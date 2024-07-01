CREATE PROCEDURE STR_TN_General
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)

AS

--Variables general
iVal int :=0;
iVal2 int :=0;
nVal nvarchar(10) :='';
nVal2 nvarchar(20) :='n';
dVal Date;


--Pago masivo detracciones
vv_CodComp INTEGER;
vd_FecDeps SECONDDATE;
vv_NumDeps VARCHAR(20);
vv_CdgPvdr VARCHAR(40);
vv_Nmatcar VARCHAR(40);
vv_Status VARCHAR(1);

---

BEGIN
error :=0;
error_message := N'Ok';


--------------------------------------------------------------------------
--------------------------------------------------------------------------


--Exclusivo para Localización Strat.
IF IFNULL(:error,0)=0 
THEN
CALL STR_TN_Localizacion(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);
END IF;

--Exclusivo para Objetos - Consultor
-- SE DEFINIRÁ CON EL USUARIO QUE VALIDACIONES REQUIERE
/*
IF IFNULL(:error,0)=0 
THEN
CALL STR_TN_Funcional(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);
END IF;
*/

--Exclusivo para Addon Caja Chica.
IF IFNULL(:error,0)=0 
THEN
CALL STR_SP_Valida_CCH_EAR(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
END IF;
	
   --Exclusivo para Addon Letra
IF IFNULL(:error,0)=0 
THEN
CALL STR_SP_Valida_Letras(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
END IF;

    
--Exclusivo para Addon Facturacion electronica
IF IFNULL(:error,0)=0 
THEN
CALL STR_SP_Valida_FactElect(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
END IF;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--PAGO MASIVO DE DETRACCIONES PROVEEDORES---

	IF :object_type = 'BPP_PAYDTR' AND (:transaction_type = 'U') THEN
		SELECT (SELECT TOP 1 "Status" FROM "@BPP_PAYDTR" WHERE "DocEntry" = list_of_cols_val_tab_del) INTO vv_Status FROM DUMMY;
		SELECT (SELECT TOP 1 "U_BPP_FcDp" FROM "@BPP_PAYDTR" WHERE "DocEntry" = list_of_cols_val_tab_del) INTO vd_FecDeps FROM DUMMY;
			IF (IFNULL(:vv_Status, '') = 'C') THEN
				--------------------------------------------------------------------------------------------------------------------------------------		
				DECLARE CURSOR CUR_UpdateOPCHNmCnst FOR
					SELECT T1."U_BPP_DocKeyDest", T0."U_BPP_CgPv", T0."U_BPP_Cnst"
  						FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs" = T1."TransId" WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
				--------------------------------------------------------------------------------------------------------------------------------------
				   FOR vcur_Row AS CUR_UpdateOPCHNmCnst DO
		 				    vv_CodComp := vcur_Row."U_BPP_DocKeyDest";
							vv_CdgPvdr := vcur_Row."U_BPP_CgPv";
							vv_NumDeps := vcur_Row."U_BPP_Cnst";
				
							UPDATE OPCH TX SET TX."U_BPP_DPFC" = :vd_FecDeps, TX."U_BPP_DPNM" = :vv_NumDeps 
									WHERE "DocEntry" = :vv_CodComp AND TX."CardCode" = vv_CdgPvdr;
				   END FOR; 
				 --------------------------------------------------------------------------------------------------------------------------------------
				   UPDATE ORPC SET "U_BPP_DPFC"=:vd_FecDeps, "U_BPP_DPNM"=:vv_NumDeps WHERE "DocEntry" IN (SELECT T1."U_BPP_DocKeyDest" FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs"=T1."TransId" WHERE T0."DocEntry"=list_of_cols_val_tab_del AND T1."U_BPP_CtaTdoc"='19');
				   UPDATE ODPO SET "U_BPP_DPFC"=:vd_FecDeps, "U_BPP_DPNM"=:vv_NumDeps WHERE "DocEntry" IN (SELECT T1."U_BPP_DocKeyDest" FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs"=T1."TransId" WHERE T0."DocEntry"=list_of_cols_val_tab_del AND T1."U_BPP_CtaTdoc"='204');
			END IF;
	END IF;

	If IFNULL(:error,0)=0 and :object_type ='30' and (:transaction_type ='A' or :transaction_type ='U')
	then

	declare rsl int;
	
	select count('a') into rsl from OJDT T0  inner join OJDT T1 ON T0."TransId" != T1."TransId" AND T0."U_BPP_DocKeyDest" = T1."U_BPP_DocKeyDest"
	AND T0."U_BPP_CtaTdoc" = '18'  AND T1."TransCode" = 'DTR' and T1."StornoToTr" is null AND T1."TransId" = :list_of_cols_val_tab_del;
	if :rsl > 0 
	then 
		error := 1;
		error_message :='STR: Existe un asiento de detracción con la misma referencia';
	end if;
	
end if;

-- Resultado
SELECT :error, :error_message from dummy;

END;




