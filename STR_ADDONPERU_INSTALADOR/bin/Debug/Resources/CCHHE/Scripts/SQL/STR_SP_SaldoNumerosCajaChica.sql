CREATE PROC STR_SP_SaldoNumerosCajaChica
@NMROCCH VARCHAR(30)
as
DECLARE @MNDLOC CHAR(3)
SET @MNDLOC = (SELECT TOP 1 MainCurncy FROM OADM)
--Si existe tabla [@BPP_CAJASCHICASDET]
IF EXISTS(SELECT 'E' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '@BPP_CAJASCHICASDET')
BEGIN
	--SELECT 
	--	CASE T0.U_BPP_TIPM 
	--		WHEN 'SOL' THEN 
	--			U_BPP_SALD - (SELECT ISNULL(SUM(CashSum),0.0) FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum WHERE 
	--			TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_BPP_NUMC)  
	--		ELSE 
	--			U_BPP_SALD - (SELECT ISNULL(SUM(CashSumFC),0.0) FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum WHERE 
	--			TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_BPP_NUMC)    
	--	END AS SALDO
	--	,T0.U_BPP_TIPM AS MONEDA 
	--FROM [@BPP_CAJASCHICASDET] T0  WHERE U_BPP_NUMC = @NMROCCH AND U_BPP_STAD = 'A'
	--UNION ALL 
	SELECT CONVERT(VARCHAR,CONVERT(MONEY,(U_CC_MNTO - ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry 
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_CC_NMCC),0.0) 
						  + 
						  ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_CC_NMCC),0.0)))) AS SALDO
		,U_CC_MNDA AS MONEDA 
	FROM [@STR_CCHAPRDET] T0 INNER JOIN [@STR_CCHAPR] T1 
	ON T0.DocEntry = T1.DocEntry  
	WHERE T0.U_CC_NMCC = @NMROCCH AND U_CC_STDO = 'A'
END
ELSE
BEGIN
	SELECT CONVERT(VARCHAR,CONVERT(MONEY,(U_CC_MNTO - ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry 
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_CC_NMCC),0.0) 
						  + 
						  ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T0.U_CC_NMCC),0.0)))) AS SALDO
		,U_CC_MNDA AS MONEDA 
	FROM [@STR_CCHAPRDET] T0 INNER JOIN [@STR_CCHAPR] T1 
	ON T0.DocEntry = T1.DocEntry  
	WHERE T0.U_CC_NMCC = @NMROCCH AND U_CC_STDO = 'A'
END

