CREATE PROCEDURE RML_PT_APP_PMD_001_UDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
--RETURNS VARCHAR(200)
AS
vv_CodComp INTEGER;
vd_FecDeps SECONDDATE;
vv_NumDeps VARCHAR(20);
vv_CdgPvdr VARCHAR(40);
vv_Nmatcar VARCHAR(40);
vv_Status VARCHAR(1);
BEGIN
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
/*VALIDACION DE PAGO MASIVOS DETRACCIONES*/

	IF :transaction_type = 'U' THEN
	
		SELECT (SELECT TOP 1 "Status" FROM "@BPP_PAYDTR" WHERE "DocEntry" = id) INTO vv_Status FROM DUMMY;
		SELECT (SELECT TOP 1 "U_BPP_FcDp" FROM "@BPP_PAYDTR" WHERE "DocEntry" = id) INTO vd_FecDeps FROM DUMMY;
			IF (IFNULL(:vv_Status, '') = 'C') THEN
				--------------------------------------------------------------------------------------------------------------------------------------		
				DECLARE CURSOR CUR_UpdateOPCHNmCnst FOR
					SELECT T1."U_BPP_DocKeyDest", T0."U_BPP_CgPv", T0."U_BPP_Cnst"
  						FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs" = T1."TransId" WHERE T0."DocEntry" = :id;
				--------------------------------------------------------------------------------------------------------------------------------------
				   FOR vcur_Row AS CUR_UpdateOPCHNmCnst DO
		 				    vv_CodComp := vcur_Row."U_BPP_DocKeyDest";
							vv_CdgPvdr := vcur_Row."U_BPP_CgPv";
							vv_NumDeps := vcur_Row."U_BPP_Cnst";
				
							UPDATE OPCH TX SET TX."U_BPP_DPFC" = :vd_FecDeps, TX."U_BPP_DPNM" = :vv_NumDeps 
									WHERE "DocEntry" = :vv_CodComp AND TX."CardCode" = vv_CdgPvdr;
				   END FOR; 
				 --------------------------------------------------------------------------------------------------------------------------------------
				   UPDATE ORPC SET "U_BPP_DPFC"=:vd_FecDeps, "U_BPP_DPNM"=:vv_NumDeps WHERE "DocEntry" IN (SELECT T1."U_BPP_DocKeyDest" FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs"=T1."TransId" WHERE T0."DocEntry"=id AND T1."U_BPP_CtaTdoc"='19');
				   UPDATE ODPO SET "U_BPP_DPFC"=:vd_FecDeps, "U_BPP_DPNM"=:vv_NumDeps WHERE "DocEntry" IN (SELECT T1."U_BPP_DocKeyDest" FROM "@BPP_PAYDTRDET" T0 INNER JOIN OJDT T1 ON T0."U_BPP_DEAs"=T1."TransId" WHERE T0."DocEntry"=id AND T1."U_BPP_CtaTdoc"='204');
			END IF;
		
	END IF;
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
END;