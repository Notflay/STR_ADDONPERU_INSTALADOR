CREATE PROCEDURE STR_SP_LOC_ListarSolicitudesEntregaRendir
(
	MND VARCHAR(10),
	USR VARCHAR(20)
)
AS
BEGIN 
SELECT T2."CdgEAR",
	   T2."Requester",
	   T2."ReqName",
	   T2."AcctCode",
	   T2."FormatCode",
	   T2."AcctName",
	   SUM(T2."U_CE_IMSL"),
	   ' ' AS "Dscription",
	   T2."DocEntry" ,
	   T2."DocNum",
	   T2."Project",
	   T2."OcrCode2",--unidad negocio
	   T2."OcrCode3",  --cuenta destino
	   T2."OcrCode4",  --gerencia
	   T2."OcrCode5"  --area operativa
FROM (
SELECT

	'EAR'||T1."Requester" AS "CdgEAR", 
	T1."Requester",
	T1."ReqName",
	T4."AcctCode",
	T4."FormatCode",
	T4."AcctName",
	T0."U_CE_IMSL",
	T0."Dscription",
	T1."DocEntry",
	T1."DocNum",
	T0."Project",
	T0."OcrCode2",
	T0."OcrCode3",
	T0."OcrCode4",
	T0."OcrCode5"
FROM  PRQ1 T0  INNER  JOIN OPRQ T1  ON  T1."DocEntry" = T0."DocEntry" 
LEFT OUTER JOIN OCRD T2 ON T0."LineVendor" = T2."CardCode" 
LEFT OUTER JOIN CRD3 T3 ON T2."CardCode" = T3."CardCode"
LEFT OUTER JOIN OACT T4 ON T3."AcctCode" = T4."AcctCode"
LEFT OUTER JOIN OUSR T5 ON T1."UserSign" = T5."USERID"
LEFT OUTER JOIN "@STR_HEMEAR" T6 ON T1."Requester" = "U_empID"
WHERE T0."LineStatus" = 'O' AND T1."DocStatus" = 'O'
AND T1."ReqType" = '171' AND T6."U_ER_SAPR" = 'Y' AND T1."U_CE_MNDA" = :MND AND T6."U_ER_CDUS" = :USR)T2
GROUP BY T2."DocEntry",T2."CdgEAR",T2."Requester",T2."ReqName",T2."AcctCode",T2."DocNum",T2."FormatCode",T2."AcctName", T2."Project",T2."OcrCode2",	T2."OcrCode3",	T2."OcrCode4",	T2."OcrCode5";--,T2."Dscription";

END;