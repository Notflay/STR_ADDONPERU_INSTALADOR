CREATE FUNCTION RML_TN_LC_67_TRANSFERENCIASTOCK
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS

R1 VARCHAR(30);
R2 VARCHAR(30);
R3 VARCHAR(30);
R4 VARCHAR(30);
R5 VARCHAR(30);
DOCTYPE NCHAR(1);


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
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type IN ('A','U') THEN
			--Tipo de Operacion	
		SELECT(SELECT count(*) FROM WTR1  T0  INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
		WHERE (IFNULL(T0."U_tipoOpT12",'') ='' and t1."InvntItem"='Y' ) 
		AND T0."DocEntry" = :id)INTO R4 FROM DUMMY;
		
		IF :R4 > 0 THEN 
			error_message := 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento'; 
		END IF;
		
			-- VALIDA SI YA EXISTE 
			IF :transaction_type = 'A'
			THEN	
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD" INTO cc,tp,sr,sNumero from OWTR where "DocEntry"= TO_INTEGER(:id);
				   SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
					iNumero := :iNumero + 1;
			
					SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
					(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
					
					 SELECT (SELECT top 1 "DocNum" FROM(
					select "DocNum" as "DocNum" from OINV where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from ORIN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from ODLN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from ORDN where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from ODPI where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL					
					select "DocNum" as "DocNum" from OIGE where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from OWTR where "U_BPP_MDCD"=:sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL				
					select "DocNum" as "DocNum" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
						where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
								and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:id)
					)) INTO sNumExist FROM DUMMY;-- DE  ;--)
					
										
		       SELECT (SELECT top 1 "Tipo" FROM (
					select "ObjType" as "Tipo" from OINV where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from ORIN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from ODLN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from ORDN where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from ODPI where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from OIGE where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "ObjType" as "Tipo" from OWTR where "U_BPP_MDCD"= :sNumero and COALESCE("U_BPP_MDCD", '')<>'' and "U_BPP_MDSD"= :sr and COALESCE("U_BPP_MDSD", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL					
					select "ObjType" as "Tipo" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select 'Anulado' as "Tipo" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
						where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
								and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:id)
					)) INTO sTipoExist FROM DUMMY;-- TP;--)

					 Select (select TO_INTEGER("U_BPP_NDCD")+1   from   "@BPP_NUMDOC" 
				  	 where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr)
					 INTO ValCorr FROM DUMMY;
				   	 if ((:ValCorr) <>   To_integer(:Numero))
					 --if (:snumero <> :Numero)
				     Then 
						error_message := 'El Correlativo ingresado es incorrecto';	
					 end if;	
					 
					 IF IFNULL(:sNumExist, '') <> '' or IFNULL(:sTipoExist, '') <> ''
					 THEN 
					 	error_message := 'Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' || :sNumExist || ' ObjType: ' || :sTipoExist || ')';	
					 END IF;
			END IF;	
	END IF;
END