CREATE FUNCTION RML_TN_APP_CC_ER_002_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @cnt INT;
    DECLARE @inct INT = 0;
    DECLARE @error_message NVARCHAR(200) = '';

    -- ENTREGA A RENDIR
    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Crear un cursor para recorrer las filas de "@STR_EARCRGDET"
        DECLARE CURSOR_EAR_DET CURSOR FOR
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS "Orden", *
        FROM "@STR_EARCRGDET"
        WHERE ISNULL("U_ER_CDPV", '') <> ''
        AND "DocEntry" = @id
        AND "U_ER_ESTD" <> 'OK';

        -- Abrir el cursor
        OPEN CURSOR_EAR_DET;

        DECLARE @Orden INT;
        DECLARE @U_ER_DIM1 NVARCHAR(50), @U_ER_DIM3 NVARCHAR(50), @U_ER_CDPV NVARCHAR(50);

        -- Obtener las filas del cursor
        FETCH NEXT FROM CURSOR_EAR_DET INTO @Orden, @U_ER_DIM1, @U_ER_DIM3, @U_ER_CDPV;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si la dimensión 1 es obligatoria
            IF ISNULL(@U_ER_DIM1, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | La dimensión 1 es obligatoria';
                CLOSE CURSOR_EAR_DET;
                DEALLOCATE CURSOR_EAR_DET;
                RETURN @error_message;
            END

            -- Verificar si la dimensión 3 es obligatoria
            IF ISNULL(@U_ER_DIM3, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | La dimensión 3 es obligatoria';
                CLOSE CURSOR_EAR_DET;
                DEALLOCATE CURSOR_EAR_DET;
                RETURN @error_message;
            END

            -- Verificar si el Socio de Negocio está inactivo
            SELECT @inct = COUNT(*)
            FROM OCRD
            WHERE "CardCode" = @U_ER_CDPV AND "frozenFor" = 'Y';

            IF @inct > 0
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | El Socio de Negocio se encuentra inactivo';
                CLOSE CURSOR_EAR_DET;
                DEALLOCATE CURSOR_EAR_DET;
                RETURN @error_message;
            END

            -- Continuar al siguiente registro en el cursor
            FETCH NEXT FROM CURSOR_EAR_DET INTO @Orden, @U_ER_DIM1, @U_ER_DIM3, @U_ER_CDPV;
        END

        -- Cerrar y desalojar el cursor
        CLOSE CURSOR_EAR_DET;
        DEALLOCATE CURSOR_EAR_DET;
    END

    -- Devolver el mensaje de error vacío si no hubo errores
    RETURN @error_message;
END;
GO
