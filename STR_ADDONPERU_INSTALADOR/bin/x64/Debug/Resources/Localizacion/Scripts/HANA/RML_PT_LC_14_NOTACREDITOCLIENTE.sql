CREATE PROCEDURE RML_PT_LC_14_NOTACREDITOCLIENTE
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
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN
		
		-- Al anular la factura con una NC debe mostrar anulado
		
		UPDATE OINV 
			SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM OINV T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry"
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='13' AND
			T3."DocEntry" = TO_INTEGER(:id)) ;
	
			UPDATE ODPI 
			SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODPI T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='203' AND
			T3."DocEntry" =TO_INTEGER(:id)); 
			
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM OINV T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='13' AND
			T3."DocEntry" =TO_INTEGER(:id));
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM ODPI T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='203' AND
			T3."DocEntry" =TO_INTEGER(:id));
			
			-- Modifica el campo "NumAtCard" cuando la NC es anulado
			update ORIN 
			set "NumAtCard" = '***ANULADO***'
			where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:id);
		
	 --Actualiza campos de documentos de Origen 

			UPDATE ORIN SET 
		      "U_BPP_MDCO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:id))
		                  when '13' then
		                        (SELECT TOP 1 
		                         T2."U_BPP_MDCD"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id)) 
		                  when '203' then
		                        (SELECT TOP 1 
		                         T2."U_BPP_MDCD"
		                        FROM ODPI T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id)) 
		                  end,         
		
		      "U_BPP_MDSO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:id))
		                  when '13' then
		                        (SELECT TOP 1 
		                        T2."U_BPP_MDSD"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id)) 
		                  when '203' then
		                        (SELECT TOP 1 
		                        T2."U_BPP_MDSD"
		                        FROM ODPI T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id)) 
		                  end,               
		            
		      "U_BPP_MDTO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:id))
		                  when '13' then
		                        (     
		                        SELECT TOP 1 
		                        T2."U_BPP_MDTD"
		                        FROM OINV T2 
		                              inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id)) 
		                  when '203' then
		                        (     
		                        SELECT TOP 1 
		                        T2."U_BPP_MDTD"
		                        FROM ODPI T2 
		                              inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id ))
		                  end,
		                                    
		      "U_BPP_SDocDate"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:id))
		                  when '13' then
		                                    (     
		                        SELECT TOP 1 T2."DocDate"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id))
		                  when '203' then
		                                    (     
		                        SELECT TOP 1 T2."DocDate"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:id))
		                  end         
		       WHERE "DocEntry" =TO_INTEGER(:id) AND "U_BPP_MDTD"='07'
		         and IFNULL((select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:id)), '-1') NOT IN ('-1','16');
		
			-- CONCATENER EL NumAtCard
			UPDATE ORIN SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
			WHERE "DocEntry" = :id;
	  
			UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ORIN WHERE "DocEntry" = :id)
			WHERE "TransId" = (SELECT "TransId" FROM ORIN WHERE "DocEntry" = :id);
			
			UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ORIN WHERE "DocEntry" = :id)
			WHERE "TransId" = (SELECT "TransId" FROM ORIN WHERE "DocEntry" = :id);
  
		-- ACTUALIZA CORRELATIVO
		IF :transaction_type = 'A' THEN
		
			select "U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO tp,sr,sNumero,cancelado from ORIN where "DocEntry"= TO_INTEGER(:id);
			
			IF :cancelado <> 'C' THEN 
				SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
				iNumero := :iNumero + 1;
			
				SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
				(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
		
				UPDATE "@BPP_NUMDOC" set "U_BPP_NDCD" = :Numero where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr;
			ELSE
				update ORIN 
			    set "NumAtCard" = '***ANULADO***'
			    where /*"U_BPP_MDSD" ='999'and*/ "DocEntry"=TO_INTEGER(:id); 
			
				UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM ORIN T0 
				INNER JOIN RIN1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = :id;
			END IF;
		END IF;	
	END IF;	
END