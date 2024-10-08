CREATE PROCEDURE SP_BPP_GNRTXT_BCP_CAB
(
    IN DOCENTRY INT
)
LANGUAGE SQLSCRIPT
AS

TotalControl NVARCHAR(15);
TotalCargo NVARCHAR(15);
TotalAbono NVARCHAR(15);

BEGIN

    /*SELECT 
          LPAD (CAST(substring(T7."U_BPP_CUENBAN",4,LENGTH(T7."U_BPP_CUENBAN"))AS DECIMAL) +
          SUM (DISTINCT CAST(substring(T8."U_BPP_CUENBAN",4,LENGTH(T8."U_BPP_CUENBAN"))AS DECIMAL)),15,0) INTO total_control
     FROM 
    "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"
     WHERE 
    T7."DocEntry" = :DOCENTRY
    GROUP BY
    T7."U_BPP_CUENBAN";*/
    
   -- Calcular TotalAbono
   SELECT SUM("TOTAL") "TOTALES" INTO TotalAbono FROM (SELECT DISTINCT 
   CASE 
       WHEN T1."BankCtlKey" = 'B' THEN
        CAST( SUBSTRING(T8."U_BPP_CUENBAN", 11, LENGTH(T8."U_BPP_CUENBAN"))AS DECIMAL)
       ELSE 
        CAST(  SUBSTRING(T8."U_BPP_CUENBAN", 4, LENGTH(T8."U_BPP_CUENBAN"))AS DECIMAL)
    END "TOTAL"

    FROM 
    "@BPP_PAGM_CAB" T7
    INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
    INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
    INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"
    WHERE 
    T7."DocEntry" = :DOCENTRY );
    
    -- Calcular TotalCargo
    SELECT
        LPAD(CAST(SUBSTRING(T7."U_BPP_CUENBAN", 4, LENGTH(T7."U_BPP_CUENBAN"))AS DECIMAL),15,0) INTO TotalCargo
    FROM 
        "@BPP_PAGM_CAB" T7
        INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
        INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
        INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"
    WHERE 
        T7."DocEntry" = :DOCENTRY
    LIMIT 1;


    --Calcular TotalControl
    TotalControl := LPAD(
        CAST(CAST(TotalAbono AS DECIMAL) + CAST(TotalCargo AS DECIMAL) AS NVARCHAR(15)), 
        15, '0'
    );

    -- Generar la salida final
    SELECT 
        "Tipo Registro"       ||  --1
        "Cantidad Abonos"     ||  --2
        "Fecha Proceso"       ||  --3
        "TipoCuentaCargo"     ||  --4
        "Moneda"              ||  --5
        "CuentaCargo"         ||  --6
        "MontoPlantilla"      ||  --7
        "Referencia"          ||  --8
        "Exonera ITF"         ||  --9
        "Total Control"          --10
    AS "PMBCP_C"
    FROM (         
        SELECT DISTINCT
            '1' AS "Tipo Registro",
            LPAD(CAST(COUNT(DISTINCT T8."U_BPP_CODPROV") AS VARCHAR(6)), 6, '0') AS "Cantidad Abonos",
            TO_VARCHAR(T7."U_BPP_FECEJE", 'YYYYMMDD') AS "Fecha Proceso",
            LEFT(LTRIM(RTRIM(T9."UsrNumber1")), 1) AS "TipoCuentaCargo",
            CASE 
                WHEN T7."U_BPP_MONEDA" = 'SOL' THEN '0001'
                WHEN T7."U_BPP_MONEDA" = 'USD' THEN '1001'
            END AS "Moneda",
            RPAD(SUBSTRING(T7."U_BPP_CUENBAN", 1, 20), 20, ' ') AS "CuentaCargo",
            RIGHT('00000000000000000' || TO_VARCHAR(TO_DECIMAL(SUM(T8."U_BPP_MONTOPAG"), 5, 2)), 17) AS "MontoPlantilla",
            RPAD('PAGOPROVEEDORESBCP', 40, ' ') AS "Referencia",
            'S' AS "Exonera ITF",
            TotalControl AS "Total Control"
            --'TotalControl'  AS "Total Control"
        FROM 
            "@BPP_PAGM_CAB" T7
        INNER JOIN 
            "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
        INNER JOIN 
            "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
        INNER JOIN 
            "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"
        WHERE 
            T7."U_BPP_ESTADO" != 'Cancelado' 
            AND T7."DocEntry" = :DOCENTRY
        GROUP BY 
            T7."U_BPP_MONEDA",
            T9."UsrNumber1", 
            T7."U_BPP_CUENBAN",  
            T7."U_BPP_FECEJE"
    ) RC;
END;