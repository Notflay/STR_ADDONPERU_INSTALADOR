
CREATE PROCEDURE STR_SP_LOC_SaldoNumerosEntregaaRendir
(
	pv_NMROEAR VARCHAR(30)
)
AS
	mndloc char(3);
BEGIN
	SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;
	
	SELECT TOP 1  T0."U_ER_MNAP" - (SELECT IFNULL(
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
		  ,T1."U_ER_MNDA" AS "MONEDA",
		  T0."U_ER_PRYC" AS "PROYECTO",
		  T0."U_ER_DIM2" AS "UNIDADNEGOCIO",
		  T0."U_ER_DIM3" AS "CTADESTINO",
		  T0."U_ER_DIM4" AS "GERENCIA",
		  T0."U_ER_DIM5" AS "AREAOPERA"
	FROM "@STR_EARAPRDET" T0
	INNER JOIN "@STR_EARAPR" T1 ON T0."DocEntry" = T1."DocEntry" 
	WHERE T0."U_ER_NMER" = :pv_NMROEAR AND T0."U_ER_STDO" = 'A';
END;

