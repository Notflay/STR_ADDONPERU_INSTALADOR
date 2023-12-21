CREATE PROCEDURE STR_LT_ESTADO_CUENTAS_CORRIENTES_SOCIO
(
@CardCode nvarchar(20),
@FechaIni datetime,
@FechaFin datetime,
@Grupo int
)
as
begin
declare @tipo as int
set @tipo = 1
SELECT * INTO #TEMPDOCUMENTOS FROM (
		SELECT T0.[DocSubType], T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], 
				T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], 
				T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[OINV] T0  INNER  JOIN [dbo].[INV6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[CardCode] = isnull(@CardCode,T0.[CardCode]) AND  (T1.[TotalBlck]  <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[ODPI] T0  INNER  JOIN [dbo].[DPI6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[CardCode] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T1.[Status] = ('O')   
		UNION ALL		
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[OCSI] T0  INNER  JOIN [dbo].[CSI6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[CardCode] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[OINV] T0  INNER  JOIN [dbo].[INV6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[FatherCard] <>'' AND T0.[FatherCard] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T0.[FatherType] = ('P')  AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[ODPI] T0  INNER  JOIN [dbo].[DPI6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[FatherCard] <> '' AND T0.[FatherCard] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T0.[FatherType] = ('P')  AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[OCSI] T0  INNER  JOIN [dbo].[CSI6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[FatherCard] <>'' AND T0.[FatherCard] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T0.[FatherType] = ('P')  AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[ORIN] T0  INNER  JOIN [dbo].[RIN6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[CardCode] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T1.[Status] = ('O')   
		UNION ALL
		SELECT T0.[DocSubType],T0.[DocEntry], T0.[DocNum], T0.[Series], T1.[InstlmntID], T0.[DocType], T0.[CANCELED], T1.[Status], T0.[DocDate], T1.[DueDate], T0.[CardCode], T0.[CardName], T0.[NumAtCard], T0.[DocCur], T0.[DocRate], T0.[TransId], T0.[GroupNum], T0.[FatherCard], T0.[FatherType], T0.[selfInv], T0.[NetProc], T0.[CashDiscPr], T0.[PaymentRef], T1.[InsTotal], T1.[InsTotalFC], T1.[InsTotalSy], T1.[PaidToDate], T1.[PaidFC], T1.[PaidSys], T1.[VatSum], T1.[VatSumFC], T1.[VatSumSy], T1.[VatPaid], T1.[VatPaidFC], T1.[VatPaidSys], T1.[TotalExpns], T1.[TotalExpFC], T1.[TotalExpSC], T1.[ExpAppl], T1.[ExpApplFC], T1.[ExpApplSC], T1.[WTSum], T1.[WTSumFC], T1.[WTSumSC], T1.[WTApplied], T1.[WTAppliedF], T1.[WTAppliedS], T1.[TotalBlck], T1.[TotalBlckF], T1.[TotalBlckS], T1.[VATBlck], T1.[VATBlckFC], T1.[VATBlckSC], T1.[ExpnsBlck], T1.[ExpnsBlckF], T1.[ExpnsBlckS], T1.[WTBlocked], T1.[WTBlockedF], T1.[WTBlockedS], T0.[Comments], T0.[ObjType], T0.[Instance], T0.[AgentCode], T0.[Installmnt], T0.[Reserve], T0.[Max1099], T0.[Posted], T0.[DpmStatus], T1.[TaxOnExp], T1.[TaxOnExpFc], T1.[TaxOnExpSc], T1.[TaxOnExpAp], T1.[TaxOnExApF], T1.[TaxOnExApS], T1.[TaxOnExBlo], T1.[TaxOnExBlF], T1.[TaxOnExBlS], T0.[TaxDate], T0.[ClsDate], T0.[CdcOffset], T1.[reserved], T0.[FolioNum], T1.[InstPrcnt], T0.[Project], T0.[PayBlock], T0.[CIG], T0.[CUP] 
		FROM  [dbo].[ORIN] T0  INNER  JOIN [dbo].[RIN6] T1  ON  T1.[DocEntry] = T0.[DocEntry]   
		WHERE T0.[FatherCard] <>'' AND T0.[FatherCard] = isnull(@CardCode,T0.[CardCode])  AND  (T1.[TotalBlck] <> T1.[InsTotal]  OR  T1.[TotalBlck] = (0) ) AND  T0.[FatherType] = ('P')  AND  T1.[Status] = ('O')   
) T 
--where T.DueDate <= isnull(@FechaFin, T.DueDate)

	SELECT T0.[ShortName], T1.[Series], T0.[TransId], T0.[Line_ID], T0.[RefDate], T0.[DueDate], T0.[LineMemo], T0.[TransType], T0.[FCCurrency], T0.[Credit], T0.[Debit], T0.[BalDueCred], T0.[BalDueDeb], T0.[FCCredit], T0.[FCDebit], T0.[BalFcCred], T0.[BalFcDeb], T0.[DebCred], T0.[WTSum], T0.[WTSumSC], T0.[WTSumFC], T0.[WTApplied], T0.[WTAppliedS], T0.[WTAppliedF], T0.[TaxDate], T1.[Ref2], T0.[PayBlock], T2.[PaymBlock], T1.[FolioNum], T1.[FolioPref], T0.[Project], T0.[CIG], T0.[CUP] , T1.[Memo], t1.TransRate, case  t1.TransCurr when null then 'SOL' when '' then 'SOL'  else t1.TransCurr end  as 'TransCurr', T1.U_LET_EST
	INTO #TEMPASIENTOS
	FROM  [dbo].[JDT1] T0  INNER  JOIN [dbo].[OJDT] T1  ON  T0.[TransId] = T1.[TransId]   
	INNER  JOIN [dbo].[OCRD] T2  ON  T0.[ShortName] = T2.[CardCode]   
	WHERE ((T0.[TransType] <> ('13')  AND  T0.[TransType] <> ('203')  AND  ((T0.[TransType] <> ('24')  AND  T0.[TransType] <> ('-5') ) OR  (T0.[TransType] = ('24')  
	AND  T0.[LineType] <> (1)  AND  T0.[LineType] <> (2)  AND  T0.[LineType] <> (5) ) OR  (T0.[TransType] = ('-5')  AND  T0.[LineType] <> (5) )) 
	AND  T0.[TransType] <> ('165')  AND  T0.[TransType] <> ('166')  AND  T0.[TransType] <> ('163')  AND  T0.[TransType] <> ('164')  
	AND  T0.[TransType] <> ('14')  AND  T0.[TransType] <> ('182') ) OR  T0.[BatchNum] > (0) ) 
	AND  T0.[ShortName]= isnull(@CardCode,T0.[ShortName])  AND  T0.[Closed] = ('N') 
	AND  (T0.[BalDueCred] <> (0)  OR  T0.[BalDueDeb] <> (0) ) AND  ((T0.[SourceLine] <> (-14)  AND  T0.[SourceLine] <> (-6) ) 
	OR  T0.[SourceLine] IS NULL  ) AND  (T0.[TransType] <> ('-2')  OR  T1.[DataSource] <> ('T') ) 
	--and T1.DueDate <= isnull(@FechaFin, T1.DueDate)
	 
	
select * into #tempFinal from (	
select 
isnull(t1.FatherCard,t1.CardCode) 'CodSocio', 
ISNULL((select tx.CardName from OCRD tx where tx.CardCode = t1.FatherCard),t1.CardName)'NomSocio', 
t1.CardCode, t1.CardName, t2.GroupName,t0.NumAtCard 'Num Legal'

-- 30/04/2013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
, t0.InsTotal 'Total'
, t0.InsTotalFC 'TotalFC' -- 30/04/2013 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
, T0.PaidToDate 'Pagado'
, T0.PaidFC 'PagadoFC' -- 30/04/2013 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
-- 18/10/2013 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
, case when t0.objtype = '14' then -1 else 1 end * (T0.InsTotal - T0.WTSum - T0.PaidToDate) 'Saldo' 
, case when t0.objtype = '14' then -1 else 1 end * (T0.InsTotalFC - T0.WTSumFC - T0.PaidFC) 'SaldoFC',
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

case when t0.docType = 'S' then t0.DocDate  else t0.docDate end 'Fecha Documento', t0.DueDate 'Fecha Vencimiento',
DATEDIFF (day, case when t0.docType = 'S' then t0.DocDate else t0.DocDate end,GETDATE()) 'Dias', 
t0.Transid 'Asiento',t0.Docnum 'Num SAP',
CASE t0.ObjType when '13'  then (select top 1 tx.Dscription from INV1 tx where tx.DocEntry = t0.DocEntry)
			 when '14'  then (select top 1 tx.Dscription from RIN1 tx where tx.DocEntry = t0.DocEntry)
			 when '203' then (select top 1 tx.Dscription from DPI1 tx where tx.DocEntry = t0.DocEntry)			
end 'Concepto', t0.DocEntry , t0.TaxDate, t0.DocCur, t0.DocRate, 
case	when t0.ObjType = '13' and t0.DocSubType = '--' then 'FA'
		when t0.ObjType = '13' and t0.DocSubType = 'DN' then 'ND'
		when t0.ObjType = '14' then 'NC'
		when t0.ObjType = '203' then 'AN'
end 'TipoDoc'
, 0 as 'Line_ID'
from #TEMPDOCUMENTOS t0
inner join OCRD t1 on t0.CardCode = t1.CardCode 
inner join OCRG t2 on t1.GroupCode = t2.GroupCode 
where t2.GroupCode = ISNULL(@Grupo, t2.GroupCode)
and T0.DocEntry not in (select U_DocEntry from [@ST_LT_EMILET] TX0 inner join [@ST_LT_ELDOCS] TX1
on TX0.DocEntry = TX1.DocEntry where TX0.U_CardCode = t0.CardCode
and U_chkSel = 'Y' and U_DocStat <> 'A' and tx0.u_EstLet='001')
union all

select 
isnull(t1.FatherCard,t1.CardCode) 'CodSocio', 
ISNULL((select tx.CardName from OCRD tx where tx.CardCode = t1.FatherCard),t1.CardName)'NomSocio',
t1.CardCode, t1.CardName, t2.GroupName,t0.ref2 'Num Legal'

-- 30/04/2013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
, t0.Debit-t0.Credit 'Total'
, t0.FCDebit-t0.FCCredit 'TotalFC'
, t0.BalDueDeb-T0.BalDueCred 'Pagado'
, t0.BalFCDeb-T0.BalFCCred 'PagadoFC'
, /*t0.Credit-t0.Debit -*/ -(T0.BalDueCred-t0.BalDueDeb) 'Saldo'
, /*t0.FCCredit-t0.FCDebit -*/ -(T0.BalFCCred-t0.BalFCDeb) 'SaldoFC'
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

, t0.RefDate 'Fecha Documento', t0.DueDate 'Fecha Vencimiento',
DATEDIFF (day,t0.refdate,GETDATE()) 'Dias', 
t0.Transid 'Asiento',t0.transid 'Num SAP', memo 'Concepto', t0.TransId , t0.TaxDate, t0.TransCurr, t0.TransRate, 'AS'
, T0.Line_ID as 'Line_ID'
from #TEMPASIENTOS t0
inner join OCRD t1 on t0.ShortName = t1.CardCode and t1.CardType = 'C'
inner join OCRG t2 on t1.GroupCode = t2.GroupCode
--where t2.GroupCode = ISNULL(@Grupo, t2.GroupCode)and ((t0.Credit-t0.Debit) - (T0.BalDueCred-t0.BalDueDeb))>0 and @tipo = 0
where /*t2.GroupCode = ISNULL(@Grupo, t2.GroupCode)and */(/*(t0.Credit-t0.Debit) - */(T0.BalDueCred-t0.BalDueDeb))<>0 --and @tipo = 1
AND case when LEFT(t0.ref2,3) = 'LET' then  ISNULL(T0.U_LET_EST, '') else 1 end=case when LEFT(t0.ref2,3) = 'LET' then '008' else 1 end
AND t0.Transid not in (Select U_DocEntry from [@ST_LT_EMILET] TX0 inner join [@ST_LT_ELDOCS] TX1
on TX0.DocEntry = TX1.DocEntry where TX0.U_CardCode = isnull(t1.FatherCard,t1.CardCode) and U_chkSel = 'Y' and U_DocStat <> 'A'  and tx0.u_EstLet='001'))T

select [Num SAP] 'DocNum', [DocEntry] 'DocEntry', [Num Legal]'NumAtCard',
[Fecha Documento]'DocDate', 
[Fecha Vencimiento] 'TaxDate', DocCur 'DocCur',DocRate'DocRate',

-- 30/04/2013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Total 'DocTotal',
TotalFC 'DocTotalFC',
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Total 'MontoLocal', 

-- 08/05/2013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Saldo'Saldo' ,
SaldoFC'SaldoFC' ,
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
TipoDoc 'TipoDoc'

-- 23092013 - 1248 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
, Line_ID 'Line_ID'
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
from #tempFinal
order by 1,2,3,4 desc
end