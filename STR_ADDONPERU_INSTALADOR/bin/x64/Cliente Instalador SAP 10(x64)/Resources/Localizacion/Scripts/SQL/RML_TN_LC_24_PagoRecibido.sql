CREATE FUNCTION RML_TN_LC_24_PagoRecibido
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R1 INT;

    -- Inicialización de la variable de error
    SET @error_message = '';

    -- Verificar la condición del Medio de Pago SUNAT
    SELECT @R1 = COUNT(*)
    FROM ORCT T0 
    WHERE T0.U_BPP_MPPG = '000' 
      AND T0.DataSource <> 'O'
      AND T0.DocEntry = @id;

    IF @R1 > 0
    BEGIN
        SET @error_message = 'STR_A: Ingrese el Medio de Pago SUNAT'; 
        RETURN @error_message;
    END;

    RETURN @error_message;
END;
