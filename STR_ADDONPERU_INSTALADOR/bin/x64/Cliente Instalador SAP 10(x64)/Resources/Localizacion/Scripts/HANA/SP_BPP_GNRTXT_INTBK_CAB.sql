CREATE PROCEDURE SP_BPP_GNRTXT_INTBK_CAB 
(
    IN DOCENTRY INT
)
LANGUAGE SQLSCRIPT
AS
BEGIN

    DECLARE TotalRegistros NVARCHAR(6);
    DECLARE TotalSoles NVARCHAR(15);
    DECLARE TotalDolares NVARCHAR(15);
    DECLARE TipoRegistro NVARCHAR(40);
    DECLARE Fecha NVARCHAR(8);
    DECLARE Desconocido NVARCHAR(15);
    DECLARE Referencia NVARCHAR(5);
    DECLARE PMGINTBK_C NVARCHAR(200);

    -- Calcular el total de registros
    SELECT LPAD(COUNT(T8."DocEntry"), 6, '0') INTO TotalRegistros
    FROM "@BPP_PAGM_DET1" T8
    WHERE T8."DocEntry" = DOCENTRY;

    -- Calcular el total en soles
    SELECT LPAD(CAST(SUM(IFNULL(T8."U_BPP_MONTOPAG", 0)) * 100 AS NVARCHAR), 15, '0') INTO TotalSoles
    FROM "@BPP_PAGM_DET1" T8
    WHERE T8."U_BPP_MONEDA" = 'SOL' AND T8."DocEntry" = DOCENTRY;

    -- Calcular el total en dólares
    SELECT LPAD(COALESCE(CAST(SUM(IFNULL(T8."U_BPP_MONTOPAG", 0)) * 100 AS NVARCHAR), '0'), 15, '0') INTO TotalDolares
    FROM "@BPP_PAGM_DET1" T8
    WHERE T8."U_BPP_MONEDA" = 'USD' AND T8."DocEntry" = DOCENTRY;

    -- Seleccionar y asignar los valores
    SELECT 
        '0103' || RPAD('', 36, ' ') AS TipoRegistro,
        TO_VARCHAR(T7.U_BPP_FECEJE, 'YYYYMMDD') AS Fecha,
        RPAD('', 15, ' ') AS Desconocido,
        'MC001' AS Referencia
    INTO TipoRegistro, Fecha, Desconocido, Referencia
    FROM "@BPP_PAGM_CAB" T7
    WHERE T7."DocEntry" = DOCENTRY
    GROUP BY T7.U_BPP_FECEJE;

    -- Concatenar el resultado final
    PMGINTBK_C := TipoRegistro ||  
                  Fecha || 
                  Desconocido ||
                  TotalRegistros || 
                  TotalSoles || 
                  TotalDolares ||
                  Referencia;

    -- Retornar el resultado
    SELECT PMGINTBK_C AS PMGINTBK_C FROM DUMMY;

END;
