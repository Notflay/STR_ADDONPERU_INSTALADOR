CREATE PROCEDURE SP_BPP_BASE_CONSULTAR_PGM_PROVEEDORES
(
FECHAINI DATE,
FECHAFIN DATE,
CODPROVEEDOR NVARCHAR(20),
MONEDA NVARCHAR(20),
FECHAVINI DATE,
FECHAVFIN DATE,
OUT TABLA "TT_BPP_PAGOS"
)
AS
	
BEGIN
	DECLARE OPTIONS CHAR(2);
	-- VALIDA QUE CLIENTE TIENE OPCIÓN 2 EN CONF DE LOCALI.
	SELECT TOP 1 "U_STR_MCTC" INTO OPTIONS FROM "@STR_LC_CONF";
	-- O2
	
	--SELECT @FECHAINI=F_RefDate,@FECHAFIN=T_RefDate FROM OFPR WHERE AbsEntry = @PERIODO
TABLA = 
	SELECT * FROM (
	SELECT  distinct
		 T3."CardCode" "CodigoProveedor"
		,T3."CardName" "NombreProveedor"
		,T3."DocEntry" "NumeroSAP"
		,T3."DocCur" "Moneda"
		,T3."DocDate" "FechaContabilizacion"
		,T3."TaxDate" "FechaDocumento"
		,T3."DocDueDate" "FechaVencimiento"
		,T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-' ||T3."U_BPP_MDCD" "NumeroDocumento"
		,CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" ELSE  T7."InsTotalFC" END
		ELSE
			CASE WHEN T3."DocCur" = 'SOL' THEN T3."DocTotal" ELSE T3."DocTotalFC" END
		END "ImporteDoc" 
		,
		
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" -   T7."PaidToDate" -  IFNULL(T7."WTSum",0) ELSE T7."InsTotalFC" - T7."PaidFC" -  IFNULL(T7."WTSumFC",0) END 
		ELSE
			( CASE WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum" -  IFNULL(T3."WTSum",0) 
				 WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'USD' THEN  T3."DocTotalFC" - T3."PaidSumFc" -  IFNULL(T3."WTSumFC",0) 
				 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum"  ELSE T3."DocTotalFC" - T3."PaidSumFc" END)
				 END ) - COALESCE((SELECT SUM(N1."GTotal") FROM RPC1 N1 WHERE N1."BaseEntry" = T3."DocEntry"), 0) 
		END
		
		 "MontoPago"
		,
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" -   T7."PaidToDate" -  IFNULL(T7."WTSum",0) ELSE T7."InsTotalFC" - T7."PaidFC" -  IFNULL(T7."WTSumFC",0) END 
		ELSE
			( CASE WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum" -  IFNULL(T3."WTSum",0) 
				 WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'USD' THEN  T3."DocTotalFC" - T3."PaidSumFc" -  IFNULL(T3."WTSumFC",0) 
				 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum"  ELSE T3."DocTotalFC" - T3."PaidSumFc" END)
				 END ) - COALESCE((SELECT SUM(N1."GTotal") FROM RPC1 N1 WHERE N1."BaseEntry" = T3."DocEntry"), 0) 
		END
		 "Saldo"		
		,CASE WHEN "isIns" = 'N' THEN 'Factura' ELSE 'Factura de Reserva' END AS "TipoDocumento"
		,T4."LicTradNum" "RUC"
		,T5."AcctName" "NombreBanco"
		,T5."Account" "CuentaBanco"
		,T5."U_BPP_MONEDA" "MonedaBanco"
		,T3."ObjType" "ObjType"
		,T7."InstlmntID" "NumeroCuota"
		
		,CAST(T7."InstlmntID" AS NVARCHAR(10)) || ' de ' || CAST(T3."Installmnt"AS NVARCHAR(10))  "NombreCuota"
		,
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN LEFT(T8."WTCode",2) = 'DT' THEN 0 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN IFNULL(T7."WTSum",0) ELSE  IFNULL(T7."WTSumFC",0) END ) END
			 -- Si es DTR es 0
		ELSE
			CASE WHEN LEFT(T8."WTCode",2) = 'DT' THEN 0 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN IFNULL(T3."WTSum",0) ELSE  IFNULL(T3."WTSumFC",0) END ) END
			-- Si es DTR es 0
		END
		"ImporteRetencion",
		CASE WHEN :OPTIONS = 'O2' 
			THEN 	
				(CASE WHEN IFNULL( T3."U_STR_TasaDTR",0) = 0 THEN 'No Aplica' 
					ELSE (CASE WHEN IFNULL(T3."U_STR_DetraccionPago",'') ='' OR T3."U_STR_DetraccionPago"='N' THEN 'Pendiente' ELSE 'Pagado' END)
							END)					
			ELSE 
				(CASE WHEN IFNULL( T10."TransCode",'') = '' THEN 'No Aplica' 
					ELSE (CASE WHEN IFNULL(T9."selfInv",'') = '' THEN 'Pendiente' ELSE 'Pagado' END)
							END)
			END	"DetraccionPago" 	
	FROM OPCH T3 
	INNER JOIN OCRD T4 ON T3."CardCode" = T4."CardCode"
	LEFT JOIN OCRB T5 ON T4."BankCode" = T5."BankCode" and T4."DflBankKey" = T5."BankKey" AND T4."DflAccount" = T5."Account"
	AND T4."CardCode" = T5."CardCode" AND T5."U_BPP_MONEDA" = :MONEDA
	
	LEFT JOIN (SELECT DISTINCT T1."U_BPP_NUMSAP" FROM "@BPP_PAGM_DET1" T1
	INNER JOIN  "@BPP_PAGM_CAB" T2 ON  T1."DocEntry" = T2."DocEntry" 
	LEFT JOIN "OPCH" T3 ON T1."U_BPP_NUMSAP" = T3."DocEntry"
	WHERE T2."U_BPP_ESTADO"  in ('Creado','Procesado') and T3."DocStatus" ='C'  ) T6 ON T3."DocEntry" = T6."U_BPP_NUMSAP"
	
	/*
	LEFT JOIN (SELECT DISTINCT T1."U_BPP_NUMSAP" FROM "@BPP_PAGM_DET1" T1
	INNER JOIN  "@BPP_PAGM_CAB" T2 ON  T1."DocEntry" = T2."DocEntry" 
	LEFT JOIN "OPCH" T3 ON T1."U_BPP_NUMSAP" = T3."DocEntry"
	WHERE T2."U_BPP_ESTADO"  = 'Creado') T6 ON T3."DocEntry" = T6."U_BPP_NUMSAP"
	*/
	LEFT JOIN "PCH6" T7 ON T3."DocEntry" = T7."DocEntry"
	LEFT JOIN "PCH5" T8 ON T3."DocEntry" = T8."AbsEntry"
	LEFT JOIN "VPM2" T9 ON T9."DocEntry" = T3."U_BPP_AstDetrac"
	LEFT JOIN "OJDT" T10 ON T10."TransId" = T3."U_BPP_AstDetrac" AND T10."TransCode" = 'DTR'
	LEFT JOIN "OWHT" T11 ON T8."WTCode" = T11."WTCode" 
	--LEFT JOIN "@BPP_PAGM_DET1" T12 ON T12."U_BPP_CODPROV" = T3."CardCode" AND T12."U_BPP_NUMDOC" = T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-' ||T3."U_BPP_MDCD"
	--LEFT JOIN "@BPP_PAGM_CAB" T13 ON T13."DocEntry" = T12."DocEntry"
	WHERE 
		T3."TaxDate" >= CASE WHEN  :FECHAINI='' THEN T3."TaxDate" ELSE :FECHAINI  END 
		AND T3."TaxDate" <= CASE WHEN  :FECHAFIN='' THEN T3."TaxDate" ELSE :FECHAFIN  END 
		AND T3."DocDueDate" >= CASE WHEN  :FECHAVINI='' THEN T3."DocDueDate" ELSE :FECHAVINI  END 
		AND T3."DocDueDate" <= CASE WHEN  :FECHAVFIN='' THEN T3."DocDueDate" ELSE :FECHAVFIN  END 
		AND T3."CardCode" = CASE WHEN  :CODPROVEEDOR='' THEN T3."CardCode" ELSE :CODPROVEEDOR END 
		AND  T3."DocTotal" - T3."PaidSum" != 0
		AND T3."DocCur" = :MONEDA
		AND T3."CANCELED" = 'N'
		AND T3."DocStatus" != 'C'
		--AND IFNULL(T12."DocEntry",0)=0
		--AND IFNULL(T13."U_BPP_ESTADO",'Cancelado') = 'Cancelado'
		AND IFNULL(T6."U_BPP_NUMSAP",0)= 0 
		
	UNION ALL
	
	
	SELECT 
		 T3."CardCode" "CodigoProveedor"
		,T3."CardName" "NombreProveedor"
		,T3."DocEntry" "NumeroSAP"
		,T3."DocCur" "Moneda"
		,T3."DocDate" "FechaContabilizacion"
		,T3."TaxDate" "FechaDocumento"
		,T3."DocDueDate" "FechaVencimiento"
		,T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-' ||T3."U_BPP_MDCD" "NumeroDocumento"
		,CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" ELSE  T7."InsTotalFC" END
		ELSE
			CASE WHEN T3."DocCur" = 'SOL' THEN T3."DocTotal" ELSE T3."DocTotalFC" END
		END "ImporteDoc" 
		,
		
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" -   T7."PaidToDate" -  IFNULL(T7."WTSum",0) ELSE T7."InsTotalFC" - T7."PaidFC" -  IFNULL(T7."WTSumFC",0) END 
		ELSE
			( CASE WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum" -  IFNULL(T3."WTSum",0) 
				 WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'USD' THEN  T3."DocTotalFC" - T3."PaidSumFc" -  IFNULL(T3."WTSumFC",0) 
				 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum"  ELSE T3."DocTotalFC" - T3."PaidSumFc" END)
				 END ) - COALESCE((SELECT SUM(N1."GTotal") FROM RPC1 N1 WHERE N1."BaseEntry" = T3."DocEntry"), 0) 
		END
		
		 "MontoPago"
		,
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN T3."DocCur" = 'SOL' THEN  T7."InsTotal" -   T7."PaidToDate" -  IFNULL(T7."WTSum",0) ELSE T7."InsTotalFC" - T7."PaidFC" -  IFNULL(T7."WTSumFC",0) END 
		ELSE
			( CASE WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum" -  IFNULL(T3."WTSum",0) 
				 WHEN T8."WTCode" like 'R%'  AND T11."Category" = 'P'  AND T3."DocCur" = 'USD' THEN  T3."DocTotalFC" - T3."PaidSumFc" -  IFNULL(T3."WTSumFC",0) 
				 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN  T3."DocTotal" - T3."PaidSum"  ELSE T3."DocTotalFC" - T3."PaidSumFc" END)
				 END ) - COALESCE((SELECT SUM(N1."GTotal") FROM RPC1 N1 WHERE N1."BaseEntry" = T3."DocEntry"), 0) 
		END
		 "Saldo"		
		,'Factura Anticipo' "TipoDocumento"
		,T4."LicTradNum" "RUC"
		,T5."AcctName" "NombreBanco"
		,T5."Account" "CuentaBanco"
		,T5."U_BPP_MONEDA" "MonedaBanco"
		,T3."ObjType" "ObjType"
		,T7."InstlmntID" "NumeroCuota"
		,CAST(T7."InstlmntID" AS NVARCHAR(10)) || ' de ' || CAST(T3."Installmnt"AS NVARCHAR(10))  "NombreCuota"
		,		
		CASE WHEN T3."Installmnt" > 1 THEN
			CASE WHEN LEFT(T8."WTCode",2) = 'DT' THEN 0 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN IFNULL(T7."WTSum",0) ELSE  IFNULL(T7."WTSumFC",0) END ) END
			 -- Si es DTR es 0
		ELSE
			CASE WHEN LEFT(T8."WTCode",2) = 'DT' THEN 0 ELSE (CASE WHEN T3."DocCur" = 'SOL' THEN IFNULL(T3."WTSum",0) ELSE  IFNULL(T3."WTSumFC",0) END ) END
			-- Si es DTR es 0
		END	
		"ImporteRetencion",
		CASE WHEN :OPTIONS = 'O2' 
			THEN 	
				(CASE WHEN IFNULL( T3."U_STR_TasaDTR",0) = 0 THEN 'No Aplica' 
					ELSE (CASE WHEN IFNULL(T3."U_STR_DetraccionPago",'') ='' OR T3."U_STR_DetraccionPago"='N' THEN 'Pendiente' ELSE 'Pagado' END)
							END)					
			ELSE 
				(CASE WHEN IFNULL( T10."TransCode",'') = '' THEN 'No Aplica' 
					ELSE (CASE WHEN IFNULL(T9."selfInv",'') = '' THEN 'Pendiente' ELSE 'Pagado' END)
							END)
			END	"DetraccionPago" 
	FROM ODPO T3 
	INNER JOIN OCRD T4 ON T3."CardCode" = T4."CardCode"
	LEFT JOIN OCRB T5 ON T4."BankCode" = T5."BankCode" and T4."DflBankKey" = T5."BankKey" AND T4."DflAccount" = T5."Account"
	AND T4."CardCode" = T5."CardCode" AND T5."U_BPP_MONEDA" = :MONEDA
	
	LEFT JOIN (SELECT DISTINCT T1."U_BPP_NUMSAP" FROM "@BPP_PAGM_DET1" T1
	INNER JOIN  "@BPP_PAGM_CAB" T2 ON  T1."DocEntry" = T2."DocEntry" 
	WHERE T2."U_BPP_ESTADO"  in ('Creado','Procesado') ) T6 ON T3."DocEntry" = T6."U_BPP_NUMSAP"
	/*
	LEFT JOIN (SELECT DISTINCT T1."U_BPP_NUMSAP" FROM "@BPP_PAGM_DET1" T1
	INNER JOIN  "@BPP_PAGM_CAB" T2 ON  T1."DocEntry" = T2."DocEntry" 
	WHERE T2."U_BPP_ESTADO" = 'Creado') T6 ON T3."DocEntry" = T6."U_BPP_NUMSAP"
	*/
	LEFT JOIN "DPO6" T7 ON T3."DocEntry" = T7."DocEntry"
	LEFT JOIN "DPO5" T8 ON T3."DocEntry" = T8."AbsEntry"
	LEFT JOIN "VPM2" T9 ON T9."DocEntry" = T3."U_BPP_AstDetrac"
	LEFT JOIN "OJDT" T10 ON T10."TransId" = T3."U_BPP_AstDetrac" AND T10."TransCode" = 'DTR'
	LEFT JOIN "OWHT" T11 ON T8."WTCode" = T11."WTCode" 
	--LEFT JOIN "@BPP_PAGM_DET1" T12 ON T12."U_BPP_CODPROV" = T3."CardCode" AND T12."U_BPP_NUMDOC" = T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-' ||T3."U_BPP_MDCD"
	--LEFT JOIN "@BPP_PAGM_CAB" T13 ON T13."DocEntry" = T12."DocEntry"
	WHERE 
		T3."TaxDate" >= CASE WHEN  :FECHAINI='' THEN T3."TaxDate" ELSE :FECHAINI  END 
		AND T3."TaxDate" <= CASE WHEN  :FECHAFIN='' THEN T3."TaxDate" ELSE :FECHAFIN  END 
		
		AND T3."DocDueDate" >= CASE WHEN  :FECHAVINI='' THEN T3."DocDueDate" ELSE :FECHAVINI  END 
		AND T3."DocDueDate" <= CASE WHEN  :FECHAVFIN='' THEN T3."DocDueDate" ELSE :FECHAVFIN  END 

		AND T3."CardCode" = CASE WHEN  :CODPROVEEDOR='' THEN T3."CardCode" ELSE :CODPROVEEDOR END 
		AND  T3."DocTotal" - T3."PaidSum" != 0
		AND T3."DocCur" = :MONEDA
		AND T3."CANCELED" = 'N'
		AND T3."DocStatus" != 'C'
		--AND IFNULL(T12."DocEntry",0)=0
		--AND IFNULL(T13."U_BPP_ESTADO",'Cancelado') = 'Cancelado'
		AND IFNULL(T6."U_BPP_NUMSAP",0)= 0
		ORDER BY "NombreProveedor" ASC
		)TT1
	 WHERE TT1."Saldo" >0	
	;
END