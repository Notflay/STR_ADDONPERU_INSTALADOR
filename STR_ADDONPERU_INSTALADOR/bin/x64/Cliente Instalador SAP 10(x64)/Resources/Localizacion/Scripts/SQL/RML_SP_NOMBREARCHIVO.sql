CREATE PROCEDURE RML_SP_NOMBREARCHIVO
(
    @DocKey INT
)
AS
BEGIN
    DECLARE @RUC NVARCHAR(20);
    
    -- Obtener el valor del TaxIdNum
    SELECT @RUC = TaxIdNum FROM OADM;

    -- Concatenar los valores y generar el resultado
    SELECT 
        CAST(DocNum AS NVARCHAR(10)) + '_' + 
        @RUC + '_' + 
        CONVERT(VARCHAR(8), CreateDate, 112) AS Data
    FROM @BPP_PAYDTR
    WHERE DocEntry = @DocKey;
END;
