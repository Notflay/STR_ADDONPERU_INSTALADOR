CREATE PROCEDURE SP_BPP_CONSULTAR_DETRACCIONES(
FECHAINI DATE,
FECHAFIN DATE
)
AS
BEGIN
	


	--SELECT @FECHAINI=F_RefDate,@FECHAFIN=T_RefDate FROM OFPR WHERE AbsEntry = @PERIODO


	SELECT 
		 T3."CardCode" "CodigoProveedor"
		,T3."CardName" "NombreProveedor"
		,T5."WTCode" "CodigoDetraccion"
		,T3."DocEntry" "NumeroSAP"
		,T6."TransId" "NumeroAsiento"
		,T3."DocCur" "Moneda"
		,T2."TaxDate" "FechaContabilizacion"
		,T2."TaxDate" "FechaDocumento"
		,T2."TaxDate" "FechaVencimiento"
		,T3."U_BPP_MDTD" "CodigoOperacion"
		,CASE WHEN T3."DocCur" = 'SOL' THEN ROUND((CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."Credit",0) ELSE -IFNULL(T0."Debit",0) END ) , 0)
		ELSE  ROUND( (CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."FCCredit",0) ELSE -IFNULL(T0."FCDebit",0) END * T3."DocRate" ), 0)
		END 	 
		 "ImportePago" 
		,T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" ||'-'||T3."U_BPP_MDCD" "NumeroDocumento"
		,CASE WHEN T3."DocCur" = 'SOL' THEN "DocTotal" ELSE "DocTotalFC" END "ImporteDoc" 
		
		, ROUND((CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."Credit",0) ELSE -IFNULL(T0."Debit",0) END  ) , 0) "Monto"
		,CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."Credit",0) ELSE -IFNULL(T0."Debit",0) END "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."FCCredit",0) ELSE -IFNULL(T0."FCDebit",0) END "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN IFNULL(T0."SYSCred",0) ELSE -IFNULL(T0."SYSDeb",0) END "MontoSistema"
		,IFNULL(T0."FCCurrency",'SOL') "Moneda"
		,T0."TaxDate" "FechaContabilizacion"
		,T0."TaxDate" "FechaDocumento"
		,T0."TaxDate" "FechaVencimiento"
		,'' "CodigoBien"
		,T6."TransCode" "CodigoTransaccion" 
		,T5."Rate" "PorcentajeDetraccion"
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
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND T1."FormatCode" IN (select  DISTINCT  "Account"  froM "OWHT" WHERE "WTCode" LIKE 'D%'  ) 	 -- AND T1."FormatCode" IN ('42120300') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId" --AND T2."TransCode"='DET'
		INNER JOIN OPCH T3 ON T2."TransId" = T3."TransId"
		INNER JOIN PCH5 T4 ON T3."DocEntry" = T4."AbsEntry"
		INNER JOIN OWHT T5 ON T4."WTCode" = T5."WTCode"
		INNER JOIN (SELECT cast(R2."Ref3" as int) "TransIdFactura", R2."TransId",R2."TransCode" FROM OJDT R2 WHERE ("Memo" LIKE '%ADD-ON BPP DETRACCIONES%' OR R2."TransCode"='DET')
		AND R2."TransId" NOT IN (SELECT A1."StornoToTr" FROM OJDT A1 WHERE  A1."StornoToTr" IS NOT NULL) AND R2."StornoToTr" IS NULL )T6 ON CAST(T3."TransId" AS NVARCHAR(20)) = T6."TransIdFactura"
		LEFT JOIN (SELECT DISTINCT T1."U_BPP_NUMASIENTO" FROM "@BPP_DETR_CAB" T0 INNER JOIN "@BPP_DETR_DET1" T1 ON T0."DocEntry"=T1."DocEntry" WHERE T0."Canceled"!='Y') T7 ON T6."TransId" = T7."U_BPP_NUMASIENTO"
	WHERE 
		T0."RefDate">=:FECHAINI and T0."RefDate"<=:FECHAFIN AND  T6."TransCode"='DET'
		AND 
		(((IFNULL(T0."Debit",0) - IFNULL(T0."Credit",0)) <> 0) OR ((IFNULL(T0."FCDebit",0) - IFNULL(T0."FCCredit",0)) <> 0) OR ((IFNULL(T0."SYSDeb",0) - IFNULL(T0."SYSCred",0)) <> 0))
		AND T2."TransType" = 18
		AND 
		T6."TransId" NOT IN (SELECT A1."DocEntry" FROM VPM2 A1 INNER JOIN OVPM A2 ON A1."DocNum" = A2."DocEntry" WHERE A2."Canceled" = 'N')
		
		AND IFNULL( T7."U_BPP_NUMASIENTO",0)=0
		AND T3."CANCELED" = 'N'
		--AND T2.TransId NOT IN (SELECT cast(R2.Ref1 as int) FROM OJDT R2 WHERE Memo LIKE '%ADD-ON BPP%' 
		--AND R2.TRANSID NOT IN (SELECT A1.StornoToTr FROM OJDT A1 WHERE  A1.StornoToTr IS NOT NULL) AND R2.StornoToTr IS NULL /*AND TransId  in (SELECT  cast(Ref1 as int) FROM OJDT WHERE  StornoToTr= 425)*/
		-- )
	
	ORDER BY 1 DESC;



END
