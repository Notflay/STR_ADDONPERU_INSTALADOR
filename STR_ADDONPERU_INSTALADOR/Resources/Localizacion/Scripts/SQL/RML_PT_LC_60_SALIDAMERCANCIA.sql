CREATE PROCEDURE RML_PT_LC_60_SALIDAMERCANCIA
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    DECLARE @tp NVARCHAR(15);
    DECLARE @sr NVARCHAR(15);
    DECLARE @sNumero NVARCHAR(15);
    DECLARE @iNumero INT;
    DECLARE @Numero NVARCHAR(15);

    -- Variable de retorno para POSTRANSAC
    -- ACTUALIZA CORRELATIVO
    IF @transaction_type = 'A'
    BEGIN
        -- Obtener valores de OIGE
        SELECT @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD 
        FROM OIGE 
        WHERE DocEntry = CAST(@id AS INT);

        -- Convertir y aumentar el número
        SET @iNumero = CAST(@sNumero AS INT) + 1;

        -- Formatear el nuevo número
        SET @Numero = 
        CASE 
            WHEN LEN(@sNumero) >= LEN(CAST(@iNumero AS NVARCHAR(15))) 
            THEN REPLICATE('0', LEN(@sNumero) - LEN(CAST(@iNumero AS NVARCHAR(15)))) + CAST(@iNumero AS NVARCHAR(15)) 
            ELSE CAST(@iNumero AS NVARCHAR(15)) 
        END;

        -- Actualizar el documento
        UPDATE "@BPP_NUMDOC" 
        SET U_BPP_NDCD = @Numero 
        WHERE U_BPP_NDTD = @tp AND U_BPP_NDSD = @sr;
    END;
END;
