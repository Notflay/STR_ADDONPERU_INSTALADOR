CREATE PROCEDURE STR_LT_EST_CUENTAS_CORRIENTES_SOCIO_PROVEEDOR
(
	IN CardCode varchar(20)
)
AS
BEGIN
	SELECT
		T0."DocNum",
		T0."DocEntry",
		IFNULL(T0."NumAtCard",'') AS "NumAtCard",
		TO_VARCHAR(T0."DocDate", 'dd/mm/yyyy') AS "DocDate",
		TO_VARCHAR(T0."TaxDate", 'dd/mm/yyyy') AS "TaxDate",
		T0."DocCur",
		T0."DocRate",
		Case when T0."DocTotalFC" = 0 then T0."DocTotal" - (case when T1."U_Detra" like 'Y' then T2."InsTotal" else 0 end)  
		else T0."DocTotalFC" - (case when T1."U_Detra" like 'Y' then T2."InsTotalFC" else 0 end) 
		end AS "DocTotal",
		T0."DocTotal" - (case when T1."U_Detra" like 'Y' then T2."InsTotal" else 0 end) AS "MontoLocal",
		Case when T0."DocTotalFC" = 0 
			then T0."DocTotal" - (case when T1."U_Detra" like 'Y' then T2."InsTotal" else 0 end) - T0."PaidToDate" 
			else T0."DocTotalFC" - (case when T1."U_Detra" like 'Y' 
			then T2."InsTotalFC" else 0 end) - T0."PaidFC" end  AS "Saldo",
			Case when T2."InsTotalFC" is null then T2."InsTotal" else T2."InsTotalFC" end  AS "Detrac",
			Case when IFNULL(T0."DocTotalFC", 0.00) = 0.00 then T0."WTSum" else T0."WTSumFC" end  AS "Retenc",
			Case T0."DocSubType" 
				when '--' 
					then 'FA' 
				when 'DN' then 'ND' 
			 end AS "TipoDoc",
			0 AS "Line_ID"
	FROM OPCH T0 INNER JOIN OCTG T1 ON T0."GroupNum" = T1."GroupNum" LEFT JOIN PCH6 T2 
	ON T0."DocEntry" = T2."DocEntry" AND T2."InstlmntID" = T1."U_NPlzoDet" where T0."DocStatus" = 'O' AND T0."CardCode" = :CardCode 

	UNION

	SELECT 
		T0."DocNum",
		T0."DocEntry",
		IFNULL(T0."NumAtCard", '') AS "NumAtCard",
		TO_VARCHAR(T0."DocDate", 'dd/mm/yyyy')  AS "DocDate",
		TO_VARCHAR(T0."TaxDate", 'dd/mm/yyyy') AS "TaxDate",
		T0."DocCur",
		T0."DocRate",
		CASE 
			WHEN T0."DocTotalFC"=0 THEN T0."DocTotal" - (CASE WHEN T1."U_Detra" LIKE 'Y' THEN T2."InsTotal" ELSE 0 END)  
			ELSE T0."DocTotalFC" - (CASE WHEN T1."U_Detra" LIKE 'Y' THEN T2."InsTotalFC" ELSE 0 END) 
			END AS "DocTotal",
		T0."DocTotal" - (CASE WHEN T1."U_Detra" LIKE 'Y' THEN T2."InsTotal" ELSE 0 END) AS "MontoLocal",
		CASE WHEN T0."DocTotalFC" = 0 
			THEN T0."DocTotal" - (CASE WHEN T1."U_Detra" LIKE 'Y' THEN T2."InsTotal" ELSE 0 END) - T0."PaidToDate" 
			ELSE T0."DocTotalFC" - (CASE WHEN T1."U_Detra" LIKE 'Y' 
			THEN T2."InsTotalFC" ELSE 0 END) - T0."PaidFC" end AS "Saldo",
			CASE WHEN T2."InsTotalFC" IS NULL THEN T2."InsTotal" ELSE T2."InsTotalFC" END AS "Detrac",
			CASE WHEN IFNULL(T0."DocTotalFC", 0.00) = 0.00 THEN T0."WTSum" ELSE T0."WTSumFC" END AS "Retenc",
			CASE T0."DocSubType" 
				WHEN '--' 
					THEN 'AN' 
				WHEN 'DN' THEN 'ND' 
			 END "TipoDoc",
			0 AS "Line_ID" 
	FROM ODPO T0 inner join OCTG T1 ON T0."GroupNum" = T1."GroupNum" LEFT JOIN PCH6 T2 
	ON T0."DocEntry" = T2."DocEntry" and T2."InstlmntID" = T1."U_NPlzoDet" WHERE T0."DocStatus" = 'O' and T0."CardCode" = :CardCode 
	
	UNION  
	
	SELECT 
		T0."DocNum",
		T0."DocEntry",
		T0."NumAtCard",
		TO_VARCHAR(T0."DocDate", 'dd/mm/yyyy') AS "DocDate",
		TO_VARCHAR(T0."TaxDate", 'dd/mm/yyyy') AS "TaxDate",
		T0."DocCur",
		T0."DocRate",
		CASE 
			WHEN T0."DocTotalFC"=0 THEN -1 * T0."DocTotal" 
			ELSE -1 * T0."DocTotalFC" 
		END  AS "DocTotal",
		-1 * T0."DocTotal" AS "MontoLocal",
		CASE
			WHEN T0."DocTotalFC" = 0 THEN -1 * T0."DocTotal" + 1 * T0."PaidToDate" 
			ELSE -1 * T0."DocTotalFC" + 1 * T0."PaidFC" END AS "Saldo",
		 0 AS "Detrac",
		 0 AS "Retenc",
		'NC',
		0 AS "Line_ID" 
	FROM ORPC T0 WHERE T0."DocStatus" = 'O' AND T0."CardCode" = :CardCode 

	UNION 
	
	SELECT 
		T1."Series",
		T0."TransId",
		T1."Ref2",
		TO_VARCHAR(T1."RefDate", 'dd/mm/yyyy') AS "DocDate",
		TO_VARCHAR(T1."TaxDate", 'dd/mm/yyyy') AS "TaxDate",
		CASE IFNULL(T1."TransCurr",'')
			WHEN '' THEN 'SOL'
			ELSE T1."TransCurr"
		 END AS "TransCurr",
		"TransRate",
		CASE 
			WHEN T1."TransCurr" = 'USD' THEN T0."FCCredit" - T0."FCDebit"
			ELSE T0."Credit" - T0."Debit"
		 END AS "DocTotal",
		CASE WHEN T1."TransCurr" = 'USD' THEN T0."BalFcCred" - T0."BalFcDeb"
			ELSE T0."BalDueCred" - T0."BalDueDeb"
		 END  AS "MontoLocal",
		 CASE WHEN T1."TransCurr" = 'USD' THEN -1 * (T0."BalFcDeb" - t0."BalFcCred")
			ELSE -1*(T0."BalDueDeb" - T0."BalDueCred")
		 END AS "Saldo",	
		 0 AS "Detrac",	
		 0 AS "Retenc",
		 'AS',
		 T0."Line_ID"	
	FROM JDT1 T0 INNER JOIN OJDT T1 on  T0."TransId" = T1."TransId"
	INNER JOIN OCRD T2 ON T2."CardCode" = T0."ShortName" AND T0."TransType" = 30 AND T0."ShortName" = :CardCode
	AND  T0."Closed" = ('N') AND  (T0."BalDueCred" <> (0)  OR  T0."BalDueDeb" <> (0) ) AND  ((T0."SourceLine" <> (-14)  AND  T0."SourceLine" <> (-6) ) 
	OR  T0."SourceLine" IS NULL  ) AND  (T0."TransType" <> ('-2')  OR  T1."DataSource" <> ('T') ) AND T0."Ref2" NOT LIKE 'LET%';

END;