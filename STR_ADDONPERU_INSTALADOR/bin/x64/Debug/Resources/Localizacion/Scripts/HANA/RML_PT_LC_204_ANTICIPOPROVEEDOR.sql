CREATE PROCEDURE RML_PT_LC_204_ANTICIPOPROVEEDOR
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
AS
BEGIN
	-- Variable de retorno para POSTRANSAC
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN

		UPDATE ODPO SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :id;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ODPO WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM ODPO WHERE "DocEntry" = :id);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ODPO WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM ODPO WHERE "DocEntry" = :id);
	END IF;

	IF :transaction_type = 'C' THEN

		UPDATE ODPO 
		      SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
		      WHERE "DocEntry" = TO_INTEGER(:id);
		      
		      UPDATE OJDT 
		      SET "Ref2"  = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODPO where "DocEntry"= TO_INTEGER(:id));
	END IF;
END