CREATE FUNCTION RML_TN_APP_CC_APR_002_UDO
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
        -- Validar si hay detalles en la tabla "@STR_EARAPRDET"
        SELECT @cantidad = COUNT(*)
        FROM "@STR_EARAPRDET"  
        WHERE "DocEntry" = @id;

        -- Obtener el número de operación desde "@STR_EARAPR"
        SELECT @numoper = "U_ER_NMPE" 
        FROM "@STR_EARAPR"
        WHERE "DocEntry" = @id;

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

        -- Crear un cursor para recorrer las filas de "@STR_EARAPRDET"
        DECLARE CURSOR_EAR_DET CURSOR FOR
        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS "Orden", U_ER_CDCT, U_ER_NMER
        FROM "@STR_EARAPRDET"
        WHERE "DocEntry" = @id;

        -- Abrir el cursor
        OPEN CURSOR_EAR_DET;

        DECLARE @Orden INT;
        DECLARE @U_ER_CDCT NVARCHAR(50), @U_ER_NMER NVARCHAR(50);

        -- Obtener las filas del cursor
        FETCH NEXT FROM CURSOR_EAR_DET INTO @Orden, @U_ER_CDCT, @U_ER_NMER;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si falta la cuenta contable
            IF ISNULL(@U_ER_CDCT, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | No se registró la Cuenta contable';
                CLOSE CURSOR_EAR_DET;
                DEALLOCATE CURSOR_EAR_DET;
                RETURN @error_message;
            END

            -- Verificar si falta el número de entrega a rendir
            IF ISNULL(@U_ER_NMER, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@Orden AS NVARCHAR(10)) + ' | No se registró el Núm. de Entrega a Rendir';
                CLOSE CURSOR_EAR_DET;
                DEALLOCATE CURSOR_EAR_DET;
                RETURN @error_message;
            END

            -- Continuar al siguiente registro en el cursor
            FETCH NEXT FROM CURSOR_EAR_DET INTO @Orden, @U_ER_CDCT, @U_ER_NMER;
        END

        -- Cerrar y desalojar el cursor
        CLOSE CURSOR_EAR_DET;
        DEALLOCATE CURSOR_EAR_DET;
    END

    -- Devolver el mensaje de error vacío si no hubo errores
    RETURN @error_message;
END;
GO
