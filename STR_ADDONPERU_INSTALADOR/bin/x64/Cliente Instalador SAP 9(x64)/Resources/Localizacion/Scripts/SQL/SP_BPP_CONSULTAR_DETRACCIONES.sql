CREATE PROCEDURE SP_BPP_CONSULTAR_DETRACCIONES(
@FECHAINI DATE,
@FECHAFIN DATE
)
AS
BEGIN
	


	--SELECT @FECHAINI=F_RefDate,@FECHAFIN=T_RefDate FROM OFPR WHERE AbsEntry = @PERIODO


	SELECT 
		 T3."CardCode" AS "CodigoProveedor"
		,T3."CardName" AS "NombreProveedor"
		,T5."WTCode" AS "CodigoDetraccion"
		,T3."DocEntry" AS "NumeroSAP"
		,T6."TransId" AS "NumeroAsiento"
		,T3."DocCur" AS "Moneda"
		,T2."TaxDate" AS "FechaContabilizacion"
		,T2."TaxDate" AS "FechaDocumento"
		,T2."TaxDate" AS "FechaVencimiento"
		,T3."U_BPP_MDTD" AS "CodigoOperacion"
		,CASE WHEN T3."DocCur" = 'SOL' THEN ROUND((CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."Credit",0) ELSE -ISNULL(T0."Debit",0) END ) , 0)
		ELSE  ROUND( (CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."FCCredit",0) ELSE -ISNULL(T0."FCDebit",0) END * T3."DocRate" ), 0)
		END 	 
		AS "ImportePago" 
		,T3."U_BPP_MDTD" + '-'+ T3."U_BPP_MDSD" +'-'+T3."U_BPP_MDCD" AS "NumeroDocumento"
		,CASE WHEN T3."DocCur" = 'SOL' THEN "DocTotal" ELSE "DocTotalFC" END AS "ImporteDoc" 
		
		, ROUND((CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."Credit",0) ELSE -ISNULL(T0."Debit",0) END  ) , 0) AS "Monto"
		,CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."Credit",0) ELSE -ISNULL(T0."Debit",0) END AS "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."FCCredit",0) ELSE -ISNULL(T0."FCDebit",0) END AS "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN ISNULL(T0."SYSCred",0) ELSE -ISNULL(T0."SYSDeb",0) END AS "MontoSistema"
		,ISNULL(T0."FCCurrency",'SOL') AS "Moneda"
		,T0."TaxDate" AS "FechaContabilizacion"
		,T0."TaxDate" AS "FechaDocumento"
		,T0."TaxDate" AS "FechaVencimiento"
		,'' AS "CodigoBien"
		,T6."TransCode" AS "CodigoTransaccion" 
		,T5."Rate" AS "PorcentajeDetraccion"
		--,'TotalDetraccion' = SUM(CASE T0.DebCred WHEN 'C' THEN ISNULL(T0.Credit,0) ELSE -ISNULL(T0.Debit,0) END)
		
		--,'Referencia'		=	CASE CONVERT(NVARCHAR,T0.TransType) 
		--							WHEN '46' THEN 'PP'
		--							WHEN '321' THEN 'ID' 
		--							WHEN '24' THEN 'PR'
		--							WHEN '30' THEN 'AS'
		--							WHEN '18' THEN 'TT'
		--							WHEN '19' THEN 'AC'
		--							WHEN '59' THEN 'EM'
		--							WHEN '60' THEN 'SM'
		--							WHEN '69' THEN 'DI'
		--							WHEN '13' THEN 'RF'
		--							ELSE CONVERT(NVARCHAR,T0.TransType) END+' '+CONVERT(NVARCHAR,T0.BaseRef)
		--,'glosa'			=	T0.LineMemo
		--,'CC1'				=	ISNULL(T0.ProfitCode,'')
		--,'CC2'				=	ISNULL(T0.OcrCode2,'')
		--,'CC3'				=	ISNULL(T0.OcrCode3,'')
		--,'CC4'				=	ISNULL(T0.OcrCode4,'')
		--,'CC5'				=	ISNULL(T0.OcrCode5,'')
		
	FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND T1."FormatCode" IN (select  DISTINCT  "Account"  froM "OWHT" WHERE "WTCode" LIKE '0%'  ) 	 -- AND T1."FormatCode" IN ('42120300') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"
		INNER JOIN OPCH T3 ON T2."TransId" = T3."TransId"
		INNER JOIN PCH5 T4 ON T3."DocEntry" = T4."AbsEntry"
		INNER JOIN OWHT T5 ON T4."WTCode" = T5."WTCode"
		INNER JOIN (SELECT cast(R2."Ref3" as int) "TransIdFactura", R2."TransId",R2."TransCode" FROM OJDT R2 WHERE "Memo" LIKE '%ADD-ON BPP DETRACCIONES%' 
		AND R2."TransId" NOT IN (SELECT A1."StornoToTr" FROM OJDT A1 WHERE  A1."StornoToTr" IS NOT NULL) AND R2."StornoToTr" IS NULL )T6 ON CAST(T3."TransId" AS NVARCHAR(20)) = T6."TransIdFactura"
	WHERE 
		T0."RefDate">=@FECHAINI and T0."RefDate"<=@FECHAFIN --AND T0.U_BPP_DCPR='N'
		AND 
		(((ISNULL(T0."Debit",0) - ISNULL(T0."Credit",0)) <> 0) OR ((ISNULL(T0."FCDebit",0) - ISNULL(T0."FCCredit",0)) <> 0) OR ((ISNULL(T0."SYSDeb",0) - ISNULL(T0."SYSCred",0)) <> 0))
		AND T2."TransType" = 18
		AND 
		T6."TransId" NOT IN (SELECT "DocEntry" FROM VPM2)
		
		AND T0."TransId" NOT IN (SELECT T1."U_BPP_NUMASIENTO" FROM "@BPP_DETR_CAB" T0 INNER JOIN "@BPP_DETR_DET1" T1 ON T0."DocEntry"=T1."DocEntry" WHERE T0."Canceled"!='Y')
		AND T3."CANCELED" = 'N'
		--AND T2.TransId NOT IN (SELECT cast(R2.Ref1 as int) FROM OJDT R2 WHERE Memo LIKE '%ADD-ON BPP%' 
		--AND R2.TRANSID NOT IN (SELECT A1.StornoToTr FROM OJDT A1 WHERE  A1.StornoToTr IS NOT NULL) AND R2.StornoToTr IS NULL /*AND TransId  in (SELECT  cast(Ref1 as int) FROM OJDT WHERE  StornoToTr= 425)*/
		-- )
	
	ORDER BY 1 DESC;



END