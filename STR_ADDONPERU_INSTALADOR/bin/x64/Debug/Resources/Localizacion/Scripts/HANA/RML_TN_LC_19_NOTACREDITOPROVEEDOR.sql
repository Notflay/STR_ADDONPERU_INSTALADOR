CREATE FUNCTION RML_TN_LC_19_NOTACREDITOPROVEEDOR
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

crdCode nvarchar(50);
ctaDetrac nvarchar(50);
v_LocManTran nvarchar(10);
Detrac integer;

cancelado CHAR(1);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type = 'U'
	THEN
			select top 1 "CardCode" INTO crdCode  from ORPC where "DocEntry"=:id;	
			select top 1 Count("WTCode") INTO Detrac FROM RPC5 where "WTCode" like 'DT%' and "AbsEntry"=:id;
		
			IF :Detrac > 0 THEN
				 SELECT(select top 1 COALESCE("U_BPP_CtaDetrac", '') from OCRD where "CardCode"=:crdCode)INTO ctaDetrac FROM DUMMY;
				IF IFNULL(:ctaDetrac, '')='' THEN
							error_message := 'No se ha definido la cuenta asociada de Detracciones para el socio de negocio.';
				END IF;	
			END IF;
			
			SELECT (select top 1 "LocManTran" from OACT where "FormatCode"=:ctaDetrac) INTO v_LocManTran FROM DUMMY;
			
			IF :v_LocManTran = 'N' THEN
					error_message := 'La cuenta del socio de negocio definida para el asiento de detracción no es una cuenta asociada.';
			END IF;
	
	
		 	--Indicador de la Nota de Credito
            select  (SELECT count(*) FROM ORPC T0 
            WHERE ifnull(T0."U_BPP_MDTD",'') ='' 
            AND T0."DocEntry" = :id) INTO R1 from dummy;
            --Tipo de Operacion     
            select  (select A."DocType"  from ORPC A where A."DocEntry" = :id ) into DOCTYPE from dummy;
            IF :DOCTYPE='I'
            then     
                 
            select (SELECT count(*) FROM RPC1 T0  INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
            WHERE ifnull(T0."U_tipoOpT12",'') ='' and t1."InvntItem"='Y'  
            AND T0."DocEntry" = :id) into R4 from dummy;
            
              IF :R1 > 0
               then  error_message := 'Debe seleccionar el tipo de documento SUNAT';
                END if;
              IF :R4 > 0 
              then error_message := 'Ingrese el Tipo de Operacion en el detalle del documento';
               END if;
           end if;
           
           
           -- VALIDA SI YA EXISTE 
			IF :transaction_type = 'A'
			THEN	
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO cc,tp,sr,sNumero,cancelado from ORPC where "DocEntry"= TO_INTEGER(:id);
				   
				   IF :cancelado <> 'C' THEN 
				   
				   		-- Validar que se haya colocado TIPO - SERIE Y CORRELATIVO
				   		IF IFNULL(sr,'') = '' THEN
				  			error_message := 'Ingrese la serie del documento'; 
				  			RETURN;		
				   		END IF;
				   		
				   		IF IFNULL(sNumero,'') = '' THEN
				  			error_message := 'Ingrese el correlativo del documento'; 
				  			RETURN;		
				   		END IF;
				   
				   		SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
						iNumero := :iNumero + 1;
				
						SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
						(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
					
						 SELECT (select top 1 "DocNum" from (
								select "DocNum" as "DocNum" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
								) DE) INTO sNumExist FROM DUMMY; --)					
			
						 SELECT (select top 1 "Tipo" from (					
										select "ObjType" as "Tipo" from ORPC where "CardCode"= :cc and "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id) and COALESCE("U_BPP_MDSD", '')<>'999'
										) TP) INTO sTipoExist FROM DUMMY; --)
								 
						 IF IFNULL(:sNumExist, '') <> '' or IFNULL(:sTipoExist, '') <> ''
						 THEN 
						 	error_message := 'Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' || :sNumExist || ' ObjType: ' || :sTipoExist || ')';	
						 END IF;
						 
						 
						 
				   END IF;
			END IF;
	END IF;
END