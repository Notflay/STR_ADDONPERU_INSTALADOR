CREATE PROCEDURE STR_SP_NumerosCajaChicaActivos 
	@NMROCCH VARCHAR(30)
as
DECLARE @MNDLOC CHAR(3)
SET @MNDLOC = (SELECT TOP 1 MainCurncy FROM OADM) 
--Si existe tabla [@BPP_CAJASCHICASDET]
IF EXISTS(SELECT 'E' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '@BPP_CAJASCHICASDET')
BEGIN
	SELECT U_BPP_NUMC ,U_BPP_TIPM + ' ' + CONVERT(varchar,CAST(U_BPP_SALD AS MONEY),1) AS SALDO FROM [@BPP_CAJASCHICASDET]
	WHERE  ISNULL(U_BPP_NUMC,'')<>''  and U_BPP_STAD = 'A' and Code = @NMROCCH
	UNION ALL
	SELECT U_CC_NMCC,U_CC_MNDA + ' ' + CONVERT(VARCHAR,CONVERT(MONEY,(T1.U_CC_MNAP - ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry 
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_CC_NMCC),0.0) 
						  + 
						  ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_CC_NMCC),0.0)))) AS SALDO	
	FROM [@STR_CCHAPR] T0 INNER JOIN [@STR_CCHAPRDET] T1 ON T0.DocEntry = T1.DocEntry
	WHERE ISNULL(U_CC_NMCC,'')<>'' AND U_CC_STDO = 'A' AND U_CC_CJCH = @NMROCCH
END
ELSE
BEGIN
	SELECT U_CC_NMCC,U_CC_MNDA + ' ' + CONVERT(VARCHAR,CONVERT(MONEY,(T1.U_CC_MNAP - ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry 
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_CC_NMCC),0.0) 
						  + 
						  ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_CC_NMCC),0.0)))) AS SALDO	
	FROM [@STR_CCHAPR] T0 INNER JOIN [@STR_CCHAPRDET] T1 ON T0.DocEntry = T1.DocEntry
	where ISNULL(U_CC_NMCC,'')<>'' AND U_CC_STDO = 'A' AND U_CC_CJCH = @NMROCCH
END

