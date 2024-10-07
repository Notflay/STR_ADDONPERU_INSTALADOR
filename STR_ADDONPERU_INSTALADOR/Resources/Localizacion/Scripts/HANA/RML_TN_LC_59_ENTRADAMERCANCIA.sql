CREATE FUNCTION RML_TN_LC_59_ENTRADAMERCANCIA
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
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN
		   --Tipo de Operacion	
		
		SELECT(SELECT count(*) FROM IGN1 T0  INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
		WHERE (IFNULL(T0."U_tipoOpT12",'') ='' and t1."InvntItem"='Y' ) 
		AND T0."DocEntry" = :id)INTO R4 FROM DUMMY;
		
		IF :R4 > 0 THEN 
			error_message := 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento'; 
		END IF;
		
		-- VALIDA SI YA EXISTE 
		IF :transaction_type = 'A'
			THEN	
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO cc,tp,sr,sNumero,cancelado from OIGN where "DocEntry"= TO_INTEGER(:id);
				   
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
							
							 SELECT (SELECT top 1 "DocNum" FROM(					
							select "DocNum" as "DocNum" from OIGN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
							UNION ALL
							select "DocNum" as "DocNum" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
								where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
										and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:id)
							)) INTO sNumExist FROM DUMMY;-- DE  ;--)
							
												
				       		SELECT (SELECT top 1 "Tipo" FROM (
							select "ObjType" as "Tipo" from OIGN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
							UNION ALL
							select 'Anulado' as "Tipo" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
								where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
										and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:id)
							)) INTO sTipoExist FROM DUMMY;-- TP;--)
		
							 
							 IF IFNULL(:sNumExist, '') <> '' or IFNULL(:sTipoExist, '') <> ''
							 THEN 
							 	error_message := 'Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' || :sNumExist || ' ObjType: ' || :sTipoExist || ')';	
							 END IF;
							
				   END IF;		  
			END IF;
	END IF;
END