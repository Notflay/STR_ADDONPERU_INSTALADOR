CREATE PROCEDURE RML_PT_LC_16_DEVOLUCIONES
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
	
-- Al anular la factura con una NC debe mostrar anulado
	IF :transaction_type IN ('A','U') THEN
		
		UPDATE ODLN 
			SET "NumAtCard" = '***ANULADO***'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODLN T2 inner join RDN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORDN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' AND
			T3."DocEntry" =TO_INTEGER(:id)); 
			
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM ODLN T2 inner join RDN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORDN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' AND
			T3."DocEntry" =TO_INTEGER(:id));
			
			
			-- Modifica el campo "NumAtCard" cuando la NC es anulado
			update ORDN 
			set "NumAtCard" = '***ANULADO***'
			where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:id) ;
	-- ACTUALIZA CORRELATIVO
		IF :transaction_type = 'A' THEN
		
			select "U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO tp,sr,sNumero,cancelado from ORDN where "DocEntry"= TO_INTEGER(:id);
			
			IF :cancelado <> 'C' THEN		
					SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
					iNumero := :iNumero + 1;
			
				SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
				(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
		
				UPDATE "@BPP_NUMDOC" set "U_BPP_NDCD" = :Numero where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr;
			ELSE
			  Update ORDN 
		      set "NumAtCard" = '***ANULADO***'
		      where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:id);
				
				UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM ORDN T0 
				INNER JOIN RDN1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = :id;
			END IF;	
		END IF;		
	END IF;
	
END