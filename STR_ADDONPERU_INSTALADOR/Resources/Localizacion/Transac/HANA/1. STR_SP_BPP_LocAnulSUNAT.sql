CREATE PROCEDURE STR_SP_BPP_LocAnulSUNAT
(
 IN object_type NVARCHAR(20),
 IN transaction_type NCHAR(1),
 --IN num_of_cols_in_key INTEGER,
 --IN list_of_key_cols_tab_del NVARCHAR(255),
 IN list_of_cols_val_tab_del NVARCHAR(255),
 OUT error INTEGER,
 OUT error_message NVARCHAR(200)
)
LANGUAGE SQLSCRIPT
AS
varInt integer;
varChars Varchar(20);

BEGIN
	

error := 0;
error_message := N'Ok';

-- Al anular la factura con una NC debe mostrar anulado
		IF :object_type = '14' AND (:transaction_type = 'A' or :transaction_type = 'U')THEN
			UPDATE OINV 
			SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM OINV T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry"
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='13' AND
			T3."DocEntry" = TO_INTEGER(:list_of_cols_val_tab_del)) ;
	
			UPDATE ODPI 
			SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODPI T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='203' AND
			T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)); 
			
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM OINV T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='13' AND
			T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM ODPI T2 inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' and T1."BaseType"='203' AND
			T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));
			
			-- Modifica el campo "NumAtCard" cuando la NC es anulado
			update ORIN 
			set "NumAtCard" = '***ANULADO***'
			where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del);
		
		END IF;

 		
		IF :object_type = '16' AND (:transaction_type = 'A' or :transaction_type = 'U')THEN
			UPDATE ODLN 
			SET "NumAtCard" = '***ANULADO***'
			WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODLN T2 inner join RDN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORDN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' AND
			T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)); 
			
			
			UPDATE OJDT 
			SET "Ref2" = '***ANULADO***'
			WHERE "TransId" = (Select top 1 T2."TransId" FROM ODLN T2 inner join RDN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
			INNER JOIN ORDN T3 ON T3."DocEntry" = T1."DocEntry"
			where T3."U_BPP_MDSD" ='999' AND
			T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));
			
			
			-- Modifica el campo "NumAtCard" cuando la NC es anulado
			update ORDN 
			set "NumAtCard" = '***ANULADO***'
			where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del) ;
		
		END IF;
		
---COMPRAS
--Muestra Anulado cuando a la Fact se genera una Nota de credito 
		IF :object_type = '19' AND (:transaction_type = 'A' or :transaction_type = 'U')THEN
      		-- Al anular la factura con una NC debe mostrar anulado
            UPDATE OPCH 
            SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
            WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM OPCH T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='18' AND
            T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)); 
            
            UPDATE ODPO 
            SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
            WHERE "DocEntry" = (Select top 1 T2."DocEntry" FROM ODPO T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='204' AND
            T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)); 
            
            UPDATE OJDT 
            SET "Ref2"  = '***ANULADO***'
            WHERE "TransId" = (Select top 1 T2."TransId" FROM OPCH T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='18' AND
            T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));
            
            UPDATE OJDT 
            SET "Ref2"  = '***ANULADO***'
            WHERE "TransId" = (Select top 1 T2."TransId" FROM ODPO T2 inner join RPC1 T1 ON T2."DocEntry"= T1."BaseEntry" 
                 INNER JOIN ORPC T3 ON T3."DocEntry" = T1."DocEntry"
            where T3."U_BPP_MDTD" ='NC' AND T1."BaseType"='204' AND
            T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));

			-- Modifica el campo "NumAtCard" cuando la NC es anulado
            update ORPC 
            set "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL'
            where "U_BPP_MDTD" ='NC' and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del);
		
		END IF;
		
--Actualiza campos de documentos de Origen 
		IF :object_type = '14' AND (:transaction_type = 'A' or :transaction_type = 'U')THEN
		      UPDATE ORIN SET 
		      "U_BPP_MDCO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del))
		                  when '13' then
		                        (SELECT TOP 1 
		                         T2."U_BPP_MDCD"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)) 
		                  when '203' then
		                        (SELECT TOP 1 
		                         T2."U_BPP_MDCD"
		                        FROM ODPI T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)) 
		                  end,         
		
		      "U_BPP_MDSO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del))
		                  when '13' then
		                        (SELECT TOP 1 
		                        T2."U_BPP_MDSD"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)) 
		                  when '203' then
		                        (SELECT TOP 1 
		                        T2."U_BPP_MDSD"
		                        FROM ODPI T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)) 
		                  end,               
		            
		      "U_BPP_MDTO"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del))
		                  when '13' then
		                        (     
		                        SELECT TOP 1 
		                        T2."U_BPP_MDTD"
		                        FROM OINV T2 
		                              inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del)) 
		                  when '203' then
		                        (     
		                        SELECT TOP 1 
		                        T2."U_BPP_MDTD"
		                        FROM ODPI T2 
		                              inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del ))
		                  end,
		                                    
		      "U_BPP_SDocDate"=
		            case (select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del))
		                  when '13' then
		                                    (     
		                        SELECT TOP 1 T2."DocDate"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del))
		                  when '203' then
		                                    (     
		                        SELECT TOP 1 T2."DocDate"
		                        FROM OINV T2 
		                                    inner join RIN1 T1 ON T2."DocEntry"= T1."BaseEntry" 
		                                    INNER JOIN ORIN T3 ON T3."DocEntry" = T1."DocEntry"
		                        where T3."DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del))
		                  end         
		       WHERE "DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del) AND "U_BPP_MDTD"='07'
		         and IFNULL((select top 1 "BaseType" From RIN1 where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del)), '-1') NOT IN ('-1','16');
		      
		END IF;
		
		IF :object_type = '13' AND (:transaction_type = 'C')THEN
		      UPDATE OINV 
		      SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
		      where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del);
		      
		      UPDATE OJDT 
		      SET "Ref2" = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM OINV where "DocEntry" = TO_INTEGER(:list_of_cols_val_tab_del));
		END IF;
		
		IF :object_type = '203' AND (:transaction_type = 'C')THEN
		      UPDATE ODPI 
		      SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
		      WHERE "DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del);
		
		      UPDATE OJDT 
		      SET "Ref2" = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODPI where "DocEntry" = TO_INTEGER(:list_of_cols_val_tab_del));
		END IF;
		
		IF :object_type = '14' AND (:transaction_type = 'C')THEN
		      update ORIN 
		      set "NumAtCard" = '***ANULADO***'
		      where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del); 
		END IF;
		
		IF :object_type = '15' AND (:transaction_type = 'C')THEN
		      UPDATE ODLN 
		      SET "NumAtCard" = '***ANULADO***'
		      WHERE "DocEntry" = TO_INTEGER(:list_of_cols_val_tab_del);
		      
		      UPDATE OJDT 
		      SET "Ref2" = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODLN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del));
		END IF;
		
		IF :object_type = '16' AND (:transaction_type = 'C') THEN
		      update ORDN 
		      set "NumAtCard" = '***ANULADO***'
		      where "U_BPP_MDSD" ='999'and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del);
		END IF;
		
		IF :object_type = '18' AND (:transaction_type = 'C') THEN
		      UPDATE OPCH 
		      SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
		      WHERE "DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del);
		      
		      UPDATE OJDT 
		      SET "Ref2"  = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM OPCH where "DocEntry" =TO_INTEGER(:list_of_cols_val_tab_del));
		END IF;   
		
		IF :object_type = '204' AND (:transaction_type = 'C') THEN            
		      UPDATE ODPO 
		      SET   "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL', "Indicator"='ZA'
		      WHERE "DocEntry" = TO_INTEGER(:list_of_cols_val_tab_del);
		      
		      UPDATE OJDT 
		      SET "Ref2"  = '***ANULADO***'
		      WHERE "TransId" = (Select top 1 "TransId" FROM ODPO where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del));
		END IF;
		
		IF :object_type = '19' AND :transaction_type = 'C' THEN
		       update ORPC 
		       set "NumAtCard" = '***ANULADO***', "U_BPP_MDSD" = 'ANL'
		       where "U_BPP_MDTD" ='NC' and "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del); 
		END IF;


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
	--FACTURA VENTA 
	IF :object_type = '13' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
		UPDATE OINV SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
	
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM OINV WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM OINV WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM OINV WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM OINV WHERE "DocEntry" = :list_of_cols_val_tab_del);
  
	END IF;
	--FACTURA ANTICIPO
	IF :object_type = '203' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
		UPDATE ODPI SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ODPI WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODPI WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ODPI WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODPI WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
	END IF;
	--NOTA CREDITO VENTA
	IF :object_type = '14' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN

		UPDATE ORIN SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ORIN WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ORIN WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ORIN WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ORIN WHERE "DocEntry" = :list_of_cols_val_tab_del);
  
	END IF;
	--GUIA DE REMISION VENTA
	IF :object_type = '15' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN

		UPDATE ODLN SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ODLN WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODLN WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ODLN WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODLN WHERE "DocEntry" = :list_of_cols_val_tab_del);
  
	END IF;

	--FACTURA PROVEEDORES
	IF :object_type = '18' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
		UPDATE OPCH SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",'')
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM OPCH WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM OPCH WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM OPCH WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM OPCH WHERE "DocEntry" = :list_of_cols_val_tab_del);
  
	END IF;

	--ANTICIPO PROVEEDORES
	IF :object_type = '204' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN
		UPDATE ODPO SET "NumAtCard" = IFNULL("U_BPP_MDTD",'') || '-' || IFNULL("U_BPP_MDSD",'') || '-' || IFNULL("U_BPP_MDCD",''), "FolioNum" = 0
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ODPO WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODPO WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ODPO WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ODPO WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
	END IF;
	--NOTA CREDITO PROVEEDORES
	IF :object_type = '19' and (:transaction_type = 'A' OR :transaction_type = 'U') THEN

		UPDATE ORPC SET "NumAtCard" = IFNULL( "U_BPP_MDTD",'') || '-' || IFNULL( "U_BPP_MDSD",'') || '-' || IFNULL( "U_BPP_MDCD",'')
		WHERE "DocEntry" = :list_of_cols_val_tab_del;
  
		UPDATE OJDT SET "Ref2" =  (SELECT "NumAtCard" FROM ORPC WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ORPC WHERE "DocEntry" = :list_of_cols_val_tab_del);
		
		UPDATE JDT1 SET "Ref2" =  (SELECT "NumAtCard" FROM ORPC WHERE "DocEntry" = :list_of_cols_val_tab_del)
		WHERE "TransId" = (SELECT "TransId" FROM ORPC WHERE "DocEntry" = :list_of_cols_val_tab_del);
  
	END IF;

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
		
--***********************************************************************************************************************************************************************
--- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
--Validacion para el ingreso de documentos por socio de negocio
	
		
		IF :object_type = '18' AND :transaction_type = 'A' THEN
		      --SELECT @varChar=T0.CardCode FROM OPCH T0 WHERE T0."DocEntry"=:list_of_cols_val_tab_del      
		      SELECT(SELECT T0."CardCode" FROM OPCH T0 WHERE T0."DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del)) INTO varChars FROM DUMMY;
		      --SELECT @varInt= COUNT(*)from opch T0 
		      SELECT (SELECT COUNT(*) FROM opch T0 
						WHERE T0."DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del) 
						AND (CAST(T0."CardCode" AS VARCHAR(20))|| T0."U_BPP_MDTD" || 
						RIGHT(LPAD(CAST(T0."U_BPP_MDSD" AS VARCHAR(5)),5,'0') ,5) || 
						RIGHT(LPAD(CAST(T0."U_BPP_MDCD" AS VARCHAR(15)),15,'0'),15)) 
						IN (SELECT CAST(T1."CardCode" AS VARCHAR(20)) || T1."U_BPP_MDTD" || 
						RIGHT(LPAD(CAST(T1."U_BPP_MDSD" AS VARCHAR(5)),'0',5),5) || 
						RIGHT(LPAD(CAST(T1."U_BPP_MDCD" AS VARCHAR(15)),'0',15),15) 
					  FROM OPCH T1 
					  WHERE T1."DocEntry"!=TO_INTEGER(:list_of_cols_val_tab_del) and T1."CardCode"=:varChars)) INTO varInt FROM DUMMY;
							    
				IF :varInt > 0 THEN
					error :=1;
					error_message :='Este Nro de Documento ya fue registrado'|| cast(:varInt as varchar(5)) || :varChars;
				END IF; 	
		END IF;

SELECT :error, :error_message FROM DUMMY;

END;




