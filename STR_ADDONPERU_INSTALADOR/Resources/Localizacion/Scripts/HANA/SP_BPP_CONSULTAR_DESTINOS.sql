CREATE PROCEDURE "SP_BPP_CONSULTAR_DESTINOS"
(
    PERIODO INT
)
AS
BEGIN
    DECLARE FECHAINI DATE;
    DECLARE FECHAFIN DATE;
    DECLARE OCRCODE VARCHAR(20);
    
    -- Obtener fechas de inicio y fin del periodo desde la tabla OFPR
    SELECT "F_RefDate", "T_RefDate" INTO FECHAINI, FECHAFIN FROM OFPR WHERE "AbsEntry" = PERIODO;
    
    -- Obtener el código de segmento de contabilidad desde la tabla "@BPP_PARAMS"
    SELECT "U_STR_OcrCode" INTO OCRCODE FROM "@BPP_PARAMS";
    
    -- Consulta principal para seleccionar datos de cuentas contables
    SELECT 
        T0."TransId" AS "AsientoOrigen",
        T0."Line_ID" AS "linOrigen",
        
        CASE 
            WHEN :OCRCODE = '2' THEN (CASE WHEN LEFT(T0."OcrCode2",'1') NOT IN('9','6')  THEN T3."U_STR_LC_CDST"  ELSE T0."OcrCode2" END)
            WHEN :OCRCODE = '3' THEN (CASE WHEN LEFT(T0."OcrCode3",'1') NOT IN('9','6')   THEN T3."U_STR_LC_CDST"  ELSE T0."OcrCode3" END)
            WHEN :OCRCODE = '4' THEN (CASE WHEN LEFT(T0."OcrCode4",'1') NOT IN('9','6')  THEN T3."U_STR_LC_CDST"  ELSE T0."OcrCode4" END)
            ELSE (CASE WHEN LEFT(T0."OcrCode5",'1') <> '9' THEN T3."U_STR_LC_CDST"  ELSE T0."OcrCode5" END)
        END AS "CuentaDestino",
        T1."FormatCode" AS "CuentaNaturaleza",
        CASE 
            WHEN T0."DebCred" = 'C' THEN -IFNULL(T0."Credit", 0) 
            ELSE IFNULL(T0."Debit", 0) 
        END AS "MontoLocal",
        CASE 
            WHEN T0."DebCred" = 'C' THEN -IFNULL(T0."FCCredit", 0) 
            ELSE IFNULL(T0."FCDebit", 0) 
        END AS "MontoExtranjero",
        CASE 
            WHEN T0."DebCred" = 'C' THEN -IFNULL(T0."SYSCred", 0) 
            ELSE IFNULL(T0."SYSDeb", 0) 
        END AS "MontoSistema",
        IFNULL(T0."FCCurrency", 'SOL') AS "Moneda",
        T0."RefDate" AS "FechaContabilizacion",
        T0."TaxDate" AS "FechaDocumento",
        T0."DueDate" AS "FechaVencimiento",
        CASE 
            WHEN T0."TransType" = '46' THEN 'PP'
            WHEN T0."TransType" = '321' THEN 'ID'
            WHEN T0."TransType" = '24' THEN 'PR'
            WHEN T0."TransType" = '30' THEN 'AS'
            WHEN T0."TransType" = '18' THEN 'TT'
            WHEN T0."TransType" = '19' THEN 'AC'
            WHEN T0."TransType" = '59' THEN 'EM'
            WHEN T0."TransType" = '60' THEN 'SM'
            WHEN T0."TransType" = '69' THEN 'DI'
            WHEN T0."TransType" = '13' THEN 'RF'
            ELSE T0."TransType" 
        END || ' ' || T0."BaseRef" AS "Referencia",
        T0."Ref2" AS "Referencia2",
        T2."Memo" AS "Comentarios",
        IFNULL(T0."ProfitCode", '') AS "CC1",
        IFNULL(T0."OcrCode2", '') AS "CC2",
        IFNULL(T0."OcrCode3", '') AS "CC3",
        IFNULL(T0."OcrCode4", '') AS "CC4",
        IFNULL(T0."OcrCode5", '') AS "CC5"
    FROM 
        JDT1 T0 
        INNER JOIN OACT T1 ON T1."AcctCode" = T0."Account" AND LEFT(T1."FormatCode", 2) IN ('62', '63', '64', '65', '66', '67', '68','76')
        INNER JOIN OJDT T2 ON T0."TransId" = T2."TransId"	
        LEFT JOIN OOCR T3 ON 
        (
            (:OCRCODE = '2' AND T3."OcrCode" = T0."OcrCode2") OR
            (:OCRCODE = '3' AND T3."OcrCode" = T0."OcrCode3") OR
            (:OCRCODE = '4' AND T3."OcrCode" = T0."OcrCode4") OR
            (:OCRCODE = '5' AND T3."OcrCode" = T0."OcrCode5") 
        )
    WHERE 
        T0."RefDate" >= FECHAINI AND T0."RefDate" <= FECHAFIN
        AND (
            (IFNULL(T0."Debit", 0) - IFNULL(T0."Credit", 0)) <> 0 
            OR (IFNULL(T0."FCDebit", 0) - IFNULL(T0."FCCredit", 0)) <> 0 
            OR (IFNULL(T0."SYSDeb", 0) - IFNULL(T0."SYSCred", 0)) <> 0
        )
        AND IFNULL(
            CASE 
                WHEN :OCRCODE = '2' THEN T0."OcrCode2" 
                WHEN :OCRCODE = '3' THEN T0."OcrCode3" 
                WHEN :OCRCODE = '4' THEN T0."OcrCode4" 
                ELSE T0."OcrCode5" 
            END, ''
        ) != ''
    ORDER BY 1 DESC;
END