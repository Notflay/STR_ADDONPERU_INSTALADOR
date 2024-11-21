CREATE FUNCTION RML_TN_APP_CC_ER_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @ttcch DECIMAL(19,6);
    DECLARE @sldcch DECIMAL(19,6);
    DECLARE @flgsld CHAR(1);
    DECLARE @cnt INT;
    DECLARE @inct INT = 0;
    DECLARE @error_message NVARCHAR(200) = '';

    -- Solo se ejecuta si el tipo de transacción es 'A' o 'U'
    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Cursor para recorrer los detalles de la caja chica
        DECLARE CURSOR_CCH_DET CURSOR FOR
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS "Orden","U_CC_DIM1","U_CC_DIM3","U_CC_CDPV"
        FROM "@STR_CCHCRGDET"
        WHERE ISNULL("U_CC_CDPV", '') <> ''
        AND "DocEntry" = @id
        AND "U_CC_ESTD" <> 'OK';

        -- Sumar los montos
       
		SELECT @ttcch = SUM(IMT)
		FROM (
			SELECT 
				CASE T0.U_CC_MNDA 
					WHEN 'SOL' THEN
						CASE T1.U_CC_MNDC 
							WHEN 'SOL' THEN T1.U_CC_TTLN
							ELSE T1.U_CC_TTLN * (SELECT Rate FROM ORTT WHERE RateDate = T1.U_CC_FCDC)
						END
					ELSE
						CASE T1.U_CC_MNDC 
							WHEN 'SOL' THEN T1.U_CC_TTLN / (SELECT Rate FROM ORTT WHERE RateDate = T1.U_CC_FCDC)
							ELSE T1.U_CC_TTLN 
						END
				END AS IMT
			FROM "@STR_CCHCRG" T0 
			INNER JOIN "@STR_CCHCRGDET" T1 ON T0.DocEntry = T1.DocEntry 
			WHERE T0.DocEntry = @id 
			  AND T1.U_CC_SLCC = 'Y' 
			  AND T1.U_CC_ESTD IN ('CRE', 'ERR')
		) AS TX0;

        -- Calcular saldo
        SELECT @sldcch = "U_CC_SLDI" - @ttcch
        FROM "@STR_CCHCRG"
        WHERE "DocEntry" = @id;

        -- Obtener el indicador de saldo
        SELECT TOP 1 @flgsld = "U_STR_SLNG"
        FROM "@BPP_CAJASCHICAS" T0
        INNER JOIN "@STR_CCHCRG" T1 ON T0."Code" = T1."U_CC_NMBR"
        WHERE T1."DocEntry" = @id;

        -- Verificar si el saldo es negativo y no está permitido
        IF @sldcch < 0 AND ISNULL(@flgsld, 'N') <> 'Y'
        BEGIN
            SET @error_message = 'El monto total de los documentos registrados (' + CAST(@ttcch AS NVARCHAR(50)) + '), es mayor al saldo de esta caja chica';
            RETURN @error_message;
        END

        -- Abrir el cursor
        OPEN CURSOR_CCH_DET;

        DECLARE @Orden INT;
        DECLARE @U_CC_DIM1 NVARCHAR(50), @U_CC_DIM3 NVARCHAR(50), @U_CC_CDPV NVARCHAR(50);

        -- Obtener las filas del cursor
        FETCH NEXT FROM CURSOR_CCH_DET INTO @Orden, @U_CC_DIM1, @U_CC_DIM3, @U_CC_CDPV;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si la dimensión 1 es obligatoria
            IF ISNULL(@U_CC_DIM1, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | La dimensión 1 es obligatoria';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Verificar si la dimensión 3 es obligatoria
            IF ISNULL(@U_CC_DIM3, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | La dimensión 3 es obligatoria';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Verificar si el Socio de Negocio está inactivo
            SELECT @inct = COUNT(*)
            FROM OCRD
            WHERE "CardCode" = @U_CC_CDPV AND "frozenFor" = 'Y';

            IF @inct > 0
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | El Socio de Negocio se encuentra inactivo';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Continuar al siguiente registro en el cursor
            FETCH NEXT FROM CURSOR_CCH_DET INTO @Orden, @U_CC_DIM1, @U_CC_DIM3, @U_CC_CDPV;
        END

        -- Cerrar y desalojar el cursor
        CLOSE CURSOR_CCH_DET;
        DEALLOCATE CURSOR_CCH_DET;
    END

    -- Devolver el mensaje de error vacío si no hubo errores
    RETURN @error_message;
END;
GO
