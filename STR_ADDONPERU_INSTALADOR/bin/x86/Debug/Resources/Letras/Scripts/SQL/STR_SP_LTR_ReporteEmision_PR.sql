CREATE PROCEDURE STR_SP_LTR_ReporteEmision_PR
(
	@p_CardCode1 NVARCHAR(30),
	@p_CardCode2 NVARCHAR(30),
	@p_FIni DATETIME,
	@p_FFin DATETIME
)
AS
BEGIN

	SELECT 
		T0."DocEntry" AS "DocEntryEL",
		T0."DocNum" AS "DocNumEL",
		ISNULL(T2."SeriesName", '') AS "SeriesEL",
		T0."U_CardCode" AS "CodigoSN",
		T0."U_CardName" AS "NombreSN",
		T0."U_EmiDate" AS "FechaEL",
		T0."U_DocCurr" AS "MonedaEL",
		T0."U_TipCamb" AS "TipCambEL",
		T0."U_CantLet" AS "CantLetEL",
		T0."U_CantDPD" AS "CantDPDEL",
		T0."U_CantDEE" AS "CantDEEEL",
		T1."U_DocEntry" AS "DocEntryDC",
		T1."U_numLeg" AS "NumLegDC",
		T1."U_EmiDate" AS "FechaEmiDC",
		T1."U_VencDate" AS "FechaVencDC",
		T1."U_DocCurr" AS "MonedaDC",
		T1."U_Total" AS "TotalDC",
		T1."U_MontoLoc" AS "TotalMLDC",
		T1."U_Saldo" AS "SaldoDC",
		T1."U_Saldo" * 
			CASE T1."U_DocCurr" 
				WHEN 'SOL' THEN 1
				ELSE 
					CASE T1."U_tipDoc" 
						WHEN 'FA' THEN T3."DocRate"
						WHEN 'ND' THEN T3."DocRate"
						WHEN 'NC' THEN T4."DocRate"
					END 
			END AS "SaldoMLDC",
		T1."U_Pago" AS "PagoDC",
		T1."U_Pago" * 
			CASE T1."U_DocCurr" 
				WHEN 'SOL' THEN 1
				ELSE 
					CASE T1."U_tipDoc" 
						WHEN 'FA' THEN T3."DocRate"
						WHEN 'ND' THEN T3."DocRate"
						WHEN 'NC' THEN T4."DocRate"
					END 
			END AS "PagoMLDC",
		T1."U_tipDoc" AS "TipoDC"
	FROM "@ST_LT_EMILET" T0 
	INNER JOIN "@ST_LT_ELDOCS" T1 ON T0."DocEntry" = T1."DocEntry" 
	LEFT JOIN NNM1 T2 ON T2."Series" = T0."Series"
	LEFT JOIN OINV T3 ON T3."DocEntry" = T1."U_DocEntry"
	LEFT JOIN ORIN T4 ON T4."DocEntry" = T1."U_DocEntry"
	WHERE 
		ISNULL(T1."U_chkSel", '') = 'Y' 
		AND ISNULL(T0."U_DocStat", '') <> 'A' 
		AND T0."U_CardCode" BETWEEN @p_CardCode1 AND @p_CardCode2 
		AND T0."U_EmiDate" BETWEEN @p_FIni AND @p_FFin;

END;
