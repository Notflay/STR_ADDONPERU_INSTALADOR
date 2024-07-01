CREATE PROCEDURE RML_PT_LC_18_FACTURAPROVEEDOR
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
AS
cancelado CHAR(1);
BEGIN
	-- Variable de retorno para POSTRANSAC

	IF :transaction_type IN('A','U') THEN
		UPDATE OPCH SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",'')
		WHERE "DocEntry" = :id;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM OPCH WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM OPCH WHERE "DocEntry" = :id);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM OPCH WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM OPCH WHERE "DocEntry" = :id);
		
		IF :transaction_type = 'A' THEN 
			SELECT "CANCELED" INTO cancelado FROM OPCH WHERE "DocEntry" = TO_INTEGER(:id);
			IF :cancelado = 'C' THEN
			  UPDATE OPCH 
		      SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
		      WHERE "DocEntry" =TO_INTEGER(:id);
		      
		      UPDATE OJDT 
		      SET "Ref2"  = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM OPCH where "DocEntry" =TO_INTEGER(:id));
		      
		      UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM OPCH T0 
				INNER JOIN PCH1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = :id;
			END IF;
		END IF;
	END IF;
END