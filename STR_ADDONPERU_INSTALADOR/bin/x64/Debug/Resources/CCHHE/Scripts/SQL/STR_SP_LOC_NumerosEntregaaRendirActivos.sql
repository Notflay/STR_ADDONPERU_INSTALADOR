CREATE PROC STR_SP_LOC_NumerosEntregaaRendirActivos 
@CODEAR VARCHAR(30)
AS
DECLARE @MNDLOC CHAR(3)
SET @MNDLOC = (SELECT TOP 1 MainCurncy FROM OADM) 
SELECT T1.U_ER_NMER,U_ER_MNDA + ' ' + CONVERT(VARCHAR,CONVERT(MONEY,(U_ER_MNTO - ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry 
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_ER_NMER),0.0) 
						  + 
						  ISNULL((SELECT SUM(ISNULL(
									(CASE TX2.DocCur WHEN @MNDLOC THEN
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE (TX1.SumApplied / TX0.DocRate) END
									ELSE 
										CASE TX0.DocCurr WHEN @MNDLOC THEN TX1.SumApplied ELSE TX1.AppliedFC END END),0.0))
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum 
						  INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
						  WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = T1.U_ER_NMER),0.0)))) AS SALDO		  
FROM [@STR_EARAPR] T0 INNER JOIN [@STR_EARAPRDET] T1 ON T0.DocEntry = T1.DocEntry
WHERE ISNULL(T1.U_ER_NMER,'')<>'' AND U_ER_STDO = 'A' AND T1.U_ER_EARN = @CODEAR