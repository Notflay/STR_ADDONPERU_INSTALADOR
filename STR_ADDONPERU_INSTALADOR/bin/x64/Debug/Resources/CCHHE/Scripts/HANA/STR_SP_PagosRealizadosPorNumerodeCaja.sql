CREATE PROCEDURE STR_SP_PagosRealizadosPorNumerodeCaja
(
	CodCCH varchar(20),
	NmrCCH varchar(50)
)
AS
BEGIN
	SELECT T2."CardCode" AS "Cod. Proveedor"
	,T2."CardName" AS "Nombre"
	,T1."DocEntry" AS "DED"
	,T2."DocNum" AS "Nro Documento"
	,CASE "InvType" WHEN '18' THEN 'FA' END AS "Documento"
	,T2."DocDate" AS "Fecha de Documento"
	,T2."TaxDate" AS "Fecha de Contabilizacion"
	,T2."DocCur" AS "Moneda de Documento"
	,CASE T2."DocCur" when 'SOL' THEN T2."DocTotal" ELSE T2."DocTotalFC" END AS "Total"
	,T0."DocEntry" AS "DEP"
	,T0."DocNum" AS "Nro Pago"
	,T0."DocDate" AS "Fecha de Pago"
	,T0."DocCurr" AS "Moneda de Pago"
	,CASE T0."DocCurr" WHEN 'SOL' THEN "CashSum" ELSE T0."CashSumFC" END AS "Importe Pagado"
	FROM OVPM T0 INNER JOIN VPM2 T1 ON T0."DocEntry" = T1."DocNum"
	INNER JOIN OPCH T2 ON T1."DocEntry" = T2."DocEntry"
	WHERE "U_BPP_TIPR" = 'CCH' AND "U_BPP_CCHI" = CodCCH AND "U_BPP_NUMC" = NmrCCH
	ORDER BY "DED";
END;