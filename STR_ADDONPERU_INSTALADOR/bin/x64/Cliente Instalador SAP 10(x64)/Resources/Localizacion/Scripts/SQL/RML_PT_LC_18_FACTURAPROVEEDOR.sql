CREATE PROCEDURE RML_PT_LC_18_FACTURAPROVEEDOR
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    -- Variable de retorno para POSTRANSAC
	DECLARE @canceled CHAR(1);
    IF @transaction_type IN ('A', 'U')
    BEGIN
        UPDATE OPCH
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, '')
        WHERE DocEntry = @id;
  
        UPDATE OJDT
        SET Ref2 = (SELECT NumAtCard FROM OPCH WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM OPCH WHERE DocEntry = @id);
        
        UPDATE JDT1
        SET Ref2 = (SELECT NumAtCard FROM OPCH WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM OPCH WHERE DocEntry = @id);
		
		IF @transaction_type = 'A' BEGIN 
			SELECT @canceled = "CANCELED"  FROM OPCH WHERE "DocEntry" = CAST(@id AS INT);
			IF @canceled = 'C' BEGIN
			  UPDATE OPCH 
		      SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
		      WHERE "DocEntry" = CAST(@id AS INT);
		      
		      UPDATE OJDT 
		      SET "Ref2"  = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM OPCH where "DocEntry" =CAST(@id AS INT));
		      
		      UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM OPCH T0 
				INNER JOIN PCH1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = CAST(@id AS INT);
			END 
		END
    END

    IF @transaction_type = 'C'
    BEGIN
        UPDATE OPCH 
        SET NumAtCard = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator = 'ZA'
        WHERE DocEntry = CAST(@id AS INT);
        
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 TransId FROM OPCH WHERE DocEntry = CAST(@id AS INT));
    END
END