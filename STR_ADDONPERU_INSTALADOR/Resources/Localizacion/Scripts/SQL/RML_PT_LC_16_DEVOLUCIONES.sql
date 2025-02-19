CREATE PROCEDURE RML_PT_LC_16_DEVOLUCIONES
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

    -- Al anular la factura con una NC debe mostrar anulado
    IF @transaction_type IN ('A', 'U')
    BEGIN
        UPDATE ODLN 
        SET NumAtCard = '***ANULADO***'
        WHERE DocEntry = (SELECT TOP 1 T2.DocEntry 
                          FROM ODLN T2 
                          INNER JOIN RDN1 T1 ON T2.DocEntry = T1.BaseEntry 
                          INNER JOIN ORDN T3 ON T3.DocEntry = T1.DocEntry
                          WHERE T3.U_BPP_MDSD = '999' AND T3.DocEntry = CAST(@id AS INT));
                          
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 T2.TransId 
                         FROM ODLN T2 
                         INNER JOIN RDN1 T1 ON T2.DocEntry = T1.BaseEntry 
                         INNER JOIN ORDN T3 ON T3.DocEntry = T1.DocEntry
                         WHERE T3.U_BPP_MDSD = '999' AND T3.DocEntry = CAST(@id AS INT));

        -- Modifica el campo "NumAtCard" cuando la NC es anulada
        UPDATE ORDN 
        SET NumAtCard = '***ANULADO***'
        WHERE U_BPP_MDSD = '999' AND DocEntry = CAST(@id AS INT);

        -- ACTUALIZA CORRELATIVO
        IF @transaction_type = 'A'
        BEGIN
            SELECT @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD 
            FROM ORDN 
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
        UPDATE ORDN 
        SET NumAtCard = '***ANULADO***'
        WHERE U_BPP_MDSD = '999' AND DocEntry = CAST(@id AS INT);
    END
END;