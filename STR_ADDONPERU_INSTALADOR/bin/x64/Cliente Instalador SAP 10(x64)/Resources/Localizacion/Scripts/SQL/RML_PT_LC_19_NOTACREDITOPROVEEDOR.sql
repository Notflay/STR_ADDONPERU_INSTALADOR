CREATE PROCEDURE RML_PT_LC_19_NOTACREDITOPROVEEDOR
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    -- Variable de retorno para POSTRANSAC
    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Al anular la factura con una NC debe mostrar anulado
        UPDATE OPCH 
        SET NumAtCard = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator = 'ZA'
        WHERE DocEntry = (SELECT TOP 1 T2.DocEntry FROM OPCH T2 
                          INNER JOIN RPC1 T1 ON T2.DocEntry = T1.BaseEntry
                          INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
                          WHERE T3.U_BPP_MDTD = 'NC' AND T1.BaseType = '18' AND T3.DocEntry = CAST(@id AS INT));
                          
        UPDATE ODPO 
        SET NumAtCard = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator = 'ZA'
        WHERE DocEntry = (SELECT TOP 1 T2.DocEntry FROM ODPO T2 
                          INNER JOIN RPC1 T1 ON T2.DocEntry = T1.BaseEntry
                          INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
                          WHERE T3.U_BPP_MDTD = 'NC' AND T1.BaseType = '204' AND T3.DocEntry = CAST(@id AS INT));
                          
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 T2.TransId FROM OPCH T2 
                         INNER JOIN RPC1 T1 ON T2.DocEntry = T1.BaseEntry
                         INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
                         WHERE T3.U_BPP_MDTD = 'NC' AND T1.BaseType = '18' AND T3.DocEntry = CAST(@id AS INT));
                         
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 T2.TransId FROM ODPO T2 
                         INNER JOIN RPC1 T1 ON T2.DocEntry = T1.BaseEntry
                         INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
                         WHERE T3.U_BPP_MDTD = 'NC' AND T1.BaseType = '204' AND T3.DocEntry = CAST(@id AS INT));
                         
        -- Modifica el campo "NumAtCard" cuando la NC es anulado
        UPDATE ORPC 
        SET NumAtCard = '***ANULADO***', U_BPP_MDSD = 'ANL'
        WHERE U_BPP_MDTD = 'NC' AND DocEntry = CAST(@id AS INT);
        
        UPDATE ORPC 
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, '')
        WHERE DocEntry = @id;
        
        UPDATE OJDT 
        SET Ref2 = (SELECT NumAtCard FROM ORPC WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ORPC WHERE DocEntry = @id);
        
        UPDATE JDT1 
        SET Ref2 = (SELECT NumAtCard FROM ORPC WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ORPC WHERE DocEntry = @id);
    END

    IF @transaction_type = 'C'
    BEGIN
        UPDATE ORPC 
        SET NumAtCard = '***ANULADO***', U_BPP_MDSD = 'ANL'
        WHERE U_BPP_MDTD = 'NC' AND DocEntry = CAST(@id AS INT);
    END
END