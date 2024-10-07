CREATE PROCEDURE STR_SP_PagoMasivoDetraccionesDetalle
(
	IN NroLote INTEGER,
	IN Fecha DATE
)
AS
BEGIN
	Temp=(
		SELECT 
			T3."DocEntry",
			LPAD('',35,' ') AS "CardName",
			'6'AS "TProv",
			T1."LicTradNum",
			T1."CardCode",
			T3."DocNum" AS "U_Nrolote",
			T2."U_BPP_CdBn",
			REPLACE(T4."Account",'-','') AS "Account",
			RTRIM(CAST(TO_INTEGER(ROUND(T0."U_BPP_SdAs",0)) AS CHAR(5))) || '' || '00'AS "ImportCargar",
			T2."U_BPP_CdOp", -- '01'
			(TO_VARCHAR(YEAR(T2."TaxDate")) || '' || LPAD('',2 - LENGTH(MONTH(T2."TaxDate")),'0') || '' || TO_VARCHAR(MONTH(T2."TaxDate"))) AS "Perido",
			T2."U_BPP_MDTD" AS  "Tipo",
			TO_VARCHAR(TO_VARCHAR(LPAD('',4 - LENGTH(T2."U_BPP_MDSD"),'0')) || T2."U_BPP_MDSD") AS "Serie",
			TO_VARCHAR(TO_VARCHAR(LPAD('',8 - LENGTH(T2."U_BPP_MDCD"),'0')) || TO_VARCHAR(RIGHT(T2."U_BPP_MDCD",8))) AS "Correlativo",
			T4."BankCode",
			T4."Branch"
		FROM "@BPP_PAYDTRDET" T0
		INNER JOIN "@BPP_PAYDTR" T3 ON T0."DocEntry" = T3."DocEntry"
		INNER JOIN OCRD T1 ON T0."U_BPP_CgPv" = T1."CardCode"
		INNER JOIN OCRB T4 ON T4."CardCode" = T1."CardCode"
		INNER JOIN OPCH T2 ON T2."U_BPP_AstDetrac" = T0."U_BPP_DEAs"
		WHERE (REPLACE(T4."BankCode",'0','') = '18' OR T4."MandateID" = '18') AND
		 T3."DocNum" = :NroLote
		AND T3."CreateDate" = :Fecha
		
		UNION ALL 
		
		SELECT 
			T3."DocEntry",
			LPAD('',35,' ') AS "CardName",
			'6'AS "TProv",
			T1."LicTradNum",
			T1."CardCode",
			T3."DocNum" AS "U_Nrolote",
			T2."U_BPP_CdBn",
			REPLACE(T4."Account",'-','') AS "Account",
			RTRIM(CAST(TO_INTEGER(ROUND(T0."U_BPP_SdAs",0)) AS CHAR(5))) || '' || '00'AS "ImportCargar",
			T2."U_BPP_CdOp", -- '01'
			(TO_VARCHAR(YEAR(T2."TaxDate")) || '' || LPAD('',2 - LENGTH(MONTH(T2."TaxDate")),'0') || '' || TO_VARCHAR(MONTH(T2."TaxDate"))) AS "Perido",
			T2."U_BPP_MDTD" AS  "Tipo",
			TO_VARCHAR(TO_VARCHAR(LPAD('',4 - LENGTH(T2."U_BPP_MDSD"),'0')) || T2."U_BPP_MDSD") AS "Serie",
			TO_VARCHAR(TO_VARCHAR(LPAD('',8 - LENGTH(T2."U_BPP_MDCD"),'0')) || TO_VARCHAR(RIGHT(T2."U_BPP_MDCD",8))) AS "Correlativo",
			T4."BankCode",
			T4."Branch"
		FROM "@BPP_PAYDTRDET" T0
		INNER JOIN "@BPP_PAYDTR" T3 ON T0."DocEntry" = T3."DocEntry"
		INNER JOIN OCRD T1 ON T0."U_BPP_CgPv" = T1."CardCode"
		INNER JOIN OCRB T4 ON T4."CardCode" = T1."CardCode"
		INNER JOIN ODPO T2 ON T2."U_BPP_AstDetrac" = T0."U_BPP_DEAs"
		WHERE (REPLACE(T4."BankCode",'0','') = '18' OR T4."MandateID" = '18') AND
		 T3."DocNum" = :NroLote
		AND T3."CreateDate" = :Fecha
		
		UNION ALL 
		
		SELECT 
			T3."DocEntry",
			LPAD('',35,' ') AS "CardName",
			'6'AS "TProv",
			T1."LicTradNum",
			T1."CardCode",
			T3."DocNum" AS "U_Nrolote",
			T2."U_BPP_CdBn",
			REPLACE(T4."Account",'-','') AS "Account",
			RTRIM(CAST(TO_INTEGER(ROUND(T0."U_BPP_SdAs",0)) AS CHAR(5))) || '' || '00'AS "ImportCargar",
			T2."U_BPP_CdOp", -- '01'
			(TO_VARCHAR(YEAR(T2."TaxDate")) || '' || LPAD('',2 - LENGTH(MONTH(T2."TaxDate")),'0') || '' || TO_VARCHAR(MONTH(T2."TaxDate"))) AS "Perido",
			T2."U_BPP_MDTD" AS  "Tipo",
			TO_VARCHAR(TO_VARCHAR(LPAD('',4 - LENGTH(T2."U_BPP_MDSD"),'0')) || T2."U_BPP_MDSD") AS "Serie",
			TO_VARCHAR(TO_VARCHAR(LPAD('',8 - LENGTH(T2."U_BPP_MDCD"),'0')) || TO_VARCHAR(RIGHT(T2."U_BPP_MDCD",8))) AS "Correlativo",
			T4."BankCode",
			T4."Branch"
		FROM "@BPP_PAYDTRDET" T0
		INNER JOIN "@BPP_PAYDTR" T3 ON T0."DocEntry" = T3."DocEntry"
		INNER JOIN OCRD T1 ON T0."U_BPP_CgPv" = T1."CardCode"
		INNER JOIN OCRB T4 ON T4."CardCode" = T1."CardCode"
		INNER JOIN ORPC T2 ON T2."U_BPP_AstDetrac" = T0."U_BPP_DEAs"
		WHERE (REPLACE(T4."BankCode",'0','') = '18' OR T4."MandateID" = '18') AND
		 T3."DocNum" = :NroLote
		AND T3."CreateDate" = :Fecha
		
		ORDER BY T1."CardCode");
		
		SELECT 
		IFNULL("DocEntry",'0')||
		IFNULL("CardName",'')||
		IFNULL("TProv",'')||
		IFNULL("LicTradNum",'')||
		IFNULL("CardCode",'')||
		IFNULL("U_Nrolote",'0')||
		IFNULL("U_BPP_CdBn",'')||
		IFNULL("Account",'')||
		IFNULL("ImportCargar",'')||
		IFNULL("U_BPP_CdOp",'')||
		IFNULL("Perido",'')||
		IFNULL("Tipo",'')||
		IFNULL("Serie",'')||
		IFNULL("Correlativo",'')||
		IFNULL("BankCode",'')||
		IFNULL("Branch",'') AS "DATA"
		 FROM :TEMP;
END;