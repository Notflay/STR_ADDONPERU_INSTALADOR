CREATE PROCEDURE STR_SOLICITUD_DINERO_EAR_RP
AS
BEGIN
	SELECT  
	REPLACE (T0."DocNum",',','') AS "DocNum",
	T0."PIndicator"   AS "Year",
	T0."ReqName" AS "Nombre",
	T1."ExtEmpNo"||' - '||T1."U_CE_CEAR" AS "CodigoEmp",
	T1."jobTitle",
	T2."Remarks" AS "Area",
	T1."CostCenter" AS "CRP",
	--(T4."SEDE"||'-'||T4."TIPO"||'-'||LPAD(T4."NUMEROEAR",8,0)) AS "NroViatico",
	T0."Comments" AS "Motivo",
	--T0."U_DEPARTAMENTO"||'-'||T0."U_PROVINCIA"||'-'||T0."U_DISTRITO" AS "Lugar",
	TO_DATE(T0."TaxDate") AS "Fec_Ini",
	TO_DATE(T0."ReqDate")  AS "Fec_Fin",
	(SELECT CAST(MAX("Quantity")AS INT) FROM PRQ1 TX WHERE TX."DocEntry"=T0."DocEntry") AS "DiasCabecera",
	T3."Dscription" AS "Concepto",
	T3."Price" AS "Escala",
	CAST(T3."Quantity" AS INT) AS "DiasDetalle",
	T3."LineTotal" AS "SubTotal",
	T0."DocTotal" AS "TotalPres",
	STR_FN_FE_ObtMontoLetras(T0."DocTotal",T0."DocCur")AS "ImporteLetras",
	T1."ExtEmpNo",
	T3."OcrCode2"
----------------PIE DE PAGINA------------------
	
/*
SELECT MAX(X3."U_STR_CL_FIRMA") FROM OPRQ X0 INNER JOIN STR_WEB_APR_SR X1 ON X1."STR_ID_SR" = X0."U_STR_WEB_COD" 
INNER JOIN OHEM X2 ON X2."empID" = X1."STR_USUARIOAPROBADORID" INNER JOIN OUSR X3 ON X2."userId" = X3."USERID"  WHERE X0."U_STR_WEB_COD" = T0."U_STR_WEB_COD"
*/

			
---------------FIN PIE DE PAGINA----------------
	 FROM OPRQ T0 
	 INNER JOIN PRQ1 T3 ON T3."DocEntry"=T0."DocEntry"
	 INNER JOIN OHEM T1 ON T1."empID"=T0."Requester"
	 INNER JOIN OUDP T2 ON T0."Department"=T2."Code"
	 --INNER JOIN OPRQ_NUMEAR T4 ON T0."DocEntry"=T4."DOCENTRY"
	 WHERE T0."ReqType" = '171' --AND T0."Series"='214' 
	ORDER BY T0."TaxDate" DESC
;
END