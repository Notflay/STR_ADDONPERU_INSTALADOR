CREATE PROCEDURE SP_BPP_CONSULTAR_DESTINOS(
@PERIODO INT
)
AS
BEGIN
	
	DECLARE @FECHAINI DATE
	DECLARE @FECHAFIN DATE

	--SELECT  "F_RefDate" INTO  FECHAINI ,"T_RefDate" INTO FECHAFIN  FROM OFPR WHERE "AbsEntry" = PERIODO;

    SET @FECHAINI = (SELECT TOP 1 "F_RefDate"  FROM OFPR WHERE "AbsEntry" = @PERIODO)
    SET @FECHAFIN = (SELECT TOP 1 "T_RefDate"  FROM OFPR WHERE "AbsEntry" = @PERIODO)

	SELECT 

		T0."TransId" AS "AsientoOrigen"
		,T0."Line_ID" + 1 AS "linOrigen"
		,T0."OcrCode5" AS "CuentaDestino"
		,T1."FormatCode" AS "CuentaNaturaleza"
--,'792' "CuentaNaturaleza"
		,CASE T0."DebCred" WHEN 'C' THEN -ISNULL(T0."Credit",0) ELSE ISNULL(T0."Debit",0) END AS "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN -ISNULL(T0."FCCredit",0) ELSE ISNULL(T0."FCDebit",0) END AS "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN -ISNULL(T0."SYSCred",0) ELSE ISNULL(T0."SYSDeb",0) END AS "MontoSistema"
		,ISNULL(T0."FCCurrency",'SOL') AS "Moneda"
		,T0."RefDate" AS "FechaContabilizacion"
		,T0."TaxDate" AS "FechaDocumento"
		,T0."DueDate" AS "FechaVencimiento"
		,CASE T0."TransType"
									WHEN '46' THEN 'PP'
									WHEN '321' THEN 'ID' 
									WHEN '24' THEN 'PR'
									WHEN '30' THEN 'AS'
									WHEN '18' THEN 'TT'
									WHEN '19' THEN 'AC'
									WHEN '59' THEN 'EM'
									WHEN '60' THEN 'SM'
									WHEN '69' THEN 'DI'
									WHEN '13' THEN 'RF'
									ELSE T0."TransType" END + ' ' + T0."BaseRef" AS "Referencia"
									
		,T0."Ref2" AS "Referencia2"
									
		,T2."Memo" "Comentarios"
		,ISNULL(T0."ProfitCode",'') AS "CC1"
		,ISNULL(T0."OcrCode2",'') AS "CC2"
		,ISNULL(T0."OcrCode3",'') AS "CC3"
		,ISNULL(T0."OcrCode4",'') AS "CC4"
		,ISNULL(T0."OcrCode5",'') AS "CC5"
		
	FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND LEFT(T1."FormatCode",2) IN ('62','63','64','65','66','67','68') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"	
	WHERE 
		T0."RefDate">=@FECHAINI and T0."RefDate"<=@FECHAFIN --AND T0.U_BPP_DCPR='N'
		AND 
		(((ISNULL(T0."Debit",0) - ISNULL(T0."Credit",0)) <> 0) OR ((ISNULL(T0."FCDebit",0) - ISNULL(T0."FCCredit",0))  <> 0) OR ((ISNULL(T0."SYSDeb",0) - ISNULL(T0."SYSCred",0)) <> 0))
		--AND T2."TransType" = 18
		AND cast(T2."TransId" as nvarchar(20)) NOT IN (SELECT R2."Ref1"  FROM OJDT R2 WHERE "Memo" LIKE '%ADD-ON BPP%' 
		AND R2."TransId" NOT IN (SELECT A1."StornoToTr" FROM OJDT A1 WHERE  A1."StornoToTr" IS NOT NULL) AND R2."StornoToTr" IS NULL /*AND TransId  in (SELECT  cast(Ref1 as int) FROM OJDT WHERE  StornoToTr= 425)*/
		 )
		 AND ISNULL(T0."OcrCode5",'') !=''

	ORDER BY 1 DESC;

END

