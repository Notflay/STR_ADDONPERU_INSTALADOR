CREATE FUNCTION RML_TN_LC_16_DEVOLUCIONES
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R2 INT;
    DECLARE @DOCTYPE NCHAR(1);

    SET @error_message = '';

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Tipo de Operación
        SELECT @DOCTYPE = A."DocType" FROM ORDN A WHERE A."DocEntry" = @id;

        IF @DOCTYPE = 'I'
        BEGIN
            -- Validación específica para tipo 'I'
            SELECT @R2 = COUNT(*) FROM RDN1 T0 INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
            WHERE COALESCE(T0."U_tipoOpT12", '') = '' AND T1."InvntItem" = 'Y' 
            AND T0."DocEntry" = @id;

            IF @R2 > 0 BEGIN
                SET @error_message = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento';
            END
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
            FROM ORDN
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

			set @sNumExist = (SELECT TOP 1 DocNum from (
								select DocNum as 'DocNum' from OINV where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select DocNum as 'DocNum' from ORIN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select DocNum as 'DocNum' from ODLN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select DocNum as 'DocNum' from ORDN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select DocNum as 'DocNum' from ODPI where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL					
								select DocNum as 'DocNum' from OIGE where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select DocNum as 'DocNum' from OWTR where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL				
								select DocNum as 'DocNum' from OVPM where U_BPP_PTCC=@sNumero and ISNULL(U_BPP_PTCC, '')<>'' and U_BPP_PTSC=@sr and ISNULL(U_BPP_PTSC, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								--select Code as 'DocNum' from @BPP_NROANUL where U_BPP_TpoDoc='Venta' and U_BPP_Correlativo=@sNumero and ISNULL(U_BPP_Correlativo, '')<>'' and U_BPP_Serie=@sr and ISNULL(U_BPP_Serie, '')<>'' and U_BPP_TpoSUNAT=@tp and ISNULL(U_BPP_TpoSUNAT, '')<>''
								--UNION ALL
								select DocNum as 'DocNum' from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1.DocEntry = T2.DocEntry 
									where U_BPP_TpDoc = 'Venta' and U_BPP_NmCr = @sNumero and ISNULL(U_BPP_NmCr,'')<>'' and U_BPP_DocSnt = @tp 
										and  ISNULL(U_BPP_DocSnt,'')<>'' and U_BPP_Serie = @sr and ISNULL(U_BPP_Serie,'') <>'' and T1.DocEntry <> @id 
								) DE)
					
			set @sTipoExist = (select top 1 Tipo from (
								select ObjType as 'Tipo' from OINV where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from ORIN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from ODLN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from ORDN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from ODPI where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from OIGE where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								select ObjType as 'Tipo' from OWTR where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL					
								select ObjType as 'Tipo' from OVPM where U_BPP_PTCC=@sNumero and ISNULL(U_BPP_PTCC, '')<>'' and U_BPP_PTSC=@sr and ISNULL(U_BPP_PTSC, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@id
								UNION ALL
								--select 'Anulacion' as 'Tipo' from @BPP_NROANUL where U_BPP_TpoDoc='Venta' and U_BPP_Correlativo=@sNumero and ISNULL(U_BPP_Correlativo, '')<>'' and U_BPP_Serie=@sr and ISNULL(U_BPP_Serie, '')<>'' and U_BPP_TpoSUNAT=@tp and ISNULL(U_BPP_TpoSUNAT, '')<>'') 
								--UNION ALL 
								select 'Anulacion' as 'Tipo' from "@BPP_ANULCORR" T1 inner join "@BPP_ANULCORRDET" T2 on T1.DocEntry = T2.DocEntry 
									where U_BPP_TpDoc = 'Venta' and U_BPP_NmCr = @sNumero and ISNULL(U_BPP_NmCr,'')<>'' and U_BPP_DocSnt = @tp 
										and ISNULL(U_BPP_DocSnt,'')<>'' and U_BPP_Serie = @sr and ISNULL(U_BPP_Serie,'') <>'' and T1.DocEntry <> @id
								)TP)
			
			IF ISNULL(@sNumExist, '') != '' or ISNULL(@sTipoExist, '') != ''
			BEGIN
				SET @error_message='Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' + @sNumExist + ' ObjType: ' + @sTipoExist + ')'
			END
END

    END

    RETURN @error_message;
END

