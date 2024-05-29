CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_PROVEEDORES
    @FECHAINI DATE,
    @FECHAFIN DATE,
    @CODPROVEEDOR NVARCHAR(20),
    @MONEDA NVARCHAR(20),
    @FECHAVINI DATE,
    @FECHAVFIN DATE
AS
BEGIN
    SELECT 
        T3.CardCode AS CodigoProveedor,
        T3.CardName AS NombreProveedor,
        T3.DocEntry AS NumeroSAP,
        T3.DocCur AS Moneda,
        T3.DocDate AS FechaContabilizacion,
        T3.TaxDate AS FechaDocumento,
        T3.DocDueDate AS FechaVencimiento,
        CONCAT(T3.U_BPP_MDTD, '-', T3.U_BPP_MDSD, '-', T3.U_BPP_MDCD) AS NumeroDocumento,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal ELSE T3.DocTotalFC END AS ImporteDoc,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal - T3.PaidSum ELSE T3.DocTotalFC - T3.PaidSumFc END AS MontoPago,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal - T3.PaidSum ELSE T3.DocTotalFC - T3.PaidSumFc END AS Saldo,
        ISNULL(T3.DocCur, '') AS Moneda,
        'Factura' AS TipoDocumento,
        T3.CardCode AS CodigoProveedor,
        T3.CardName AS NombreProveedor,
        T4.LicTradNum AS RUC,
        T5.AcctName AS NombreBanco,
        T5.Account AS CuentaBanco,
        T5.U_BPP_MONEDA AS MonedaBanco,
        T3.ObjType,
		T7."InstlmntID" AS "NumeroCuota",
		CAST(T7."InstlmntID" AS NVARCHAR(10)) + ' de ' + CAST(T3."Installmnt" AS NVARCHAR(10)) AS "NombreCuota",
		CASE WHEN T3."Installmnt" > 1 THEN CASE WHEN T3."DocCur" = 'SOL' THEN ISNULL(T7."WTSum", 0) 
                ELSE ISNULL(T7."WTSumFC", 0) 
            END 
        ELSE
            CASE 
                WHEN T3."DocCur" = 'SOL' THEN ISNULL(T3."WTSum", 0) 
                ELSE ISNULL(T3."WTSumFC", 0) 
            END 
        END AS "ImporteRetencion",
        CASE WHEN ISNULL( T8.AbsEntry,0) = 0  THEN 'No Aplica' ELSE 'Si aplica' END AS "DetraccionPago"
    FROM 
        OPCH T3 
     -- INNER 
	 LEFT JOIN 
        OCRD T4 ON T3.CardCode = T4.CardCode
    LEFT JOIN 
        OCRB T5 ON T4.BankCode = T5.BankCode AND T4.CardCode = T5.CardCode AND T5.U_BPP_MONEDA = @MONEDA
    LEFT JOIN 
        (SELECT DISTINCT T1.U_BPP_NUMSAP 
         FROM [@BPP_PAGM_DET1] T1
        --INNER 
		 LEFT JOIN [@BPP_PAGM_CAB] T2 ON T1.DocEntry = T2.DocEntry 
         WHERE T2.U_BPP_ESTADO IN ('Procesado','Creado') 
        ) T6 ON T3.DocEntry = T6.U_BPP_NUMSAP
	LEFT JOIN PCH6 T7 ON T3."DocEntry" = T7."DocEntry"
    LEFT JOIN PCH5 T8 ON T3."DocEntry" = T8."AbsEntry"
   WHERE 
        T3.TaxDate >= CASE WHEN @FECHAINI = '' THEN T3.TaxDate ELSE @FECHAINI END 
        AND T3.TaxDate <= CASE WHEN @FECHAFIN = '' THEN T3.TaxDate ELSE @FECHAFIN END 
        AND T3.DocDueDate >= CASE WHEN @FECHAVINI = '' THEN T3.DocDueDate ELSE @FECHAVINI END 
        AND T3.DocDueDate <= CASE WHEN @FECHAVFIN = '' THEN T3.DocDueDate ELSE @FECHAVFIN END 
        AND T3.CardCode = CASE WHEN @CODPROVEEDOR = '' THEN T3.CardCode ELSE @CODPROVEEDOR END 
        AND T3.DocTotal - T3.PaidSum != 0 
        AND T3.DocCur = @MONEDA
        AND T3.CANCELED = 'N' and t3.DocStatus != 'C'
        AND ISNULL(T6.U_BPP_NUMSAP, 0) = 0 
		--AND T3.DocEntry = 151516
	UNION ALL
		 SELECT 
        T3.CardCode AS CodigoProveedor,
        T3.CardName AS NombreProveedor,
        T3.DocEntry AS NumeroSAP,
        T3.DocCur AS Moneda,
        T3.DocDate AS FechaContabilizacion,
        T3.TaxDate AS FechaDocumento,
        T3.DocDueDate AS FechaVencimiento,
        CONCAT(T3.U_BPP_MDTD, '-', T3.U_BPP_MDSD, '-', T3.U_BPP_MDCD) AS NumeroDocumento,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal ELSE T3.DocTotalFC END AS ImporteDoc,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal - T3.PaidSum ELSE T3.DocTotalFC - T3.PaidSumFc END AS MontoPago,
        CASE WHEN T3.DocCur = 'SOL' THEN T3.DocTotal - T3.PaidSum ELSE T3.DocTotalFC - T3.PaidSumFc END AS Saldo,
        ISNULL(T3.DocCur, '') AS Moneda,
        'Factura' AS TipoDocumento,
        T3.CardCode AS CodigoProveedor,
        T3.CardName AS NombreProveedor,
        T4.LicTradNum AS RUC,
        T5.AcctName AS NombreBanco,
        T5.Account AS CuentaBanco,
        T5.U_BPP_MONEDA AS MonedaBanco,
        T3.ObjType,
		T7."InstlmntID" AS "NumeroCuota",
		CAST(T7."InstlmntID" AS NVARCHAR(10)) + ' de ' + CAST(T3."Installmnt" AS NVARCHAR(10)) AS "NombreCuota",
		CASE WHEN T3."Installmnt" > 1 THEN CASE WHEN T3."DocCur" = 'SOL' THEN ISNULL(T7."WTSum", 0) 
                ELSE ISNULL(T7."WTSumFC", 0) 
            END 
        ELSE
            CASE 
                WHEN T3."DocCur" = 'SOL' THEN ISNULL(T3."WTSum", 0) 
                ELSE ISNULL(T3."WTSumFC", 0) 
            END 
        END AS "ImporteRetencion",
        CASE WHEN ISNULL( T8.AbsEntry,0) = 0  THEN 'No Aplica' ELSE 'Si aplica' END AS "DetraccionPago"
    FROM 
        ODPO T3 
     -- INNER 
	 LEFT JOIN 
        OCRD T4 ON T3.CardCode = T4.CardCode
    LEFT JOIN 
        OCRB T5 ON T4.BankCode = T5.BankCode AND T4.CardCode = T5.CardCode AND T5.U_BPP_MONEDA = @MONEDA
    LEFT JOIN 
        (SELECT DISTINCT T1.U_BPP_NUMSAP 
         FROM [@BPP_PAGM_DET1] T1
        --INNER 
		 LEFT JOIN [@BPP_PAGM_CAB] T2 ON T1.DocEntry = T2.DocEntry 
         WHERE T2.U_BPP_ESTADO IN ('Procesado','Creado') 
        ) T6 ON T3.DocEntry = T6.U_BPP_NUMSAP
	LEFT JOIN PCH6 T7 ON T3."DocEntry" = T7."DocEntry"
    LEFT JOIN PCH5 T8 ON T3."DocEntry" = T8."AbsEntry"
   WHERE 
        T3.TaxDate >= CASE WHEN @FECHAINI = '' THEN T3.TaxDate ELSE @FECHAINI END 
        AND T3.TaxDate <= CASE WHEN @FECHAFIN = '' THEN T3.TaxDate ELSE @FECHAFIN END 
        AND T3.DocDueDate >= CASE WHEN @FECHAVINI = '' THEN T3.DocDueDate ELSE @FECHAVINI END 
        AND T3.DocDueDate <= CASE WHEN @FECHAVFIN = '' THEN T3.DocDueDate ELSE @FECHAVFIN END 
        AND T3.CardCode = CASE WHEN @CODPROVEEDOR = '' THEN T3.CardCode ELSE @CODPROVEEDOR END 
        AND T3.DocTotal - T3.PaidSum != 0 
        AND T3.DocCur = @MONEDA
        AND T3.CANCELED = 'N' and t3.DocStatus != 'C'
        AND ISNULL(T6.U_BPP_NUMSAP, 0) = 0 
		--AND T3.DocEntry = 151516
   ORDER BY 
        T3.DocDate DESC;
END