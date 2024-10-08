CREATE PROCEDURE STR_SP_DetraccionesXPagar
(
    @ProvD NVARCHAR(50),
    @ProvH NVARCHAR(50),
    @FcCntD NVARCHAR(50),
    @FcCntH NVARCHAR(50),
    @FcVncD NVARCHAR(50),
    @FcVncH NVARCHAR(50),
    @Options NVARCHAR(50),
    @CodSuc NVARCHAR(50)
)
AS
BEGIN
    -- Si la opción no es 'O2', se ejecuta esta parte del procedimiento
    IF @Options <> 'O2'
    BEGIN
        SELECT 
            T2.CardCode + '-' + T2.CardName AS Proveedor,
            T2.CardCode AS Codigo_SN,
            T2.CardName AS Razon_Social,
            'Y' AS Seleccion,
            T0.TransId AS Cod_Transaccion,  
            T1.Line_ID AS Line_ID, 
            CASE T0.U_BPP_CtaTdoc
                WHEN '18' THEN 
                    CASE T0.U_BPP_SubTDoc
                        WHEN '5' THEN 'Nota Débito'
                        WHEN '0' THEN 'Factura' 
                        ELSE 'Factura'
                    END
                WHEN '19' THEN 'Nota Crédito'
                WHEN '204' THEN 'Factura Anticipo'
            END AS Tipo_Doc,
            T0.U_BPP_CtaTdoc AS Cod_Objeto,
            T0.Ref2 AS NumeroDoc,
            T0.TaxDate AS [Fecha de Documento],
            
            -- Cod_Bien basado en el tipo de documento
            CASE T0.U_BPP_CtaTdoc 
                WHEN '18' THEN (SELECT U_BPP_CdBn FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest)
                WHEN '19' THEN (SELECT U_BPP_CdBn FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest)
                WHEN '204' THEN (SELECT U_BPP_CdBn FROM ODPO WHERE DocEntry = T0.U_BPP_DocKeyDest)
            END AS Cod_Bien,
            
            -- Cod_Operacion basado en el tipo de documento
            CASE T0.U_BPP_CtaTdoc 
                WHEN '18' THEN (SELECT U_BPP_CdOp FROM OPCH WHERE DocEntry = T0.U_BPP_DocKeyDest)
                WHEN '19' THEN (SELECT U_BPP_CdOp FROM ORPC WHERE DocEntry = T0.U_BPP_DocKeyDest)
                WHEN '204' THEN (SELECT U_BPP_CdOp FROM ODPO WHERE DocEntry = T0.U_BPP_DocKeyDest)
            END AS Cod_Operacion,

            -- Detracción
            (SELECT WTCode + '-' + WTName FROM OWHT WHERE WTCode = T0.Ref3) AS Detraccion,
            (SELECT WTCode FROM OWHT WHERE WTCode = T0.Ref3) AS Cod_Detraccion,

            -- Importe de detracción
            CASE T0.U_BPP_CtaTdoc
                WHEN '19' THEN -1 * (T1.BalDueDeb + T1.BalDueCred)
                ELSE T1.BalDueDeb + T1.BalDueCred
            END AS Imp_Detraccion,

            -- Importe de detracción redondeado
            CASE T0.U_BPP_CtaTdoc
                WHEN '19' THEN -1 * ROUND(T1.BalDueDeb + T1.BalDueCred, 0)
                ELSE ROUND(T1.BalDueDeb + T1.BalDueCred, 0)
            END AS Imp_Detraccion2,
            '' AS [N de Constancia]
            
        FROM OJDT T0
        INNER JOIN JDT1 T1 ON T0.TransId = T1.TransId
        INNER JOIN OCRD T2 ON T1.ShortName = T2.CardCode
        LEFT OUTER JOIN OPCH T3 ON T0.U_BPP_DocKeyDest = T3.DocEntry 
        LEFT OUTER JOIN ORPC T4 ON T0.U_BPP_DocKeyDest = T4.DocEntry
        WHERE T0.TransCode = 'DTR'
          AND CASE T0.U_BPP_CtaTdoc
                  WHEN '18' THEN T3.U_BPP_MDSD
                  WHEN '19' THEN T4.U_BPP_MDSD
                  ELSE ''
              END <> 'ANL'
          AND (T3.CANCELED = 'N' OR T4.CANCELED = 'N') 
          AND ISNULL(T1.BPLId, 99) = CAST(CASE WHEN @CodSuc = '' THEN '99' ELSE @CodSuc END AS INT)
          AND EXISTS(SELECT 1 FROM OCRD WHERE CardCode = T1.ShortName)
          AND (T1.BalDueDeb + T1.BalDueCred) > 0.0
          AND T0.TransId NOT IN (
              SELECT U_BPP_DEAs
              FROM "@BPP_PAYDTRDET" TDet 
              INNER JOIN "@BPP_PAYDTR" TCab ON TDet.DocEntry = TCab.DocEntry
              WHERE TDet.U_BPP_DEAs = T0.TransId AND TCab.Status = 'O'
          )
          AND (
                (ISNULL(@ProvD, '') = '' AND ISNULL(@ProvH, '') = '')
                OR (ISNULL(@ProvH, '') = '' AND T1.ShortName = @ProvD)
                OR T1.ShortName BETWEEN @ProvD AND @ProvH
          )
          AND (
                (ISNULL(@FcCntD, '') = '' AND ISNULL(@FcCntH, '') = '')
                OR (ISNULL(@FcCntH, '') <> '' AND T0.RefDate BETWEEN @FcCntD AND @FcCntH)
                OR (ISNULL(@FcCntH, '') = '' AND T0.RefDate >= @FcCntD)
          )
          AND (
                (ISNULL(@FcVncD, '') = '' AND ISNULL(@FcVncH, '') = '')
                OR (ISNULL(@FcVncH, '') <> '' AND T0.DueDate BETWEEN @FcVncD AND @FcVncH)
                OR (ISNULL(@FcVncH, '') = '' AND T0.DueDate >= @FcVncD)
          )
        ORDER BY T2.CardCode;
    END
    ELSE
    BEGIN
        SELECT 
            T0.CardCode + '-' + T0.CardName AS Proveedor,
            T0.CardCode AS Codigo_SN,
            T0.CardName AS Razon_Social,
            'N' AS Seleccion,
            T0.DocEntry AS Cod_Transaccion,
            '' AS Line_ID,
            CASE T0.ObjType
                WHEN '18' THEN 'Factura'
                WHEN '19' THEN 'Nota Crédito'
            END AS Tipo_Doc,
            T0.ObjType AS Cod_Objeto,
            T0.NumAtCard AS NumeroDoc,
            T0.TaxDate AS [Fecha de Documento],
            CASE T0.ObjType
                WHEN '18' THEN T0.U_BPP_CdBn
                WHEN '19' THEN (SELECT U_BPP_CdOp FROM ORPC WHERE DocEntry = T0.DocEntry)
            END AS Cod_Bien,
            CASE T0.ObjType
                WHEN '18' THEN T0.U_BPP_CdBn
                WHEN '19' THEN (SELECT U_BPP_CdOp FROM ORPC WHERE DocEntry = T0.DocEntry)
            END AS Cod_Operacion,
            ('Detracción ' + CAST(ROUND(T0.U_STR_TasaDTR, 2) AS NVARCHAR(10)) + ' %') AS Detraccion,
            '' AS Cod_Detraccion,
            T0.DocTotal * (T0.U_STR_TasaDTR / 100) AS Imp_Detraccion,
            ROUND(T0.DocTotal * (T0.U_STR_TasaDTR / 100), 0) AS Imp_Detraccion2,
            '' AS [N de Constancia]
        FROM OPCH T0
        WHERE T0.U_STR_TasaDTR > 0 
          AND (ISNULL(T0.U_STR_DetraccionPago, '') = '' OR T0.U_STR_DetraccionPago = 'N')
          AND T0.CANCELED = 'N' 
          AND T0.DocEntry NOT IN (
              SELECT U_BPP_DEAs
              FROM "@BPP_PAYDTRDET" TDet
              INNER JOIN "@BPP_PAYDTR" TCab ON TDet.DocEntry = TCab.DocEntry
              WHERE TDet.U_BPP_DEAs = T0.DocEntry AND TCab.Status = 'O'
          )
          AND (
                (ISNULL(@ProvD, '') = '' AND ISNULL(@ProvH, '') = '')
                OR (ISNULL(@ProvH, '') = '' AND T0.CardCode = @ProvD)
                OR T0.CardCode BETWEEN @ProvD AND @ProvH
          )
          AND (
                (ISNULL(@FcCntD, '') = '' AND ISNULL(@FcCntH, '') = '')
                OR (ISNULL(@FcCntH, '') <> '' AND T0.DocDate BETWEEN @FcCntD AND @FcCntH)
                OR (ISNULL(@FcCntH, '') = '' AND T0.DocDate >= @FcCntD)
          )
          AND (
                (ISNULL(@FcVncD, '') = '' AND ISNULL(@FcVncH, '') = '')
                OR (ISNULL(@FcVncH, '') <> '' AND T0.DocDueDate BETWEEN @FcVncD AND @FcVncH)
                OR (ISNULL(@FcVncH, '') = '' AND T0.DocDueDate >= @FcVncD)
          )
        ORDER BY T0.CardCode;
    END
END;
GO
