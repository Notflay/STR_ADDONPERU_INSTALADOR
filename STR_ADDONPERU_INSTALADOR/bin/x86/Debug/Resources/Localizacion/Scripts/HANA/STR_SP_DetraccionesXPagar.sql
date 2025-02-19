﻿CREATE PROCEDURE STR_SP_DetraccionesXPagar
(
	IN ProvD nvarchar(50),
	IN ProvH nvarchar(50),
	IN FcCntD nvarchar(50),
	IN FcCntH nvarchar(50),
	IN FcVncD nvarchar(50),
	IN FcVncH nvarchar(50),
	IN Options nvarchar(50),
	IN CodSuc nvarchar(50)
)
AS

v_sql nvarchar(2000);

BEGIN


IF Options <>'O2' THEN
	IF IFNULL(:ProvD, '')<> '' AND IFNULL(:ProvH, '')<> '' THEN
	
		SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota Débito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Crédito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  

/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
		  
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 AND T1."ShortName" BETWEEN :ProvD AND :ProvH 
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
		
	END IF;
	
-------

	IF IFNULL(:FcCntD, '')<>'' AND IFNULL(:FcCntH, NULL)<>'' THEN -- and isnull(@FcCntH, NULL)='01-01-1900'
	
	SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota Débito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Crédito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  
	/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
	*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
		  
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 AND T0."RefDate" BETWEEN :FcCntD AND :FcCntH  --T0."RefDate" >= CAST(CAST(:FcCntD AS DATE) AS nvarchar(10))
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  	
	END IF;
	
-------
	
	IF IFNULL(:FcCntD, '')<>'' THEN -- and isnull(@FcCntH, NULL)='01-01-1900'
	
	SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota Débito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Crédito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  
	/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
	*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
		  
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 AND T0."RefDate" >= CAST(CAST(:FcCntD AS DATE) AS nvarchar(10))
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  	
	END IF;
	
----------
	
	IF IFNULL(:FcCntH, NULL)<>'' THEN-- and isnull(@FcCntD, NULL)='01-01-1900'
		
	  SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota Débito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Crédito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  
/*

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
*/
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",

/*		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 and T0."RefDate"<= CAST(CAST(:FcCntH AS DATE) AS nvarchar(10))
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  
	END IF;
	
----------
	
	IF IFNULL(:FcVncD, NULL)<>'' THEN-- and isnull(@FcVncH, NULL)='01-01-1900'
		
		SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota D�bito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Cr�dito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 AND T0."DueDate">= CAST(CAST(:FcVncD AS DATE) AS nvarchar(10))
   	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  
	END IF;
	
--------------
	
	IF IFNULL(:FcVncH, NULL)<>'' THEN-- and isnull(@FcVncD, NULL)='01-01-1900'

	SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota D�bito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Cr�dito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
/*		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/

		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0 AND T0."DueDate"<= CAST(CAST(:FcVncH AS DATE) AS nvarchar(10))
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  
	END IF;
	
	
	IF :ProvD= '' AND :ProvH= '' AND FcCntD='' AND FcCntH='' AND FcVncD='' AND FcVncH ='' THEN
	
	SELECT 
		  T2."CardCode" || '-' || T2."CardName" AS "Proveedor",
		  T2."CardCode" AS "Codigo_SN",
		  T2."CardName" AS "Razon_Social",
		  'Y' AS "Seleccion",
		  T0."TransId" AS "Cod_Transaccion",  
		  T1."Line_ID" as "Line_ID", 
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		CASE T0."U_BPP_SubTDoc" 
		  			WHEN '5' THEN 
		  				'Nota Débito' 
		  			WHEN '0' THEN 
		  				'Factura' 
		  		END 
		  	WHEN '19' THEN 'Nota Crédito' 
		  END AS "Tipo_Doc",
		  
		  T0."U_BPP_CtaTdoc" AS "Cod_Objeto",
		  T0."Ref2" AS "NumeroDoc",
		  T0."TaxDate" AS "Fecha de Documento",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdBn" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN (SELECT "U_BPP_CdBn" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Bien",
		  
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '18' THEN 
		  		(SELECT "U_BPP_CdOp" FROM OPCH WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  	WHEN '19' THEN 
		  		(SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."U_BPP_DocKeyDest") 
		  END AS "Cod_Operacion",
		  --CASE T0.U_BPP_CtaTdoc WHEN ''18'' THEN (SELECT (BaseAmnt + VatSum) FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest) WHEN ''19'' THEN (SELECT (BaseAmnt + VatSum) FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest) END  as ''Total_Doc_Soles'',
		
		  (SELECT "WTCode" || '-' || "WTName" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Detraccion",
		  (SELECT "WTCode" FROM OWHT WHERE "WTCode" = T0."Ref3") AS "Cod_Detraccion",
		  
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."Debit" + T1."Credit") 
		  ELSE 
		  	T1."Debit" + T1."Credit"
		  END AS "Imp_Detraccion",
*/
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN 
		  		-1 * (T1."BalDueDeb" + T1."BalDueCred") 
		  ELSE 
		  	T1."BalDueDeb" + T1."BalDueCred"
		  END AS "Imp_Detraccion",
/*
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."Debit" + T1."Credit",0) 
		  ELSE 
		  	ROUND(T1."Debit" + T1."Credit",0)
		  END AS "Imp_Detraccion2", 
*/
		  CASE T0."U_BPP_CtaTdoc" 
		  	WHEN '19' THEN
		  		-1 * ROUND(T1."BalDueDeb" + T1."BalDueCred",0) 
		  ELSE 
		  	ROUND(T1."BalDueDeb" + T1."BalDueCred",0)
		  END AS "Imp_Detraccion2", 
		  '                    ' AS "N de Constancia"
	  FROM OJDT T0 
	  INNER JOIN JDT1 T1 ON T0."TransId" = T1."TransId" 
	  INNER JOIN OCRD T2 ON T1."ShortName" = T2."CardCode"
	  
	  LEFT OUTER JOIN OPCH T3 ON T0."U_BPP_DocKeyDest" = T3."DocEntry"
	  LEFT OUTER JOIN ORPC T4 ON T0."U_BPP_DocKeyDest" = T4."DocEntry"
	  LEFT OUTER JOIN OCRD T5 ON T1."ShortName" = T5."CardCode"
	  
	  WHERE
	  	T0."TransCode" = 'DTR'   AND 
	  	CASE T0."U_BPP_CtaTdoc" 
	  		WHEN '18' THEN 
	  			T3."U_BPP_MDSD"
	  		WHEN '19' THEN
	  			T4."U_BPP_MDSD"
	  	ELSE 
	  		'' 
	  	END <> 'ANL'
		AND IFNULL(T1."BPLId", 99) = TO_INTEGER(CASE WHEN :CodSuc = '' THEN '99' ELSE :CodSuc  END)
	  	AND EXISTS(select 'E' FROM OCRD WHERE "CardCode" = T1."ShortName")  
	  AND (T1."BalDueDeb" + T1."BalDueCred")> 0.0
	  AND T0."TransId" NOT IN(SELECT "U_BPP_DEAs" FROM "@BPP_PAYDTRDET" TDet INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" WHERE TDet."U_BPP_DEAs" = T0."TransId" AND TCab."Status" = 'O')
	  ORDER BY T2."CardCode"; 
	  
	END IF;
	
	 -- ========================================================================================================
		-- Opcion configurable Nro 2
	-- ========================================================================================================
	
	ELSE
	
	
		IF IFNULL(:ProvD, '')<> '' AND IFNULL(:ProvH, '')<> '' THEN
	
			SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			--T0."U_STR_TasaDTR" IS NOT NULL --OR 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."CardCode" BETWEEN :ProvD AND :ProvH 
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
			 
			 ORDER BY T0."CardCode";
			
		END IF;
			
		-------

		IF IFNULL(:FcCntD, '')<>'' AND IFNULL(:FcCntH, '')<> '' THEN -- and isnull(@FcCntH, NULL)='01-01-1900'
		
			SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."DocDate" BETWEEN :FcCntD AND :FcCntH  --T0."DocDate" >= CAST(CAST(:FcCntD AS DATE) AS nvarchar(10))
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
			 
			 ORDER BY T0."CardCode";

		END IF;
			
		-------
	
		IF IFNULL(:FcCntD, '')<>'' THEN -- and isnull(@FcCntH, NULL)='01-01-1900'
		
			SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."DocDate" >= CAST(CAST(:FcCntD AS DATE) AS nvarchar(10))
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
			 
			 ORDER BY T0."CardCode";

		END IF;
			
		----------
			
		IF IFNULL(:FcCntH, NULL)<>'' THEN-- and isnull(@FcCntD, NULL)='01-01-1900'
			
			SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--INNER JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--INNER JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."DocDate"<= CAST(CAST(:FcCntH AS DATE) AS nvarchar(10))
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
			 
			 ORDER BY T0."CardCode";
		  
		END IF;
			
		----------
			
		IF IFNULL(:FcVncD, NULL)<>'' THEN-- and isnull(@FcVncH, NULL)='01-01-1900'
			
			SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."DocDueDate">= CAST(CAST(:FcVncD AS DATE) AS nvarchar(10))
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
			 
			 ORDER BY T0."CardCode";

		END IF;
			
		--------------
			
		IF IFNULL(:FcVncH, NULL)<>'' THEN-- and isnull(@FcVncD, NULL)='01-01-1900'

				SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND T0."DocDueDate"<= CAST(CAST(:FcVncH AS DATE) AS nvarchar(10))
			AND T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
		
			  ORDER BY T0."CardCode";
		  
		END IF;
			
			
		IF :ProvD= '' AND :ProvH= '' AND FcCntD='' AND FcCntH='' AND FcVncD='' AND FcVncH ='' THEN
			
				SELECT T0."CardCode" || '-' || T0."CardName" AS "Proveedor",
				   T0."CardCode" AS "Codigo_SN",
				   T0."CardName" AS "Razon_Social",
				   'N' AS "Seleccion",
				   T0."DocEntry" AS "Cod_Transaccion",
				   '' AS "Line_ID",
				   
				   case T0."ObjType"
						when '18' then 'Factura'
						when '19' then 'Nota Crédito' 
				   end as "Tipo_Doc",
				   
				   T0."ObjType" AS "Cod_Objeto",
				   T0."NumAtCard" AS "NumeroDoc",
				   T0."TaxDate" AS "Fecha de Documento",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn"
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Bien",
				   
				   case T0."ObjType"
						when 18 then T0."U_BPP_CdBn" 
						when 19 then (SELECT "U_BPP_CdOp" FROM ORPC WHERE "DocEntry" = T0."DocEntry") 
				   end AS "Cod_Operacion",
				   
				  (concat('Detracción ', CONCAT( Round(T0."U_STR_TasaDTR",2) , ' %')) ) AS "Detraccion",
				  ('') AS "Cod_Detraccion",
				  
				  -- (T0."DocTotal"-T0."VatSum") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  (T0."DocTotal") * (T0."U_STR_TasaDTR" / 100) AS "Imp_Detraccion",
				  
				  ROUND((T0."DocTotal") * (T0."U_STR_TasaDTR" / 100))  AS "Imp_Detraccion2",		  	  
				  '                    ' AS "N de Constancia"
				   
			FROM OPCH AS T0
			--LEFT JOIN VPM2 AS T1 ON T0."DocEntry" = T1."DocEntry" AND (T1."InvType" = 18 OR T1."InvType" = 5)
			--LEFT JOIN OVPM AS T2 ON T1."DocNum" = T2."DocEntry"
			
			WHERE 
			T0."U_STR_TasaDTR" > 0 
			AND (IFNULL("U_STR_DetraccionPago",'')='' OR "U_STR_DetraccionPago"='N')
			AND	T0."DocEntry" NOT IN(SELECT "U_BPP_DEAs" 
									 FROM "@BPP_PAYDTRDET" TDet 
									 INNER JOIN "@BPP_PAYDTR" TCab ON TDet."DocEntry" = TCab."DocEntry" 
									 WHERE TDet."U_BPP_DEAs" = T0."DocEntry" AND TCab."Status" = 'O')
		
			  ORDER BY T0."CardCode"; 
		  
		END IF;
	
	END IF;
	
END;