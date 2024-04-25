CREATE procedure "SP_BPP_GENERAR_ASIENTO"
(
Docentry int,
ObjType nvarchar(20)
)
AS
BEGIN 

IF (:ObjType = '18')
THEN 

-- 1.Caso Periodo Antiguo, no genero asiento ?
--SELECT 
--T1.DocEntry,T1.DocDate 'RefDate',T1.TaxDate 'TaxDate'
--,T1.DocDueDate 'DueDate','' 'Type',T1.TransId 'TransId'
--,T1.DocTotal*0.10 'TotalML'
----,T1.DocTotal*0.10 'CreditML' 
--,T1.DocCur 'Currency' 
--,'ADDON BPP - Detracciones:' + T1.CardCode 'Memo'
--,T1.CardCode 'CardCode'
--,'4212103' 'Account'
--,T1.CardCode 'AccountDebit'
--,'4212103' 'Accountcredit'
--FROM OPCH T1 
--WHERE T1.DocEntry = @Docentry

SELECT 
		
		
		T0."TransId" "AsientoOrigen"
		,T0."Line_ID" + 1 "linOrigen"
		,T3."DocEntry" "NumeroSAP"
		,T5."Account" "CuentaDebit"
		--, '42120400' "CuentaCredit" --( select "Account" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId" ) 
		, (SELECT "U_BPP_CNTDETASC" FROM "@BPP_PARAMS"  )"CuentaCredit" --( select "Account" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId" ) 
		--,T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-'||T3."U_BPP_MDCD" "NumeroDocumento"
		,T3."NumAtCard" "NumeroDocumento"
		--,( select  "ShortName" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId") "Proveedor"
		,( select  a1."ShortName" from "JDT1"  A1 INNER JOIN "OACT" A2 ON A2."AcctCode" = A1."Account"where a2."LocManTran" = 'Y' and "TransId" = T2."TransId") "Proveedor"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."Credit",0) ELSE IFNULL(T0."Debit",0) END "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."FCCredit",0) ELSE IFNULL(T0."FCDebit",0) END "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."SYSCred",0) ELSE IFNULL(T0."SYSDeb",0) END "MontoSistema"
		,IFNULL(T0."FCCurrency",'SOL') "Moneda"
		,T0."RefDate" "FechaContabilizacion"
		,T0."TaxDate" "FechaDocumento"
		,T0."DueDate" "FechaVencimiento"
		
									
		,T0."LineMemo" "glosa"
		,IFNULL(T0."ProfitCode",'') "CC1"
		,IFNULL(T0."OcrCode2",'') "CC2"
		,IFNULL(T0."OcrCode3",'') "CC3"
		,IFNULL(T0."OcrCode4",'') "CC4"
		,IFNULL(T0."OcrCode5",'') "CC5"
		
		FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" --AND LEFT(T1."FormatCode",2) IN ('62','63','64','65') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"
		INNER JOIN OPCH T3 ON T2."TransId" = T3."TransId"
		INNER JOIN PCH5 T4 ON T3."DocEntry" = T4."AbsEntry"
		INNER JOIN OWHT T5 ON T4."WTCode" = T5."WTCode"	AND T0."Account" = T5."Account"	
	WHERE  (((IFNULL(T0."Debit",0) - IFNULL(T0."Credit",0)) <> 0) OR ((IFNULL(T0."FCDebit",0) - IFNULL(T0."FCCredit",0))  <> 0) OR ((IFNULL(T0."SYSDeb",0) - IFNULL(T0."SYSCred",0)) <> 0))
		AND T2."TransType" = :ObjType AND T3."DocEntry" = :Docentry
		AND T3."CANCELED" = 'N'
		--AND T5."Account" = T0."Account"
		;


END IF;

IF (:ObjType = '19')
THEN 

-- 1.Caso Periodo Antiguo, no genero asiento ?
--SELECT 
--T1.DocEntry,T1.DocDate 'RefDate',T1.TaxDate 'TaxDate'
--,T1.DocDueDate 'DueDate','' 'Type',T1.TransId 'TransId'
--,T1.DocTotal*0.10 'TotalML'
----,T1.DocTotal*0.10 'CreditML' 
--,T1.DocCur 'Currency' 
--,'ADDON BPP - Detracciones:' + T1.CardCode 'Memo'
--,T1.CardCode 'CardCode'
--,'4212103' 'Account'
--,T1.CardCode 'AccountDebit'
--,'4212103' 'Accountcredit'
--FROM OPCH T1 
--WHERE T1.DocEntry = @Docentry

SELECT 
		
		
		T0."TransId" "AsientoOrigen"
		,T0."Line_ID" + 1 "linOrigen"
		,T3."DocEntry" "NumeroSAP"
		,T5."Account" "CuentaDebit"
		--, '42120400' "CuentaCredit" --( select "Account" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId" ) 
		, (SELECT "U_BPP_CNTDETASC" FROM "@BPP_PARAMS"  )"CuentaCredit" --( select "Account" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId" ) 
		--,T3."U_BPP_MDTD" || '-'|| T3."U_BPP_MDSD" || '-'||T3."U_BPP_MDCD" "NumeroDocumento"
		,T3."NumAtCard" "NumeroDocumento"
		--,( select  "ShortName" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId") "Proveedor"
		,( select  a1."ShortName" from "JDT1"  A1 INNER JOIN "OACT" A2 ON A2."AcctCode" = A1."Account"where a2."LocManTran" = 'Y' and "TransId" = T2."TransId") "Proveedor"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."Credit",0) ELSE IFNULL(T0."Debit",0) END "MontoLocal"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."FCCredit",0) ELSE IFNULL(T0."FCDebit",0) END "MontoExtranjero"
		,CASE T0."DebCred" WHEN 'C' THEN -IFNULL(T0."SYSCred",0) ELSE IFNULL(T0."SYSDeb",0) END "MontoSistema"
		,IFNULL(T0."FCCurrency",'SOL') "Moneda"
		,T0."RefDate" "FechaContabilizacion"
		,T0."TaxDate" "FechaDocumento"
		,T0."DueDate" "FechaVencimiento"
		
									
		,T0."LineMemo" "glosa"
		,IFNULL(T0."ProfitCode",'') "CC1"
		,IFNULL(T0."OcrCode2",'') "CC2"
		,IFNULL(T0."OcrCode3",'') "CC3"
		,IFNULL(T0."OcrCode4",'') "CC4"
		,IFNULL(T0."OcrCode5",'') "CC5"
		
		FROM 
		JDT1 T0 
		INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" --AND LEFT(T1."FormatCode",2) IN ('62','63','64','65') 	
		INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"
		INNER JOIN ORPC T3 ON T2."TransId" = T3."TransId"
		INNER JOIN RPC5 T4 ON T3."DocEntry" = T4."AbsEntry"
		INNER JOIN OWHT T5 ON T4."WTCode" = T5."WTCode"	AND T0."Account" = T5."Account"	
	WHERE  (((IFNULL(T0."Debit",0) - IFNULL(T0."Credit",0)) <> 0) OR ((IFNULL(T0."FCDebit",0) - IFNULL(T0."FCCredit",0))  <> 0) OR ((IFNULL(T0."SYSDeb",0) - IFNULL(T0."SYSCred",0)) <> 0))
		AND T2."TransType" = :ObjType AND T3."DocEntry" = :Docentry
		AND T3."CANCELED" = 'N'
		--AND T5."Account" = T0."Account"
		;


END IF;


END;