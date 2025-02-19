CREATE PROCEDURE RML_PT_LC_14_NOTACREDITOCLIENTE
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    DECLARE @cc NVARCHAR(15);
    DECLARE @tp NVARCHAR(15);
    DECLARE @sr NVARCHAR(15);
    DECLARE @Numero NVARCHAR(15);
    DECLARE @sNumero NVARCHAR(15);
    DECLARE @iNumero INT;

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Al anular la factura con una NC debe mostrar anulado
        UPDATE OINV 
        SET NumAtCard = '***ANULADO***', Indicator = 'ZA'
        WHERE DocEntry = (SELECT TOP 1 T2.DocEntry FROM OINV T2 
                          INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                          INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                          WHERE T3.U_BPP_MDSD = '999' AND T1.BaseType = '13' AND T3.DocEntry = CAST(@id AS INT));

        UPDATE ODPI 
        SET NumAtCard = '***ANULADO***', Indicator = 'ZA'
        WHERE DocEntry = (SELECT TOP 1 T2.DocEntry FROM ODPI T2 
                          INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                          INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                          WHERE T3.U_BPP_MDSD = '999' AND T1.BaseType = '203' AND T3.DocEntry = CAST(@id AS INT)); 

        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 T2.TransId FROM OINV T2 
                         INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                         INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                         WHERE T3.U_BPP_MDSD = '999' AND T1.BaseType = '13' AND T3.DocEntry = CAST(@id AS INT));

        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 T2.TransId FROM ODPI T2 
                         INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                         INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                         WHERE T3.U_BPP_MDSD = '999' AND T1.BaseType = '203' AND T3.DocEntry = CAST(@id AS INT));

        -- Modifica el campo "NumAtCard" cuando la NC es anulada
        UPDATE ORIN 
        SET NumAtCard = '***ANULADO***'
        WHERE U_BPP_MDSD = '999' AND DocEntry = CAST(@id AS INT);

        -- Actualiza campos de documentos de origen
        UPDATE ORIN 
        SET U_BPP_MDCO = CASE (SELECT TOP 1 BaseType FROM RIN1 WHERE DocEntry = CAST(@id AS INT))
                            WHEN '13' THEN (SELECT TOP 1 T2.U_BPP_MDCD FROM OINV T2 
                                            INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                            INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                            WHERE T3.DocEntry = CAST(@id AS INT))
                            WHEN '203' THEN (SELECT TOP 1 T2.U_BPP_MDCD FROM ODPI T2 
                                             INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                             INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                             WHERE T3.DocEntry = CAST(@id AS INT))
                         END,
            U_BPP_MDSO = CASE (SELECT TOP 1 BaseType FROM RIN1 WHERE DocEntry = CAST(@id AS INT))
                            WHEN '13' THEN (SELECT TOP 1 T2.U_BPP_MDSD FROM OINV T2 
                                            INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                            INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                            WHERE T3.DocEntry = CAST(@id AS INT))
                            WHEN '203' THEN (SELECT TOP 1 T2.U_BPP_MDSD FROM ODPI T2 
                                             INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                             INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                             WHERE T3.DocEntry = CAST(@id AS INT))
                         END,
            U_BPP_MDTO = CASE (SELECT TOP 1 BaseType FROM RIN1 WHERE DocEntry = CAST(@id AS INT))
                            WHEN '13' THEN (SELECT TOP 1 T2.U_BPP_MDTD FROM OINV T2 
                                            INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                            INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                            WHERE T3.DocEntry = CAST(@id AS INT))
                            WHEN '203' THEN (SELECT TOP 1 T2.U_BPP_MDTD FROM ODPI T2 
                                             INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                             INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                             WHERE T3.DocEntry = CAST(@id AS INT))
                         END,
            U_BPP_SDocDate = CASE (SELECT TOP 1 BaseType FROM RIN1 WHERE DocEntry = CAST(@id AS INT))
                                WHEN '13' THEN (SELECT TOP 1 T2.DocDate FROM OINV T2 
                                                INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                                INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                                WHERE T3.DocEntry = CAST(@id AS INT))
                                WHEN '203' THEN (SELECT TOP 1 T2.DocDate FROM ODPI T2 
                                                 INNER JOIN RIN1 T1 ON T2.DocEntry = T1.BaseEntry
                                                 INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
                                                 WHERE T3.DocEntry = CAST(@id AS INT))
                             END
        WHERE DocEntry = CAST(@id AS INT) AND U_BPP_MDTD = '07'
          AND ISNULL((SELECT TOP 1 BaseType FROM RIN1 WHERE DocEntry = CAST(@id AS INT)), '-1') NOT IN ('-1', '16');

        -- Concatenar el NumAtCard
        UPDATE ORIN 
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, ''), 
            FolioNum = 0
        WHERE DocEntry = @id;

        UPDATE OJDT 
        SET Ref2 = (SELECT NumAtCard FROM ORIN WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ORIN WHERE DocEntry = @id);

        UPDATE JDT1 
        SET Ref2 = (SELECT NumAtCard FROM ORIN WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ORIN WHERE DocEntry = @id);

        -- Actualiza correlativo
        IF @transaction_type = 'A'
        BEGIN
            SELECT @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD 
            FROM ORIN 
            WHERE DocEntry = CAST(@id AS INT);

            SET @iNumero = CAST(@sNumero AS INT);
            SET @iNumero = @iNumero + 1;

            SET @Numero = CASE 
                            WHEN LEN(@sNumero) >= LEN(CAST(@iNumero AS NVARCHAR(15))) 
                            THEN REPLICATE('0', LEN(@sNumero) - LEN(CAST(@iNumero AS NVARCHAR(15)))) + CAST(@iNumero AS NVARCHAR(15)) 
                            ELSE CAST(@iNumero AS NVARCHAR(15)) 
                          END;

            UPDATE "@BPP_NUMDOC" 
            SET U_BPP_NDCD = @Numero 
            WHERE U_BPP_NDTD = @tp AND U_BPP_NDSD = @sr;
        END
    END

    IF @transaction_type = 'C'
    BEGIN
        UPDATE ORIN 
        SET NumAtCard = '***ANULADO***'
        WHERE U_BPP_MDSD = '999' AND DocEntry = CAST(@id AS INT);
    END
END;