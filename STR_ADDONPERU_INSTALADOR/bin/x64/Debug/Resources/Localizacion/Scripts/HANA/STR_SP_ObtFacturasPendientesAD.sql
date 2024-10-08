CREATE PROCEDURE STR_SP_ObtFacturasPendientesAD
(
	IN fIni NVARCHAR(50),
	IN fFin NVARCHAR(50),
	IN method nvarchar(1)
)
AS

BEGIN

	IF :method = 'E' THEN
		
		SELECT T2."CreatedBy"
		FROM JDT1 AS T0
		INNER JOIN OPRC T1 on T0."OcrCode3" = T1."PrcCode"
		INNER JOIN OJDT AS T2 ON T0."TransId" = T2."TransId" 
		INNER JOIN OPCH AS T4 ON T2."CreatedBy" = T4."DocEntry" AND T4."DocType" = 'S' AND T4."U_STR_ADP" = 'N'
		WHERE TO_DATE(T0."RefDate") BETWEEN 
									CASE WHEN :fIni = '' THEN '19000101' ELSE TO_DATE(:fIni) END 
									AND 
									CASE WHEN :fFin = '' then CURRENT_DATE ELSE TO_DATE(:fFin) END;
	
	ELSE
	
		SELECT T2."CreatedBy"
		FROM JDT1 AS T0
		INNER JOIN OPRC T1 ON T0."OcrCode3" = T1."PrcCode"
		INNER JOIN OJDT AS T2 ON T0."TransId" = T2."TransId" 
		INNER JOIN OACT AS T3 ON T3."AcctCode" = T1."U_STR_LC_CDST"
		INNER JOIN OPCH AS T4 ON T2."CreatedBy" = T4."DocEntry" AND T4."DocType" = 'S' AND T4."U_STR_ADP" = 'N'
		WHERE TO_DATE(T0."RefDate") BETWEEN 
									CASE WHEN :fIni = '' THEN '19000101' ELSE TO_DATE(:fIni) END 
									AND 
									CASE WHEN :fFin = '' then CURRENT_DATE ELSE TO_DATE(:fFin) END;
		
	END IF;

END;