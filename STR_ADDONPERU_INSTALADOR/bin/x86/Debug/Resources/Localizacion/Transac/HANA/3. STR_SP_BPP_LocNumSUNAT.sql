CREATE PROCEDURE STR_SP_BPP_LocNumSUNAT
(
 IN object_type NVARCHAR(20),
 IN transaction_type NCHAR(1),
 IN list_of_cols_val_tab_del NVARCHAR(255),
 OUT error INTEGER,
 OUT error_message NVARCHAR(200)
)
LANGUAGE SQLSCRIPT
AS

cc nvarchar(15);
tp nvarchar(15);
sr nvarchar(15);
sNumero nvarchar(15);
iNumero integer;

sNumExist nvarchar(15);
sTipoExist nvarchar(15);
Numero nvarchar(15);
ValCorr integer;
BEGIN

error := 0;
error_message := N'Ok';

	IF (:object_type = '13' or 
		:object_type = '14' or
		:object_type = '15' or
		:object_type = '16' or
		:object_type = '18' or
		:object_type = '19' or
		:object_type = '203' or
		:object_type = '204' or
		:object_type = '60' or
		:object_type = '67' or
		:object_type = '46')
		AND(:transaction_type = 'A')
	THEN
	
	    SELECT (case when :object_type='13' then (select "CardCode" from OINV where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='14' then (select "CardCode" from ORIN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='15' then (select "CardCode" from ODLN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='16' then (select "CardCode" from ORDN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='18' then (select "CardCode" from OPCH where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='19' then (select "CardCode" from ORPC where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='203' then (select "CardCode" from ODPI where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='204' then (select "CardCode" from ODPO where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))	  
				  when :object_type='60' then (select "CardCode" from OIGE where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='67' then (select "CardCode" from OWTR where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='46' then (select "CardCode" from OVPM where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
			 	end) INTO cc FROM DUMMY;
	
		SELECT (case when :object_type='13' then (select "U_BPP_MDTD" from OINV where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='14' then (select "U_BPP_MDTD" from ORIN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='15' then (select "U_BPP_MDTD" from ODLN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='16' then (select "U_BPP_MDTD" from ORDN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='18' then (select "U_BPP_MDTD" from OPCH where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='19' then (select "U_BPP_MDTD" from ORPC where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='203' then (select "U_BPP_MDTD" from ODPI where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='204' then (select "U_BPP_MDTD" from ODPO where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))	  
				  when :object_type='60' then (select "U_BPP_MDTD" from OIGE where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='67' then (select "U_BPP_MDTD" from OWTR where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='46' then (select "U_BPP_MDTD" from OVPM where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='BPP_ANULCORR' then (select "U_BPP_DocSnt" from "@BPP_ANULCORR" where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				end) INTO tp FROM DUMMY;
			
		SELECT (case when :object_type='13' then (select "U_BPP_MDSD" from OINV where "DocEntry"=TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='14' then (select "U_BPP_MDSD" from ORIN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='15' then (select "U_BPP_MDSD" from ODLN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='16' then (select "U_BPP_MDSD" from ORDN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='18' then (select "U_BPP_MDSD" from OPCH where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='19' then (select "U_BPP_MDSD" from ORPC where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='203' then (select "U_BPP_MDSD" from ODPI where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='204' then (select "U_BPP_MDSD" from ODPO where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))	  			  
				  when :object_type='60' then (select "U_BPP_MDSD" from OIGE where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='67' then (select "U_BPP_MDSD" from OWTR where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='46' then (select "U_BPP_PTSC" from OVPM where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='BPP_ANULCORR' then (select "U_BPP_Serie" from "@BPP_ANULCORR" where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				end) INTO sr FROM DUMMY;
	
		SELECT (case when :object_type='13' then (select "U_BPP_MDCD" from OINV where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='14' then 
				  (select "U_BPP_MDCD" from ORIN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='15' then (select "U_BPP_MDCD" from ODLN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='16' then (select "U_BPP_MDCD" from ORDN where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='18' then (select "U_BPP_MDCD" from OPCH where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='19' then (select "U_BPP_MDCD" from ORPC where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))			  
				  when :object_type='203' then (select "U_BPP_MDCD" from ODPI where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='204' then (select "U_BPP_MDCD" from ODPO where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))	  			  
				  when :object_type='60' then (select "U_BPP_MDCD" from OIGE where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='67' then (select "U_BPP_MDCD" from OWTR where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='46' then (select "U_BPP_PTCC" from OVPM where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				  when :object_type='BPP_ANULCORR' then (select "U_BPP_NmCorH" from "@BPP_ANULCORR" where "DocEntry"= TO_INTEGER(:list_of_cols_val_tab_del))
				end) INTO sNumero FROM DUMMY;
	
	
		IF (:object_type ='13' or 
			:object_type ='14' or
			:object_type ='15' or
			:object_type ='16' or
			:object_type ='203' or
			:object_type ='60' or
			:object_type ='67' or
			:object_type ='46') 
		THEN		
	

			SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
			iNumero := :iNumero + 1;
			
			SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN 
							LPAD (TO_VARCHAR(:iNumero), 
							( length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero)) )
+ LENGTH(TO_VARCHAR(:iNumero)), '0')
						ELSE 
							TO_VARCHAR(:iNumero)
						END
					) INTO Numero FROM DUMMY; 
								

			 SELECT (SELECT top 1 "DocNum" FROM(
					select "DocNum" as "DocNum" from OINV where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from ORIN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from ODLN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from ORDN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from ODPI where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL					
					select "DocNum" as "DocNum" from OIGE where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from OWTR where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL				
					select "DocNum" as "DocNum" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "DocNum" as "DocNum" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
						where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
								and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:list_of_cols_val_tab_del)
					)) INTO sNumExist FROM DUMMY;-- DE  ;--)
					
										
		       SELECT (SELECT top 1 "Tipo" FROM (
					select "ObjType" as "Tipo" from OINV where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from ORIN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from ODLN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from ORDN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from ODPI where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from OIGE where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select "ObjType" as "Tipo" from OWTR where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL					
					select "ObjType" as "Tipo" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del)
					UNION ALL
					select 'Anulado' as "Tipo" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
						where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
								and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:list_of_cols_val_tab_del)
					)) INTO sTipoExist FROM DUMMY;-- TP;--)

			
		END IF;

		IF (:object_type ='18' or
			:object_type ='19' or
			:object_type ='204')
		THEN
			 SELECT (select top 1 "DocNum" from (
							select "DocNum" as "DocNum" from OPCH where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL
							select "DocNum" as "DocNum" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL					
							select "DocNum" as "DocNum" from ODPO where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999') DE) INTO sNumExist FROM DUMMY; --)					
		
			 SELECT (select top 1 "Tipo" from (					
							select "ObjType" as "Tipo" from OPCH where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL
							select "ObjType" as "Tipo" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL					
							select "ObjType" as "Tipo" from ODPO where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:list_of_cols_val_tab_del) and COALESCE("U_BPP_MDSD", '')<>'999') TP) INTO sTipoExist FROM DUMMY; --)
		 
		END IF;
	
 Select (select TO_INTEGER("U_BPP_NDCD")+1   from   "@BPP_NUMDOC" 
  where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr)
	   INTO ValCorr FROM DUMMY;
	--control de correlativo

 if ((:ValCorr) <>   To_integer(:Numero))
 --if (:snumero <> :Numero)
then 
error :=1;
error_message := 'El Correlativo ingresado es incorrecto' ;	
end if;	
			
	
		IF IFNULL(:sNumExist, '') = '' or IFNULL(:sTipoExist, '') = ''
	THEN 

		
			if (:object_type = '13' or
				:object_type = '14' or
				:object_type = '15' or
				:object_type = '16' or
				:object_type = '203' or
				:object_type = '60' or
				:object_type = '67' or
				:object_type = '46')
				
				AND IFNULL(:sNumero, '')<>''
				AND IFNULL(:tp, '')<>''
				AND IFNULL(:sr, '')<>''
			
			then

	 
				
				
						
			
				update "@BPP_NUMDOC" set "U_BPP_NDCD" = :Numero where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr;
			end if;
		
		ELSE			
			error :=1;
			error_message := 'Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' || :sNumExist || ' ObjType: ' || :sTipoExist || ')';	
		END IF;

END IF;

select :error, :error_message from dummy;

END;
