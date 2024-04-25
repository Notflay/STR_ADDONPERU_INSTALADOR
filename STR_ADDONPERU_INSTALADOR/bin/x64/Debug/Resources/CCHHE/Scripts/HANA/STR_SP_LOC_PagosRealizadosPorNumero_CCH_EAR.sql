CREATE PROCEDURE STR_SP_LOC_PagosRealizadosPorNumero_CCH_EAR
(
	IN pv_CodCCH varchar(20),
	IN pv_NmrCCH varchar(50),
	IN pv_TpoRnd varchar(3)
)
AS
	mndloc char(3);
BEGIN
SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;

	SELECT T2."CardCode" AS "Cod. Proveedor",
			T2."CardName" AS "Nombre",
			T1."DocEntry" AS "DED",
			T2."DocNum" AS "Nro Documento",
			CASE "InvType" WHEN '18' THEN 'FA' END AS "Documento",
			T2."U_BPP_MDTD" || '-' || T2."U_BPP_MDSD" || '-' || T2."U_BPP_MDCD" AS "Numero SUNAT",
			T2."DocDate" AS "Fecha de Contabilizacion",
			T2."TaxDate" AS "Fecha de Documento",
			T2."DocCur"  AS "Moneda de Documento",
			CASE T2."DocCur" when 'SOL' THEN T2."DocTotal" ELSE T2."DocTotalFC" END AS "Total",
			T0."DocEntry" AS "DEP",
			T0."DocNum" AS "Nro Pago",
			T0."DocDate" AS "Fecha de Pago",
			T0."DocCurr" AS "Moneda de Pago",
			CASE T2."DocCur" WHEN :mndloc THEN
				CASE T0."DocCurr" WHEN :mndloc THEN T1."SumApplied" ELSE (T1."SumApplied" / (SELECT "Rate" FROM ORTT TX0 WHERE TX0."RateDate" = T0."DocDate" AND TX0."Currency" =  T0."DocCurr")) END
			ELSE 
				CASE T0."DocCurr" WHEN :mndloc THEN T1."SumApplied" ELSE T1."AppliedFC" END END AS "Importe Pagado"			
	FROM OVPM T0 INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum"
	INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry"
	WHERE "U_BPP_TIPR" = :pv_TpoRnd AND T0."Canceled" != 'Y' AND "U_BPP_CCHI" = :pv_CodCCH AND "U_BPP_NUMC" = :pv_NmrCCH
	
	UNION ALL
--Notas de Credito
	SELECT T2."CardCode" AS "Cod. Proveedor",
		T2."CardName" AS "Nombre",
		T1."DocEntry" AS "DED",
		T2."DocNum" AS "Nro Documento",
		CASE "InvType" WHEN '19' THEN 'NC' END AS "Documento",
		T2."U_BPP_MDTD" || '-' || T2."U_BPP_MDSD" || '-' || T2."U_BPP_MDCD" AS "Numero SUNAT",
		T2."DocDate" AS "Fecha de Contabilizacion",
		T2."TaxDate" AS "Fecha de Documento",
		T2."DocCur" AS "Moneda de Documento",
		CASE T2."DocCur" when 'SOL' THEN T2."DocTotal" ELSE T2."DocTotalFC" END AS "Total",
		T0."DocEntry" AS "DEP",
		T0."DocNum" AS "Nro Pago",
		T0."DocDate" AS "Fecha de Pago",
		T0."DocCurr" AS "Moneda de Pago",
					T1."SumApplied" * ((CASE T2."DocCur" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = T2."DocDate" AND "Currency" = T2."DocCur") END)
				/(CASE T0."DocCurr" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = T0."DocDate" AND "Currency" = T0."DocCurr") END)) AS "Importe Pagado"
	FROM ORCT T0 INNER JOIN RCT2 T1 ON T0."DocEntry" = T1."DocNum"
	INNER JOIN ORPC T2 ON T1."DocEntry" = T2."DocEntry"
	WHERE "U_BPP_TIPR" = :pv_TpoRnd AND T0."Canceled" != 'Y' AND "U_BPP_CCHI" = :pv_CodCCH AND "U_BPP_NUMC" = :pv_NmrCCH;
END;