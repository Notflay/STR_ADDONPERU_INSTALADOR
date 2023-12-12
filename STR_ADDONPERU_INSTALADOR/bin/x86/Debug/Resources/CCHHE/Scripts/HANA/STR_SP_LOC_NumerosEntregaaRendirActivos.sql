CREATE PROCEDURE STR_SP_LOC_NumerosEntregaaRendirActivos
(
	pv_CODEAR VARCHAR(30)	
)
AS
	vv_U_ER_MNTO VARCHAR(50);
	mndloc char(3);
BEGIN
	SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;
	
	SELECT
		 TT."U_ER_NMER",
		CONCAT(TT."U_ER_MNDA",CONCAT(' ',SUM(TT."SALDO"))) 
	FROM
	(
		SELECT T0."U_ER_NMER",T1."U_ER_MNDA",T0."U_ER_MNAP" - (SELECT IFNULL(
									SUM(CASE TX2."DocCur" WHEN :mndloc THEN
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE (TX1."SumApplied" / (SELECT "Rate" FROM ORTT TY0 
										WHERE TY0."RateDate" = TX0."DocDate" AND TY0."Currency" =  TX0."DocCurr")) END
									ELSE 
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE TX1."AppliedFC" END END),0.0)
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0."DocEntry" = TX1."DocNum" 
						  INNER JOIN OPCH TX2 ON TX1."DocEntry" = TX2."DocEntry" 
						  WHERE TX0."Canceled" != 'Y' AND "U_BPP_NUMC" = T0."U_ER_NMER") 
						  + 
						  (SELECT IFNULL(
									SUM(CASE TX2."DocCur" WHEN :mndloc THEN
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE (TX1."SumApplied" / (SELECT "Rate" FROM ORTT TY0 
										WHERE TY0."RateDate" = TX0."DocDate" AND TY0."Currency" =  TX0."DocCurr")) END
									ELSE 
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE TX1."AppliedFC" END END),0.0)
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0."DocEntry" = TX1."DocNum" 
						  INNER JOIN OINV TX2 ON TX1."DocEntry" = TX2."DocEntry"
						  WHERE TX0."Canceled" != 'Y' AND "U_BPP_NUMC" = T0."U_ER_NMER") AS "SALDO"		  
	FROM "@STR_EARAPRDET" T0 INNER JOIN "@STR_EARAPR" T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE IFNULL(T0."U_ER_NMER",'')<>'' AND T0."U_ER_STDO" = 'A' AND T0."U_ER_EARN" = :pv_CODEAR
	) AS TT GROUP BY TT."U_ER_NMER",TT."U_ER_MNDA"; 
END;