CREATE PROCEDURE STR_SP_PagoMasivoDetraccionesCabecera
(
	IN NroLote INTEGER,
	IN Fecha DATE
)
AS
BEGIN
	SELECT 
		T0."DocEntry",
		T1."TaxIdNum",
		T1."CompnyName",
		RIGHT(YEAR(T0."CreateDate"),2) || '' || LPAD('',4 - LENGTH(T0."DocNum"),'0') || '' || TO_VARCHAR(T0."DocNum") AS "U_Nrolote",
		
		LPAD('', 15 - LENGTH
			(SUBSTRING(CAST(SUM(ROUND(T0."U_BPP_TtPg",2)) AS VARCHAR(15)),1,LOCATE(TO_VARCHAR(T0."U_BPP_TtPg"), '.')-1) ||
			 SUBSTRING(TO_VARCHAR(T0."U_BPP_TtPg"),(LOCATE(T0."U_BPP_TtPg", '.') + 1),2) ),'0') 
		  ||(SUBSTRING(CAST(SUM(ROUND(T0."U_BPP_TtPg",2)) AS VARCHAR(15)),1,LOCATE(TO_VARCHAR(T0."U_BPP_TtPg"), '.')-1) ||
			 SUBSTRING(TO_VARCHAR(T0."U_BPP_TtPg"),(LOCATE(T0."U_BPP_TtPg", '.') + 1),2)
		) AS "ImportCargar"
		
	FROM "@BPP_PAYDTR" T0 , "OADM" T1 
	WHERE T0."DocNum" = :NroLote AND T0."CreateDate" = :Fecha
	GROUP BY T0."DocEntry",T0."U_BPP_TtPg", T0."CreateDate",T1."TaxIdNum",T1."CompnyName",T0."DocNum";
END;

