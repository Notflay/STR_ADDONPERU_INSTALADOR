CREATE FUNCTION RML_TN_APP_PMD_30_ASIENTO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    SET @error_message = '';

    IF @transaction_type IN ('A', 'U')
    BEGIN
        DECLARE @rsl INT;
        SELECT @rsl = COUNT(*)
        FROM OJDT T0
        INNER JOIN OJDT T1 ON T0.TransId != T1.TransId 
                          AND T0.U_BPP_DocKeyDest = T1.U_BPP_DocKeyDest
                          AND T0.U_BPP_CtaTdoc = T1.U_BPP_CtaTdoc
                          AND T1.TransCode = 'DTR' 
                          AND T1.StornoToTr IS NULL 
                          AND T1.TransId = @id;
        
        IF @rsl > 0 
        BEGIN
            SET @error_message = 'Existe un asiento de detracción con la misma referencia';
        END
    END

    RETURN @error_message;
END