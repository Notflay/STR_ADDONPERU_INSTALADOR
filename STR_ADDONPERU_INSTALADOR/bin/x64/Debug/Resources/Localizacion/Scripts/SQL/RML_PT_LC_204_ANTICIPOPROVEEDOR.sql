CREATE PROCEDURE RML_PT_LC_204_ANTICIPOPROVEEDOR
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    -- Variable de retorno para POSTRANSAC
    IF @transaction_type IN ('A', 'U')
    BEGIN
        UPDATE ODPO 
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, ''), 
            FolioNum = 0
        WHERE DocEntry = @id;
  
        UPDATE OJDT 
        SET Ref2 = (SELECT NumAtCard FROM ODPO WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ODPO WHERE DocEntry = @id);
        
        UPDATE JDT1 
        SET Ref2 = (SELECT NumAtCard FROM ODPO WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ODPO WHERE DocEntry = @id);
    END

    IF @transaction_type = 'C'
    BEGIN
        UPDATE ODPO 
        SET NumAtCard = '***ANULADO***', 
            U_BPP_MDSD = 'ANL', 
            Indicator = 'ZA'
        WHERE DocEntry = CAST(@id AS INT);
        
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 TransId FROM ODPO WHERE DocEntry = CAST(@id AS INT));
    END
END