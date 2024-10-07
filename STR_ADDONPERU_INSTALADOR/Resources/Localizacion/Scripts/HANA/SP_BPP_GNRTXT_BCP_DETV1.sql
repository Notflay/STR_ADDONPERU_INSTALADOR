CREATE PROCEDURE SP_BPP_GNRTXT_BCP_DETV1
(
    IN DOCENTRY INT
)
LANGUAGE SQLSCRIPT
AS
BEGIN

    CREATE GLOBAL TEMPORARY TABLE tempTable5 (
        "Tipo de Registro" NVARCHAR(1),
        "TipoCuentaAbono" NVARCHAR(1),
        "CuentaCargo" NVARCHAR(20),
        "Modalidad de Pago" NVARCHAR(1),
        "TipoDocIdentidad" NVARCHAR(1),
        "NroDocIdentidad" NVARCHAR(20) PRIMARY KEY,
        "Nombre Beneficiario" NVARCHAR(75),
        "Referencia Beneficiario" NVARCHAR(100),
        "Referencia Empresa" NVARCHAR(100),
        "Moneda" NVARCHAR(4),
        "ImportePago" NVARCHAR(100),
        "Validación" NVARCHAR(1),
        "SortOrder" NVARCHAR(25)
    );
    
   CREATE GLOBAL TEMPORARY TABLE tempImportes (
        "LicTradNum" NVARCHAR(15),
        "ImporteTotal" DECIMAL(14,2)
    );

    -- Calcular la suma de importes por LicTradNum y almacenar en la tabla intermedia
    INSERT INTO tempImportes ("LicTradNum", "ImporteTotal")
    SELECT 
        T1."LicTradNum",
        SUM(T8."U_BPP_MONTOPAG") AS "ImporteTotal"
    FROM "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    WHERE T7."DocEntry" = :DOCENTRY
    GROUP BY T1."LicTradNum";

    INSERT INTO tempTable5 (
        "Tipo de Registro",
        "TipoCuentaAbono",
        "CuentaCargo",
        "Modalidad de Pago",
        "TipoDocIdentidad",
        "NroDocIdentidad",
        "Nombre Beneficiario",
        "Referencia Beneficiario",
        "Referencia Empresa",
        "Moneda",
        "ImportePago",
        "Validación",
        "SortOrder"
    )
    SELECT DISTINCT
        '2' AS "Tipo de Registro",
        LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1) AS "TipoCuentaAbono",
        RPAD(SUBSTRING(T8."U_BPP_CUENBAN", 1, 20), 20, ' ')AS "CuentaCargo",
        '1' AS "Modalidad de Pago",
        LEFT(LTRIM(RTRIM(T1."U_BPP_BPTD")), 1) AS "TipoDocIdentidad",
        RPAD(LTRIM(RTRIM(T1."LicTradNum")), 15, ' ') AS "NroDocIdentidad" ,
        RPAD(T1."CardName", 75, ' ') AS "Nombre Beneficiario", 
        RPAD(('Referencia Beneficiario ' || LTRIM(RTRIM(T1."LicTradNum"))), 40,' ') AS "Referencia Beneficiario",
        RPAD(('Ref Emp ' || LTRIM(RTRIM(T1."LicTradNum"))),20,' ') AS "Referencia Empresa",
        CASE 
            WHEN T8."U_BPP_MONBAN" = 'SOL' THEN '0001'
            WHEN T8."U_BPP_MONBAN" = 'USD' THEN '1001'
        END AS "Moneda",
        LPAD(TO_NVARCHAR(TO_DECIMAL(TI."ImporteTotal", 14, 2)), 17, '0') AS "ImportePago",
        'N' AS "Validación",
        LTRIM(RTRIM(T1."LicTradNum")) || '-000' AS "SortOrder"
    FROM "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    LEFT JOIN tempImportes TI ON T1."LicTradNum" = TI."LicTradNum"
    WHERE T7."U_BPP_ESTADO" != 'Cancelado' 
    AND T7."DocEntry" = :DOCENTRY
    GROUP BY
        T1."LicTradNum",
        T1."CardName",
        T8."U_BPP_CUENBAN",
        TI."ImporteTotal",
        LEFT(LTRIM(RTRIM(T1."BankCtlKey")), 1),
        --LEFT(T7."U_BPP_CUENBAN", 13),
        LEFT(LTRIM(RTRIM(T1."U_BPP_BPTD")), 1),
        LTRIM(RTRIM(T1."LicTradNum")),
        LEFT(T1."CardName", 75),
        'Referencia Beneficiario ' || LTRIM(RTRIM(T1."LicTradNum")),
        'Ref Emp ' || LTRIM(RTRIM(T1."LicTradNum")),
        CASE 
            WHEN T8."U_BPP_MONBAN" = 'SOL' THEN '0001'
            WHEN T8."U_BPP_MONBAN" = 'USD' THEN '1001'
        END;


    CREATE GLOBAL TEMPORARY TABLE tempTable6 (
        "Tipo de Registro" NVARCHAR(1),
        "TipoDocumento" NVARCHAR(1),
        "NroDocumento" NVARCHAR(15) PRIMARY KEY,
        "ImportePagoDoc" NVARCHAR(100),
        "SortOrder" NVARCHAR(25)
    );


    INSERT INTO tempTable6 (
        "Tipo de Registro",
        "TipoDocumento",
        "NroDocumento",
        "ImportePagoDoc",
        "SortOrder"
    )
    SELECT DISTINCT
        '3' AS "Tipo de Registro",
        CASE 
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'F' THEN 'F'
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'B' THEN 'B'
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'N' THEN 'N'
        END AS "TipoDocumento",
        (SELECT LPAD(OP."U_BPP_MDCD", 15, '0') FROM OPCH OP WHERE OP."DocEntry" = T10."DocEntry") AS "NroDocumento", 
        LPAD(TO_NVARCHAR(TO_DECIMAL(T8."U_BPP_MONTOPAG", 14, 2)), 17, '0') AS "ImportePagoDoc",
        LTRIM(RTRIM(T1."LicTradNum")) || '-' || LPAD(ROW_NUMBER() OVER (ORDER BY "U_BPP_TIPODOC"), 3, '0') AS "SortOrder"
    FROM "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    WHERE T7."U_BPP_ESTADO" != 'Cancelado' 
    AND T7."DocEntry" = :DOCENTRY
    GROUP BY 
        T8."U_BPP_MONTOPAG",
        T1."LicTradNum",
        T8."U_BPP_TIPODOC",
        T10."DocEntry";


    SELECT "CombinedData"
    FROM (
        SELECT 
            "Tipo de Registro" || 
            "TipoCuentaAbono" ||
            "CuentaCargo" ||
            "Modalidad de Pago" ||
            "TipoDocIdentidad" ||
            "NroDocIdentidad" ||
            "Nombre Beneficiario" ||
            "Referencia Beneficiario" ||
            "Referencia Empresa" ||
            "Moneda" ||
            "ImportePago" ||
            "Validación" AS "CombinedData",
            "SortOrder"
        FROM tempTable5
        UNION ALL
        SELECT 
            "Tipo de Registro" ||
            "TipoDocumento" ||
            "NroDocumento" ||
            "ImportePagoDoc" AS "CombinedData",
            "SortOrder"
        FROM tempTable6
    )
    ORDER BY "SortOrder";


    DELETE FROM tempTable5;
    DELETE FROM tempTable6;
    DELETE FROM tempImportes;
    DROP TABLE tempTable5;
    DROP TABLE tempTable6;
    DROP TABLE tempImportes;

END;