CREATE PROCEDURE RML_PT_LC_203_ANTICIPOVENTAS
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
AS
cc nvarchar(15);
tp nvarchar(15);
sr nvarchar(15);
Numero nvarchar(15);
sNumero nvarchar(15);
iNumero integer;

cancelado CHAR(1);
BEGIN
	-- Variable de retorno para POSTRANSAC

	IF :transaction_type IN ('A','U') THEN
		UPDATE ODPI SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :id;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ODPI WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM ODPI WHERE "DocEntry" = :id);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ODPI WHERE "DocEntry" = :id)
		WHERE "TransId" = (SELECT "TransId" FROM ODPI WHERE "DocEntry" = :id);
	-- ACTUALIZA CORRELATIVO
		IF :transaction_type = 'A' THEN
		
			select "U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO tp,sr,sNumero,cancelado from ODPI where "DocEntry"= TO_INTEGER(:id);
			
			IF :cancelado <> 'C' THEN
				SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
				iNumero := :iNumero + 1;
				
				SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
				(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
			
				UPDATE "@BPP_NUMDOC" set "U_BPP_NDCD" = :Numero where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr;
			ELSE 
			  UPDATE ODPI 
		      SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
		      WHERE "DocEntry" =TO_INTEGER(:id);
		
		      UPDATE OJDT 
		      SET "Ref2" = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODPI where "DocEntry" = TO_INTEGER(:id));
		      
		      UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM ODPI T0 
				INNER JOIN DPI1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = :id;
		      
			END IF;
			
		
		END IF;

	END IF;

	IF :transaction_type = 'C' THEN

			UPDATE ODPI 
		      SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
		      WHERE "DocEntry" =TO_INTEGER(:id);
		
		      UPDATE OJDT 
		      SET "Ref2" = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODPI where "DocEntry" = TO_INTEGER(:id));

	END IF;

END