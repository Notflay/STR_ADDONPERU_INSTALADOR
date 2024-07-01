CREATE FUNCTION RML_TN_LC_18_FACTURAPROVEEDOR
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
user VARCHAR(20);
R1 VARCHAR(30);
R2 VARCHAR(30);
R3 VARCHAR(30);
R4 VARCHAR(30);
R5 VARCHAR(30);
DOCTYPE NCHAR(1);

DATA INTEGER; 
R6 INTEGER; 
R7 INTEGER; 
R8 INTEGER; 
R9 INTEGER;
R10 INTEGER;
Campovalida INTEGER;
TpTr int;
DcOP int;

cc nvarchar(15);
tp nvarchar(15);
sr nvarchar(15);
sNumero nvarchar(15);
iNumero integer;

sNumExist nvarchar(15);
sTipoExist nvarchar(15);
Numero nvarchar(15);
ValCorr integer;

cancelado CHAR(1);
BEGIN
	error_message := ''; 
	
	IF :transaction_type IN ('A','U') THEN
		select  (select count(*) from OPCH T0
                  WHERE (ifnull(T0."U_BPP_MDSD",'') = '' 
                  OR ifnull(T0."U_BPP_MDCD",'') = '' )
                  AND T0."DocEntry" = :id) into R1 from dummy;
            
             IF :R1 > 0 
             then 
             --error_message := CONCAT(CONCAT(CONCAT('STR_A: Debe ingresar la serie y el n�mero SUNAT ',:list_of_cols_val_tab_del),:VAL1),:VAL2) ;
				error_message := 'STR_A: Debe ingresar la serie y el n�mero SUNAT '; 
             END if;
             
         select (select count(*) from OPCH T0
                  WHERE (ifnull(T0."U_BPP_MDND",'') = '' 
                  OR ifnull(T0."U_BPP_MDFD",'') = '') 
                  AND T0."DocEntry" = :id
                  AND T0."U_BPP_MDTD" = '50') into R2 from dummy;
            
              IF :R2 > 0 
              then  
              error_message := 'STR_A: Ingrese los datos de DUA';
               END if;
               
               -- VALIDA SI YA EXISTE 
			IF :transaction_type = 'A'
			THEN	
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO cc,tp,sr,sNumero,cancelado from OPCH where "DocEntry"= TO_INTEGER(:id);
				   
				   IF :cancelado <> 'C' THEN 
				   		  
				   SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
					iNumero := :iNumero + 1;
			
					SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
					(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
					
					 SELECT (select top 1 "DocNum" from (
							select "DocNum" as "DocNum" from OPCH where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL
							select "DocNum" as "DocNum" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL					
							select "DocNum" as "DocNum" from ODPO where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999') DE) INTO sNumExist FROM DUMMY; --)					
		
			 SELECT (select top 1 "Tipo" from (					
							select "ObjType" as "Tipo" from OPCH where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL
							select "ObjType" as "Tipo" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
							UNION ALL					
							select "ObjType" as "Tipo" from ODPO where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999') TP) INTO sTipoExist FROM DUMMY; --)

					 IF IFNULL(:sNumExist, '') <> '' or IFNULL(:sTipoExist, '') <> ''
					 THEN 
					 	error_message := 'Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' || :sNumExist || ' ObjType: ' || :sTipoExist || ')';	
					 END IF;
				   END IF; 
			END IF;
	END IF;
END