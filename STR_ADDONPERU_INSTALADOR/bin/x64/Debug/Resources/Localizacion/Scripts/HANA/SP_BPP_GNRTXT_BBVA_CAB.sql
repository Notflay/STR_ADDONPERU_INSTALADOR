CREATE PROCEDURE SP_BPP_GNRTXT_BBVA_CAB
(
  IN DOCENTRY INT
)
AS
BEGIN
    SELECT 
        "Tipo Registro" || --1
        LEFT("Cuenta Cargo", 20) || --2
        "Moneda" || --3
        RIGHT("ImportCargar", 15) || --4
        "Tipo Proceso" || --5
        "Fecha Proceso" || --6
        "Hora Proceso" || --7
        LEFT("Referencia", 24) || --8
        RIGHT("Total Registros", 6) || --9
        "Valida" || --10
        "Vacio"
    AS "PMBBVA_C"
    FROM (
        SELECT 
            '750' AS "Tipo Registro",
            LEFT(T7."U_BPP_CUENBAN", 8) || '00' || RIGHT(T7."U_BPP_CUENBAN", 10) AS "Cuenta Cargo",
            CASE T7."U_BPP_MONEDA"
                WHEN 'SOL' THEN 'PEN'
                ELSE 'USD'
            END AS "Moneda",
            CASE T7."U_BPP_MONEDA"
                WHEN 'SOL' THEN 
                    REPLICATE('0', 15 - LENGTH(REPLACE(CAST(SUM(ROUND(T8."U_BPP_MONTOPAG", 2)) AS NUMERIC(15, 2)), '.', ''))) || '' || REPLACE(CAST(SUM(ROUND(T8."U_BPP_MONTOPAG", 2)) AS NUMERIC(15, 2)), '.', '')
                ELSE
                    REPLICATE('0', 15 - LENGTH(REPLACE(CAST(SUM(ROUND(T8."U_BPP_MONTOPAG", 2)) AS NUMERIC(15, 2)), '.', ''))) || '' || REPLACE(CAST(SUM(ROUND(T8."U_BPP_MONTOPAG", 2)) AS NUMERIC(15, 2)), '.', '')
            END AS "ImportCargar",
            'H' AS "Tipo Proceso",
            TO_VARCHAR(T7."U_BPP_FECEJE", 'YYYYMMDD') AS "Fecha Proceso",
            'B' AS "Hora Proceso",
            'PAGOPROVEEDORESBBVA' || LPAD(' ', 6) AS "Referencia",
            LPAD(COUNT(T8."DocEntry"), 7, '0') AS "Total Registros",
            'S' AS "Valida",
            '000000000000000000' AS "Vacio"
        FROM "@BPP_PAGM_CAB" T7
        INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
        INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"
        WHERE T7."U_BPP_ESTADO" != 'Cancelado'
          AND T7."DocEntry" = :DOCENTRY
        GROUP BY 
            T7."U_BPP_MONEDA", 
            T7."U_BPP_CUENBAN", 
            T7."U_BPP_FECEJE" 

    ) RC;
END;