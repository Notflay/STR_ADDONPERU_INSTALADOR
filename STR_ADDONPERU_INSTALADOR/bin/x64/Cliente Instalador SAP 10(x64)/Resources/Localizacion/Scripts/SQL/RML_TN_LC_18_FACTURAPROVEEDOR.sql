CREATE FUNCTION RML_TN_LC_18_FACTURAPROVEEDOR
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R1 INT;
    DECLARE @R2 INT;

    SET @error_message = '';

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Validación 1: Serie y número SUNAT
        SELECT @R1 = COUNT(*) FROM OPCH T0
        WHERE (COALESCE(T0."U_BPP_MDSD", '') = '' OR COALESCE(T0."U_BPP_MDCD", '') = '')
        AND T0."DocEntry" = @id;

        IF @R1 > 0
        BEGIN
            SET @error_message = 'STR_A: Debe ingresar la serie y el número SUNAT';
        END

        -- Validación 2: Datos de DUA
        SELECT @R2 = COUNT(*) FROM OPCH T0
        WHERE (COALESCE(T0."U_BPP_MDND", '') = '' OR COALESCE(T0."U_BPP_MDFD", '') = '')
        AND T0."DocEntry" = @id
        AND T0."U_BPP_MDTD" = '50';

        IF @R2 > 0
        BEGIN
            SET @error_message = 'STR_A: Ingrese los datos de DUA';
        END

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
            FROM OPCH
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

    END

    RETURN @error_message;
END

