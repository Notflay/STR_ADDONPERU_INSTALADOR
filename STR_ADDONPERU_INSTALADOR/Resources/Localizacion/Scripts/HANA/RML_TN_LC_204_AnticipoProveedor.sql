CREATE FUNCTION RML_TN_LC_204_AnticipoProveedor
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
astDetracTransId nvarchar(15);
cardCode nvarchar(50);
crdCode nvarchar(50);
ctaDetrac nvarchar(50);
Detrac integer;
Suma1 double;
Suma2 double;

--r VARCHAR(200);
user VARCHAR(20);
R1 VARCHAR(30);
R2 VARCHAR(30);
R3 VARCHAR(30);
R4 VARCHAR(30);
R5 VARCHAR(30);
DOCTYPE NCHAR(1);

v_BaseEntry nvarchar(50);
v_LocManTran nvarchar(10);

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
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	
	
	IF :transaction_type IN ('A','U') THEN
		select top 1 "CardCode" INTO crdCode  from ODPO where "DocEntry"=:id;	
	select top 1 Count("WTCode") INTO Detrac FROM DPO5 where "WTCode" like 'DT%' and "AbsEntry"=:id;
	
	IF :Detrac > 0 THEN
		 SELECT(select top 1 COALESCE("U_BPP_CtaDetrac", '') from OCRD where "CardCode"=:crdCode)INTO ctaDetrac FROM DUMMY;
		IF IFNULL(:ctaDetrac, '')='' THEN
					error_message := 'No se ha definido la cuenta asociada de Detracciones para el socio de negocio.';
		END IF;	
	END IF;
		
	SELECT (select top 1 "LocManTran" from OACT where "FormatCode"=:ctaDetrac) INTO v_LocManTran FROM DUMMY;
		
	IF :v_LocManTran = 'N' THEN
			error_message :='La cuenta del socio de negocio definida para el asiento de detracción no es una cuenta asociada.';
	END IF;
		
	
		select (select count(*) from ODPO T0
                  WHERE (ifnull(T0."U_BPP_MDSD",'') = '' 
                  OR ifnull(T0."U_BPP_MDCD",'') = '') 
                  AND T0."DocEntry" =:id) into R1 from dummy;
            
            IF :R1 > 0 
            then
            error_message := 'STR_A: Debe ingresar la serie y el n�mero SUNAT';
             END if;
             
         select (select count(*) from ODPO T0
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
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO cc,tp,sr,sNumero,cancelado from ODPO where "DocEntry"= TO_INTEGER(:id);
				   
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