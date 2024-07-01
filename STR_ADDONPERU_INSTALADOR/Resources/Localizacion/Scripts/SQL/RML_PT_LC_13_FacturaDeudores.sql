CREATE PROCEDURE RML_PT_LC_13_FacturaDeudores
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
        -- Actualizar NumAtCard y FolioNum en OINV
        UPDATE OINV 
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, ''), 
            FolioNum = 0
        WHERE DocEntry = @id;

        -- Actualizar Ref2 en OJDT y JDT1
        UPDATE OJDT 
        SET Ref2 = (SELECT NumAtCard FROM OINV WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM OINV WHERE DocEntry = @id);

        UPDATE JDT1 
        SET Ref2 = (SELECT NumAtCard FROM OINV WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM OINV WHERE DocEntry = @id);

        -- Actualizar correlativo
        IF @transaction_type = 'A'
        BEGIN
            SELECT @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD 
            FROM OINV 
            WHERE DocEntry = CAST(@id AS INT);

            SET @iNumero = CAST(@sNumero AS INT);
            SET @iNumero = @iNumero + 1;

            SET @Numero = CASE 
                            WHEN LEN(@sNumero) >= LEN(CAST(@iNumero AS NVARCHAR(15))) 
                            THEN REPLICATE('0', LEN(@sNumero) - LEN(CAST(@iNumero AS NVARCHAR(15)))) + CAST(@iNumero AS NVARCHAR(15)) 
                            ELSE CAST(@iNumero AS NVARCHAR(15)) 
                          END;
	
            UPDATE @BPP_NUMDOC 
            SET U_BPP_NDCD = @Numero 
            WHERE U_BPP_NDTD = @tp AND U_BPP_NDSD = @sr;
        END
    END

    IF @transaction_type = 'C'
    BEGIN
        -- Anular documento
        UPDATE OINV 
        SET NumAtCard = '***ANULADO***', Indicator = 'ZA'
        WHERE DocEntry = CAST(@id AS INT);

        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 TransId FROM OINV WHERE DocEntry = CAST(@id AS INT));
    END
END;