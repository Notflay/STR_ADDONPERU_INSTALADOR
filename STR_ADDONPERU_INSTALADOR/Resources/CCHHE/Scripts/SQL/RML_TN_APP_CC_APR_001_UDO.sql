CREATE FUNCTION RML_TN_APP_CC_APR_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @cantidad INT;
    DECLARE @numoper NVARCHAR(10);
    DECLARE @error_message NVARCHAR(200) = '';

    -- Solo se ejecuta si el tipo de transacción es 'A' o 'U'
    IF @transaction_type = 'A' OR @transaction_type = 'U'
    BEGIN
        -- Validar si hay detalles en la tabla @STR_CCHAPRDET
       SET @cantidad = ( SELECT COUNT(*)   
        FROM "@STR_CCHAPRDET"  
        WHERE DocEntry = @id);

        -- Obtener el número de operación desde @STR_CCHAPR
       SET @numoper = ( SELECT U_CC_NMPE   
        FROM "@STR_CCHAPR"
        WHERE DocEntry = @id);

        -- Verificar si hay al menos una línea
        IF @cantidad = 0
        BEGIN
            SET @error_message = 'Se tiene que aperturar minimo una linea';
            RETURN @error_message;
        END

        -- Verificar si el número de operación es nulo
        IF ISNULL(@numoper, '') = ''
        BEGIN
            SET @error_message = 'No se registró el pago efectuado de la apertura';
            RETURN @error_message;
        END

        -- Crear un cursor para recorrer las filas de @STR_CCHAPRDET
        DECLARE CURSOR_CCH_DET CURSOR FOR
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Orden, *
        FROM "@STR_CCHAPRDET"  
        WHERE DocEntry = @id;

        -- Abrir el cursor
        OPEN CURSOR_CCH_DET;
        DECLARE @Orden INT;
        DECLARE @U_CC_NMCT NVARCHAR(50), @U_CC_NMCC NVARCHAR(50), @U_CC_CJCH NVARCHAR(50);

        -- Obtener las filas del cursor
        FETCH NEXT FROM CURSOR_CCH_DET INTO @Orden, @U_CC_NMCT, @U_CC_NMCC, @U_CC_CJCH;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si falta la cuenta contable
            IF ISNULL(@U_CC_NMCT, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | No se registró la Cuenta contable';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Verificar si falta el número de caja o entrega
            IF ISNULL(@U_CC_NMCC, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | No se registró el Núm. de Caja / Entrega';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Verificar si falta la asignación de caja chica
            IF ISNULL(@U_CC_CJCH, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | No se asignó una caja chica';
                CLOSE CURSOR_CCH_DET;
                DEALLOCATE CURSOR_CCH_DET;
                RETURN @error_message;
            END

            -- Continuar al siguiente registro en el cursor
            FETCH NEXT FROM CURSOR_CCH_DET INTO @Orden, @U_CC_NMCT, @U_CC_NMCC, @U_CC_CJCH;
        END

        -- Cerrar y desalojar el cursor
        CLOSE CURSOR_CCH_DET;
        DEALLOCATE CURSOR_CCH_DET;
    END

    -- Devolver el mensaje de error vacío si no hubo errores
    RETURN @error_message;
END;
GO
