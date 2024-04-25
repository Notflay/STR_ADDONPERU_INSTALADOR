CREATE PROCEDURE STR_SP_LT_GESTION_DE_LETRAS_CLIENTES
(
	IN p_CodSN	NVARCHAR(20),
	IN p_EstLet	NVARCHAR(5) 
)
AS
BEGIN
	SELECT
		'N' AS "Sel",
		T0."TransId" AS "NumInt",
		T1."Ref2" AS "NumLetra",
		T2."TaxDate" AS "FecEmi",
		T0."DueDate" AS "FecVen",
		T1."U_LET_MON" AS "Moneda",
		T0."Line_ID" AS "LineaAs",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN 1 ELSE (SELECT "Rate" FROM "ORTT" WHERE "Currency" = T1."U_LET_MON" AND DAYS_BETWEEN(T1."RefDate","RateDate") = 0) END AS "TC",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "Debit" ELSE "FCDebit" END "Importe",
		CASE WHEN T7."MainCurncy" = T1."U_LET_MON" THEN "BalDueDeb" ELSE "BalFcDeb" END "Saldo",
		
		IFNULL((SELECT "U_MntPrc" FROM "@ST_LT_ELLETRAS" WHERE "U_NumAsi" = T1."TransId" AND (IFNULL("U_NumAsi",0)<>0)),
		IFNULL((SELECT "U_MntPrc" FROM "@ST_LT_RENEMI" WHERE "U_nroInt" = T1."TransId"),
		(SELECT "U_MntPrc" FROM "@ST_LT_DEPDET" WHERE "U_nroIntDe" = T1."TransId"))) AS "Percepcion",
		(SELECT "U_numUni" FROM "@ST_LT_DEPDET" WHERE "U_nroIntDe" = T0."TransId") AS "NumUni",
		IFNULL((SELECT "BankDiscou" FROM "@ST_LT_DEPLET" TX INNER JOIN "@ST_LT_DEPDET" TX1 ON TX."DocEntry" = TX1."DocEntry" INNER JOIN "DSC1" TX2 ON TX2."AbsEntry" = TX."U_ctaBan" WHERE TX1."U_nroIntDe" = T0."TransId"),T1."U_DEP_CR") AS "CtaResp",
		IFNULL((SELECT Tx2."GLAccount" FROM "@ST_LT_DEPLET" TX INNER JOIN "@ST_LT_DEPDET" TX1 on TX."DocEntry" = TX1."DocEntry" INNER JOIN "DSC1" TX2 on TX2."AbsEntry" = TX."U_ctaBan" WHERE TX1."U_nroIntDe" =  T0."TransId"), T1."U_DEP_CB") AS "CtaBan"
	FROM "JDT1" T0
	INNER JOIN "OJDT" T1 ON T0."TransId" = T1."TransId"
	LEFT  JOIN "OJDT" T2 ON T2."TransId" = T1."TransId" AND T2."U_LET_EST" = '002',
	"OADM" T7
	WHERE (T0."DebCred" = 'D' AND T0."TransType" = 30 OR T0."BatchNum" > 0)
	AND (T0."ShortName" = :p_CodSN)
	AND (T0."Closed" = 'N')
	AND (T0."BalDueCred" <> 0  OR  T0."BalDueDeb" <> 0)
	AND ((T0."SourceLine" <> -14  AND  T0."SourceLine" <> -6) OR T0."SourceLine" IS NULL)
	AND (T0."TransType" <> -2  OR  T1."DataSource" <> '-T')
	AND (T1."Ref2" LIKE 'LET%')
	AND (T1."U_LET_EST" = :p_EstLet);

END;