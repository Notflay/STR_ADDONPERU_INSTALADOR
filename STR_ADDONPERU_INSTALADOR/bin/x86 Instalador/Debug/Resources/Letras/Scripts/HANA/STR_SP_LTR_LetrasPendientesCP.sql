CREATE PROCEDURE STR_SP_LTR_LetrasPendientesCP
(

	IN p_Pv_ShortName NVARCHAR(20),
	IN p_Pv_u_Let_Est NVARCHAR(3)
)
AS
BEGIN 
	SELECT 
		'N' AS  "Sel",
		T0."TransId" AS "NumInt",
		T1."Ref2" AS "NumLetra",
		case T1."U_LET_EST" WHEN '009' THEN 'Retencion' ELSE T1."Ref1" END AS "REF1",
		T0."TaxDate" AS "FecEmi",
		T0."DueDate" AS "FecVen",
		T1."U_LET_MON" AS "Moneda",
		T0."Line_ID" AS "LineaAs",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN 1 ELSE (SELECT "Rate" FROM "ORTT" WHERE "Currency" = T1."U_LET_MON" AND DAYS_BETWEEN(T1."RefDate","RateDate") = 0) END "TC",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "Credit" ELSE "SYSCred" END "Importe",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "BalDueCred" ELSE "BalScCred" END "Saldo",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "Credit" ELSE "FCCredit" END "Importe",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "BalDueCred" ELSE "BalFcCred" END "Saldo",
		T1."U_WTRate" AS "Retencion"
	FROM "JDT1" T0
	INNER JOIN "OJDT" T1  ON  T0."TransId" = T1."TransId", "OADM" T7 
	WHERE 
	(T0."DebCred" = 'C' AND T0."TransType" = 30  OR T0."BatchNum" > 0)
	AND T0."ShortName" = :p_Pv_ShortName
	AND T0."Closed" = 'N'
	AND (T0."BalDueCred" <> 0  OR  T0."BalDueDeb" <> 0)
	AND ((T0."SourceLine" <> -14  AND  T0."SourceLine" <> -6 ) OR T0."SourceLine" IS NULL)
	AND (T0."TransType" <> -2  OR  T1."DataSource" <> '-T')
	AND T1."Ref2" LIKE 'LET%'
	AND (T1."U_LET_EST" = :p_Pv_u_Let_Est OR T1.U_LET_EST='009');
END;