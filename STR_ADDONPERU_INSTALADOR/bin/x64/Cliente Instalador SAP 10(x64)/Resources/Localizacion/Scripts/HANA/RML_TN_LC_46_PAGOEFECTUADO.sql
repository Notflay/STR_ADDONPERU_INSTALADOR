CREATE FUNCTION RML_TN_LC_46_PAGOEFECTUADO
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
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type = 'U'
	THEN
		select (SELECT count(*) FROM OVPM T0 
            WHERE T0."U_BPP_MPPG" ='000'
           and t0."DataSource" <> 'O' AND T0."DocEntry" = :id) into R1 from dummy;
            
             /* IF :R1 > 0 then  
              error_message := 'STR_A: Ingrese el Medio de Pago SUNAT';
               END if;*/
               
        -- VALIDA SI YA EXISTE 
			IF :transaction_type = 'A'
			THEN	
				   SELECT "CardCode","U_BPP_MDTD","U_BPP_PTSC","U_BPP_PTCC","Canceled" INTO cc,tp,sr,sNumero,cancelado from OVPM where "DocEntry"= TO_INTEGER(:id);
				   
				   IF :cancelado <> 'C' THEN
				   		SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
					iNumero := :iNumero + 1;
			
					SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
					(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
					
					 SELECT (SELECT top 1 "DocNum" FROM(				
					select "DocNum" as "DocNum" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
					UNION ALL
					select "DocNum" as "DocNum" from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1."DocEntry" = T2."DocEntry" 
						where "U_BPP_TpDoc" = 'Venta' and "U_BPP_NmCr" = :sNumero and COALESCE("U_BPP_NmCr", '')<>'' and "U_BPP_DocSnt" = :tp 
								and COALESCE("U_BPP_DocSnt", '')<>'' and "U_BPP_Serie" = :sr and COALESCE("U_BPP_Serie", '') <>'' and T1."DocEntry" <> TO_INTEGER(:id)
					)) INTO sNumExist FROM DUMMY;-- DE  ;--)
					
										
		       SELECT (SELECT top 1 "Tipo" FROM (					
					select "ObjType" as "Tipo" from OVPM where "U_BPP_PTCC"= :sNumero and COALESCE("U_BPP_PTCC", '')<>'' and "U_BPP_PTSC"= :sr and COALESCE("U_BPP_PTSC", '')<>'' and "U_BPP_MDTD"= :tp and COALESCE("U_BPP_MDTD", '')<>'' and "DocEntry"<> TO_INTEGER(:id)
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