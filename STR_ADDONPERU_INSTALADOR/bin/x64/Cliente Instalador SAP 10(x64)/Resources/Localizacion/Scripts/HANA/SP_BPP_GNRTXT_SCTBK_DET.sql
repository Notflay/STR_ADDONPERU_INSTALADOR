CREATE PROCEDURE SP_BPP_GNRTXT_SCTBK_DET
(
    IN DOCENTRY INT
)
AS
BEGIN

    CREATE GLOBAL TEMPORARY TABLE RD (
        "RUC" NVARCHAR(11),
        "NombreProveedor" NVARCHAR(60),
        "Factura" NVARCHAR(14),
        "Fecha" NVARCHAR(8),
        "MontoPagar" NVARCHAR(11),
        "FormaPago" NVARCHAR(1),
        "Cuenta" NVARCHAR(10),
        "Correo" NVARCHAR(30),
        "CCI" NVARCHAR(20)
    );

    INSERT INTO RD (
        "RUC",
        "NombreProveedor",
        "Factura",
        "Fecha",
        "MontoPagar",
        "FormaPago",
        "Cuenta",
        "Correo",
        "CCI"
    )
    SELECT
    RPAD(LTRIM(RTRIM(T1."LicTradNum")), 11) AS "RUC",
    RPAD(UPPER(T1."CardName"), 60) AS "NombreProveedor",
    RPAD(SUBSTR(T10."U_BPP_MDSD" || T10."U_BPP_MDCD", 1, 14), 14) AS "Factura",
    TO_VARCHAR(T10."DocDate", 'YYYYMMDD') AS "Fecha",
    CASE 
        WHEN T8."U_BPP_MONTOPAG" IS NULL OR T8."U_BPP_MONTOPAG" = 0 THEN '0'
        ELSE RIGHT(LPAD(CAST(ROUND(T8."U_BPP_MONTOPAG", 2) * 100 AS INT), 11, '0'), 11)
    END AS "MontoPagar",
    CASE 
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) IN ('I','B') THEN '4'
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) = 'C' THEN '2'
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) = 'A' THEN '3'
    END AS "FormaPago",
    CASE 
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) IN ('C', 'A') THEN RPAD(T8."U_BPP_CUENBAN", 10)
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) IN ('I','B') THEN LPAD('', 10) 
    END AS "Cuenta",
    RIGHT(SUBSTRING(UPPER(IFNULL(T1."E_Mail", '')) || LPAD('', 30), 1, 30), 30) AS "Correo",
    CASE 
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) IN ('C', 'A') THEN LPAD('', 20)
        WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) IN ('I','B') THEN LPAD(T8."U_BPP_CUENBAN", 20)
    END AS "CCI"
    FROM "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    WHERE T7."U_BPP_ESTADO" != 'Cancelado' AND T7."DocEntry" = :DOCENTRY;

    SELECT
        "RUC" ||
        "NombreProveedor" ||
        "Factura" ||
        "Fecha" ||
        "MontoPagar" ||
        "FormaPago" ||
        "Cuenta" || 
        ' ' ||
        "Correo" ||
        ' ' ||
        "CCI" AS PMSCOT_D
    FROM RD;

    DELETE FROM RD; 
    DROP TABLE RD; 

END;


