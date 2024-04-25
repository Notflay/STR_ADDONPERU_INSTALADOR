CREATE PROCEDURE "SP_BPP_CONSULTAR_DESTINOS"
(
PERIODO INT
)
AS
BEGIN
	
	DECLARE FECHAINI DATE;
	DECLARE FECHAFIN DATE;
	DECLARE OCRCODE VARCHAR(20);
	--SELECT  "F_RefDate" INTO  FECHAINI ,"T_RefDate" INTO FECHAFIN  FROM OFPR WHERE "AbsEntry" = PERIODO;

SELECT  (SELECT TOP 1 "F_RefDate"  FROM OFPR WHERE "AbsEntry" = PERIODO) INTO  FECHAINI from dummy;
SELECT  (SELECT TOP 1 "T_RefDate"  FROM OFPR WHERE "AbsEntry" = PERIODO) INTO  FECHAFIN from dummy;
SELECT  (SELECT TOP 1 "U_STR_OcrCode" FROM "@BPP_PARAMS") INTO OCRCODE from dummy;

	SELECT 

		T0."TransId" "AsientoOrigen"
		,T0."Line_ID"  "linOrigen"
		,CASE WHEN :OCRCODE = '2' THEN T0."OcrCode2" ELSE 
			(CASE WHEN :OCRCODE = '3' THEN T0."OcrCode3" ELSE 
				(CASE WHEN :OCRCODE = '4' THEN T0."OcrCode4" ELSE T0."OcrCode5" END )END) END  AS "CuentaDestino"
		,T1."FormatCode" "CuentaNaturaleza"
--,'792' "CuentaNaturaleza"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."Credit",0) ELSE IFNULL(T0."Debit",0) END "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."FCCredit",0) ELSE IFNULL(T0."FCDebit",0) END "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."SYSCred",0) ELSE IFNULL(T0."SYSDeb",0) END "MontoSistema"
		,IFNULL(T0."FCCurrency",'SOL') "Moneda"
		,T0."RefDate" "FechaContabilizacion"
		,T0."TaxDate" "FechaDocumento"
		,T0."DueDate" "FechaVencimiento"
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
									ELSE T0."TransType" END || ' ' || T0."BaseRef" "Referencia"
									
		,T0."Ref2" "Referencia2"
									
		,T2."Memo" "Comentarios"
		,IFNULL(T0."ProfitCode",'') "CC1"
		,IFNULL(T0."OcrCode2",'') "CC2"
		,IFNULL(T0."OcrCode3",'') "CC3"
		,IFNULL(T0."OcrCode4",'') "CC4"
		,IFNULL(T0."OcrCode5",'') "CC5"
		
	FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND LEFT(T1."FormatCode",2) IN ('62','63','64','65','66','67','68') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"	
	WHERE 
		T0."RefDate">=FECHAINI and T0."RefDate"<=FECHAFIN --AND T0.U_BPP_DCPR='N'
		AND 
		(((IFNULL(T0."Debit",0) - IFNULL(T0."Credit",0)) <> 0) OR ((IFNULL(T0."FCDebit",0) - IFNULL(T0."FCCredit",0))  <> 0) OR ((IFNULL(T0."SYSDeb",0) - IFNULL(T0."SYSCred",0)) <> 0))
		--AND T2."TransType" = 18
		AND cast(T2."TransId" as nvarchar(20)) NOT IN (SELECT R2."Ref1"  FROM OJDT R2 WHERE "Memo" LIKE '%ADD-ON BPP%' 
		AND R2."TransId" NOT IN (SELECT A1."StornoToTr" FROM OJDT A1 WHERE  A1."StornoToTr" IS NOT NULL) AND R2."StornoToTr" IS NULL /*AND TransId  in (SELECT  cast(Ref1 as int) FROM OJDT WHERE  StornoToTr= 425)*/
		 )
		 AND IFNULL(CASE WHEN :OCRCODE = '2' THEN T0."OcrCode2" ELSE 
			(CASE WHEN :OCRCODE = '3' THEN T0."OcrCode3" ELSE 
				(CASE WHEN :OCRCODE = '4' THEN T0."OcrCode4" ELSE T0."OcrCode5" END )END) END,'') !=''
		 /*
		 UNION ALL
		 
		 SELECT 
		T0."TransId" "AsientoOrigen"
		,T0."Line_ID" + 1 "linOrigen"
		,T0."OcrCode5" "CuentaDestino"
		,T1."FormatCode" "CuentaNaturaleza"
--,'792' "CuentaNaturaleza"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."Credit",0) ELSE IFNULL(T0."Debit",0) END "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."FCCredit",0) ELSE IFNULL(T0."FCDebit",0) END "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."SYSCred",0) ELSE IFNULL(T0."SYSDeb",0) END "MontoSistema"
		,IFNULL(T0."FCCurrency",'SOL') "Moneda"
		,T0."RefDate" "FechaContabilizacion"
		,T0."TaxDate" "FechaDocumento"
		,T0."DueDate" "FechaVencimiento"
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
									ELSE T0."TransType" END || ' ' || T0."BaseRef" "Referencia"
									
		,T0."LineMemo" "glosa"
		,IFNULL(T0."ProfitCode",'') "CC1"
		,IFNULL(T0."OcrCode2",'') "CC2"
		,IFNULL(T0."OcrCode3",'') "CC3"
		,IFNULL(T0."OcrCode4",'') "CC4"
		,IFNULL(T0."OcrCode5",'') "CC5"
		
	FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND LEFT(T1."FormatCode",2) IN ('62','63','64','65','66','67','68') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"	
	WHERE 
		T0."RefDate">='20230120' and T0."RefDate"<='20230120' --AND T0.U_BPP_DCPR='N'
		AND 
		(((IFNULL(T0."Debit",0) - IFNULL(T0."Credit",0)) <> 0) OR ((IFNULL(T0."FCDebit",0) - IFNULL(T0."FCCredit",0))  <> 0) OR ((IFNULL(T0."SYSDeb",0) - IFNULL(T0."SYSCred",0)) <> 0))
		AND T2."TransType" = 30
		AND T2."TransId" NOT IN (SELECT cast(R2."Ref1" as int) FROM OJDT R2 WHERE "Memo" LIKE '%ADD-ON BPP%' 
		AND R2."TransId" NOT IN (SELECT A1."StornoToTr" FROM OJDT A1 WHERE  A1."StornoToTr" IS NOT NULL) AND R2."StornoToTr" IS NULL /*AND TransId  in (SELECT  cast(Ref1 as int) FROM OJDT WHERE  StornoToTr= 425)
		 )
		 AND IFNULL(T0."OcrCode5",'') !=''*/
	ORDER BY 1 DESC;

END