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
        'SOL' AS MonedaBanco,
        T3.ObjType
    FROM 
        OPCH T3 
    INNER JOIN 
        OCRD T4 ON T3.CardCode = T4.CardCode
    LEFT JOIN 
        OCRB T5 ON T4.BankCode = T5.BankCode AND T4.CardCode = T5.CardCode
    LEFT JOIN 
        (SELECT DISTINCT T1.U_BPP_NUMSAP 
         FROM [@BPP_PAGM_DET1] T1
         INNER JOIN [@BPP_PAGM_CAB] T2 ON T1.DocEntry = T2.DocEntry 
         WHERE T2.U_BPP_ESTADO IN ('Cancelado', 'Creado', 'Procesado')
        ) T6 ON T3.DocEntry = T6.U_BPP_NUMSAP
    WHERE 
        T3.TaxDate >= CASE WHEN @FECHAINI = '' THEN T3.TaxDate ELSE @FECHAINI END 
        AND T3.TaxDate <= CASE WHEN @FECHAFIN = '' THEN T3.TaxDate ELSE @FECHAFIN END 
        AND T3.DocDueDate >= CASE WHEN @FECHAVINI = '' THEN T3.DocDueDate ELSE @FECHAVINI END 
        AND T3.DocDueDate <= CASE WHEN @FECHAVFIN = '' THEN T3.DocDueDate ELSE @FECHAVFIN END 
        AND T3.CardCode = CASE WHEN @CODPROVEEDOR = '' THEN T3.CardCode ELSE @CODPROVEEDOR END 
        AND T3.DocTotal - T3.PaidSum != 0
        AND T3.DocCur = @MONEDA
        AND T3.CANCELED = 'N'
        AND ISNULL(T6.U_BPP_NUMSAP, 0) = 0
    ORDER BY 
        T3.DocDate DESC;
END
