CREATE PROCEDURE STR_SP_NumerosCajaChicaActivos
(
	NMROCCH VARCHAR(30)
)
AS
	mndloc char(3);
BEGIN
	SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;
	SELECT "U_CC_NMCC","U_CC_MNDA" || ' ' || TO_VARCHAR(T1."U_CC_MNAP" - (SELECT IFNULL(
									SUM(CASE TX2."DocCur" WHEN :mndloc THEN
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE (TX1."SumApplied" / (SELECT "Rate" FROM ORTT TY0 
										WHERE TY0."RateDate" = TX0."DocDate" AND TY0."Currency" =  TX0."DocCurr")) END
									ELSE 
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE TX1."AppliedFC" END END),0.0)
				 		  FROM OVPM TX0 INNER JOIN VPM2 TX1 ON TX0."DocEntry" = TX1."DocNum" 
						  INNER JOIN OPCH TX2 ON TX1."DocEntry" = TX2."DocEntry" 
						  WHERE TX0."Canceled" != 'Y' AND "U_BPP_NUMC" = T1."U_CC_NMCC") 
						  + 
						  (SELECT IFNULL(
									SUM(CASE TX2."DocCur" WHEN :mndloc THEN
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE (TX1."SumApplied" / (SELECT "Rate" FROM ORTT TY0 
										WHERE TY0."RateDate" = TX0."DocDate" AND TY0."Currency" =  TX0."DocCurr")) END
									ELSE 
										CASE TX0."DocCurr" WHEN :mndloc THEN TX1."SumApplied" ELSE TX1."AppliedFC" END END),0.0)
						  FROM ORCT TX0 INNER JOIN RCT2 TX1 ON TX0."DocEntry" = TX1."DocNum" 
						  INNER JOIN OINV TX2 ON TX1."DocEntry" = TX2."DocEntry"
						  WHERE TX0."Canceled" != 'Y' AND "U_BPP_NUMC" = T1."U_CC_NMCC")) AS "SALDO"
		,"U_CC_MNDA" AS MONEDA  
	FROM "@STR_CCHAPR" T0 INNER JOIN "@STR_CCHAPRDET" T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE IFNULL("U_CC_NMCC",'')<>'' AND "U_CC_STDO" = 'A' AND "U_CC_CJCH" = NMROCCH;
END;
