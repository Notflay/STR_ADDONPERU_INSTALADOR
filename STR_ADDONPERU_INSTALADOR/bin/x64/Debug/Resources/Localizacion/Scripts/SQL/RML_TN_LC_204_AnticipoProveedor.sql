CREATE FUNCTION RML_TN_LC_204_AnticipoProveedor
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @crdCode NVARCHAR(50);
    DECLARE @ctaDetrac NVARCHAR(50);
    DECLARE @Detrac INT;
    DECLARE @v_LocManTran NVARCHAR(10);
    DECLARE @R1 INT;
    DECLARE @R2 INT;

    -- Inicialización de la variable de error
    SET @error_message = '';

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Obtener el CardCode del proveedor
        SELECT TOP 1 @crdCode = CardCode FROM ODPO WHERE DocEntry = @id;

        -- Verificar si existen detracciones
        SELECT TOP 1 @Detrac = COUNT(WTCode) FROM DPO5 WHERE WTCode LIKE 'DT%' AND AbsEntry = @id;

        IF @Detrac > 0
        BEGIN
            -- Obtener la cuenta de detracción
            SELECT TOP 1 @ctaDetrac = COALESCE(U_BPP_CtaDetrac, '') FROM OCRD WHERE CardCode = @crdCode;
            IF @ctaDetrac IS NULL OR @ctaDetrac = ''
            BEGIN
                SET @error_message = 'No se ha definido la cuenta asociada de Detracciones para el socio de necio.';
                RETURN @error_message;
            END;
        END;

        -- Verificar si la cuenta es asociada
        SELECT TOP 1 @v_LocManTran = LocManTran FROM OACT WHERE FormatCode = @ctaDetrac;
        IF @v_LocManTran = 'N'
        BEGIN
            SET @error_message = 'La cuenta del socio de necio definida para el asiento de detracción no es una cuenta asociada.';
            RETURN @error_message;
        END;

        -- Validaciones adicionales
        SELECT @R1 = COUNT(*) 
        FROM ODPO 
        WHERE (ISNULL(U_BPP_MDSD, '') = '' OR ISNULL(U_BPP_MDCD, '') = '') 
        AND DocEntry = @id;

        IF @R1 > 0
        BEGIN
            SET @error_message = 'STR_A: Debe ingresar la serie y el número SUNAT';
            RETURN @error_message;
        END;

        SELECT @R2 = COUNT(*) 
        FROM ODPO 
        WHERE (ISNULL(U_BPP_MDND, '') = '' OR ISNULL(U_BPP_MDFD, '') = '') 
        AND DocEntry = @id 
        AND U_BPP_MDTD = '50';

        IF @R2 > 0
        BEGIN
            SET @error_message = 'STR_A: Ingrese los datos de DUA';
            RETURN @error_message;
        END;

		-- VALIDA SI YA EXISTE EL DOCUMENTO CON EL MISMO TIPO - SERIE - CORRELATIVO
IF @transaction_type = 'A'
		BEGIN
			declare @cc nvarchar(15)
			declare @tp nvarchar(15)
			declare @sr nvarchar(15)
			declare @sNumero nvarchar(15)
			declare @iNumero int
			declare @Numero nvarchar(15)
			SELECT @cc = CardCode, @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD
            FROM ODPO
            WHERE DocEntry = CAST(@id AS INT);

			SET @iNumero = CAST(@sNumero AS INT) + 1;

            SELECT @Numero = 
                CASE
                    WHEN LEN(@sNumero) >= LEN(CAST(@iNumero AS NVARCHAR(15))) 
                    THEN REPLICATE('0', LEN(@sNumero) - LEN(CAST(@iNumero AS NVARCHAR(15)))) + CAST(@iNumero AS NVARCHAR(15))
                    ELSE CAST(@iNumero AS NVARCHAR(15))
                END;

			declare @sNumExist nvarchar(15)
			declare @sTipoExist nvarchar(15)

			set @sNumExist = (select top 1 DocNum from (
					select DocNum as 'DocNum' from OPCH where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL
					select DocNum as 'DocNum' from ORPC where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL					
					select DocNum as 'DocNum' from ODPO where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999') DE)					

			set @sTipoExist = (select top 1 Tipo from (					
					select ObjType as 'Tipo' from OPCH where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL
					select ObjType as 'Tipo' from ORPC where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL					
					select ObjType as 'Tipo' from ODPO where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id and ISNULL(U_BPP_MDSD, '')<>'999') TP)

			
			IF ISNULL(@sNumExist, '') != '' or ISNULL(@sTipoExist, '') != ''
			BEGIN
				SET @error_message='Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' + @sNumExist + ' ObjType: ' + @sTipoExist + ')'
			END
END
		
    END;

    RETURN @error_message;
END;

