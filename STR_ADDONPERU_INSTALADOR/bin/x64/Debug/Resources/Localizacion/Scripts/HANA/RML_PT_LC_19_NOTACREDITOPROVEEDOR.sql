CREATE PROCEDURE RML_PT_LC_19_NOTACREDITOPROVEEDOR
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
AS
cancelado CHAR(1);
BEGIN
	-- Variable de retorno para POSTRANSAC
	IF :transaction_type IN ('A','U') THEN
	
			-- Al anular la factura con una NC debe mostrar anulado
            UPDATE OPCH 
            SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
            WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM OPCH T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='18' AND
            T3."DocEntry" =TO_INTEGER(:id)); 
            
            UPDATE ODPO 
            SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
            WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODPO T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='204' AND
            T3."DocEntry" =TO_INTEGER(:id)); 
            
            UPDATE OJDT 
            SET "Ref2"  = '***ANULADO***'
            WHERE "TransId" = (Select top 1 T2."TransId" FROM OPCH T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='18' AND
            T3."DocEntry" =TO_INTEGER(:id));
            
            UPDATE OJDT 
            SET "Ref2"  = '***ANULADO***'
            WHERE "TransId" = (Select top 1 T2."TransId" FROM ODPO T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='204' AND
            T3."DocEntry" =TO_INTEGER(:id));

			-- Modifica el campo "NumAtCard" cuando la NC es anulado
            update ORPC 
            set "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL'
            where "U_BPP_MDTD" ='NC' and "DocEntry"=TO_INTEGER(:id);
            
            UPDATE ORPC SET "NumAtCard" = IFNULL( "U_BPP_MDTD",'') || '-' || IFNULL( "U_BPP_MDSD",'') || '-' || IFNULL( "U_BPP_MDCD",'')
			WHERE "DocEntry" = :id;
	  
			UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ORPC WHERE "DocEntry" = :id)
			WHERE "TransId" = (SELECT "TransId" FROM ORPC WHERE "DocEntry" = :id);
			
			UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ORPC WHERE "DocEntry" = :id)
			WHERE "TransId" = (SELECT "TransId" FROM ORPC WHERE "DocEntry" = :id);
			
			IF :transaction_type = 'A' THEN 
				SELECT "CANCELED" INTO cancelado FROM ORPC WHERE "DocEntry" = TO_INTEGER(:id);
				IF :cancelado = 'C' THEN
					UPDATE ORPC 
		       		SET "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL'
		       		WHERE "U_BPP_MDTD" ='NC' and "DocEntry"=TO_INTEGER(:id); 
		       		
		       		UPDATE T0
					SET T0."NumAtCard" = '***ANULADO***', T0."U_BPP_MDSD" = 'ANL'
					FROM ORPC T0 
					INNER JOIN RPC1 T1 ON T1."BaseEntry" = T0."DocEntry"
					WHERE T1."DocEntry" = :id;
							       		
				END IF;
			END IF;
			
            
	END IF;
	
	IF :transaction_type = 'C' THEN 
		update ORPC 
		       set "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL'
		       where "U_BPP_MDTD" ='NC' and "DocEntry"=TO_INTEGER(:id); 
	END IF;
END