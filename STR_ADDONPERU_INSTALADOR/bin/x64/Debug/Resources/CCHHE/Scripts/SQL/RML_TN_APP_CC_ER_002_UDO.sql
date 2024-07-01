CREATE FUNCTION RML_TN_APP_CC_ER_002_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @cnt INT;
    DECLARE @inct INT;
    SET @error_message = '';
    SET @cnt = 0;
    SET @inct = 0;

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Validaciones de CREACIÓN para EAR
        SELECT @cnt = COUNT(*)
        FROM @STR_EARCRGDET
        WHERE DocEntry = @id 
        AND (ISNULL(U_ER_DIM1, '') = '' 
             OR ISNULL(U_ER_DIM2, '') = '' 
             OR ISNULL(U_ER_DIM3, '') = ''  
             OR ISNULL(U_ER_DIM4, '') = '');
        
        IF @cnt > 0
        BEGIN
            SET @error_message = 'Las dimensiones de Centro de Costos es obligatorio a nivel detalle';
        END
        
        -- Validación de Socio de Necio Inactivo
        SELECT @inct = COUNT(*)
        FROM @STR_EARCRGDET T0 
        INNER JOIN OCRD T1 ON T1.CardCode = T0.U_ER_CDPV 
        WHERE T0.DocEntry = @id 
        AND T1.frozenFor = 'Y'; 
        
        IF @inct > 0
        BEGIN
            SELECT TOP 1 @inct = T1.LineId -- Almacena el número de línea
            FROM @STR_EARCRGDET T1
            INNER JOIN OCRD T0 ON T0.CardCode = T1.U_ER_CDPV
            WHERE T1.DocEntry = @id 
            AND T0.frozenFor = 'Y';
            
            SET @error_message = 'El Socio de Necio de la línea ' + CAST(@inct AS NVARCHAR) + ' se encuentra inactivo';
        END
        
        -- Validación de Partida presupuestal en base al CC - CRP
        /*
        DECLARE @part INT;
        SET @part = 0;

        SELECT @part = COUNT(*)
        FROM @STR_CCHCRGDET 
        WHERE DocEntry = @id 
        AND U_CC_DIM1 <> SUBSTRING(U_CC_CMP1, 7, 3);
        
        IF @part > 0
        BEGIN
            SELECT TOP 1 @part = T1.LineId -- Almacena el número de línea
            FROM @STR_CCHCRGDET T1 
            WHERE T1.DocEntry = @id 
            AND T1.U_CC_DIM1 <> SUBSTRING(T1.U_CC_CMP1, 7, 3);

            SET @error_message = 'La partida ingresada no corresponde al CC seleccionado en la línea ' + CAST(@part AS NVARCHAR);
        END
        */
    END

    RETURN @error_message;
END

