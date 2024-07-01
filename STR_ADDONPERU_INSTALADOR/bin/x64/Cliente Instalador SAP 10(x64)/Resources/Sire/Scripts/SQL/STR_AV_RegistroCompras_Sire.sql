CREATE PROCEDURE STR_AV_RegistroCompras_Sire
(
	@FI		DATETIME = '20200101', 
	@FF		DATETIME = '20231129'
)

AS
BEGIN
	DECLARE @MES CHAR(2)
	DECLARE @ANIO CHAR(4)
	DECLARE @MES_MS CHAR(2)
	DECLARE @ANIO_MS CHAR(4)
	DECLARE @vv_RER VARCHAR(4)
	DECLARE @R_Fecha_MS DATE
	DECLARE @vv_RucEmisor VARCHAR(15)   --Ruc Emisor
	DECLARE @vv_RzSEmisor VARCHAR(100)  --Razon Social Emisor
	

	SET @R_Fecha_MS = [dbo].[STR_FECHA_PRIMER_DIA_DEL_MES_SIGUIENTE](@FF)
	SET @MES_MS = RIGHT('0' + RIGHT(MONTH(@R_Fecha_MS),2),2)
	SET @ANIO_MS = YEAR(@R_Fecha_MS)
	SET @MES = RIGHT('0' + RIGHT(MONTH(@FF),2),2)
	SET @ANIO = YEAR(@FF)
	SET @vv_RER = (SELECT LEFT(GlblLocNum,4) FROM ADM1)	
	SET @vv_RucEmisor = (SELECT "TaxIdNum" FROM "OADM")
	SET @vv_RzSEmisor = (SELECT "PrintHeadr" FROM "OADM")

	SELECT
		"Periodo",
		"Periodo LE",
		"RUC Empresa",
		"Razon Social Empresa",
		"CAR",
		
		"Numero Unico",
		"Numero Correlativo del Asiento Contable",
		
		"Numero correlativo",		
		"Fecha Emision",		
		"Fecha Vencimiento",
		
		"Tipo",
		"Codigo Aduana",
		"Serie DUA",
		"Fecha DUA",
		"Numero DUA",
		"Campo 10",
		"Numero Final",
		"Tipo Doc. Identidad",
		"RUC",
		"Razon Social",
		"BASE IMPONIBLE A",
		"IGV A",
		"BASE IMPONIBLE B",
		"IGV B",
		"BASE IMPONIBLE C",
		"IGV C",
		
		"Adquisiones no gravadas",
		"ISC",
		"Otros tributos",
		"Importe Total",
		
		"Tipo de cambio",		
		"Fecha Origen",
		"Tipo Origen",
		"Serie Origen",
		"Codigo de la Dependencia Aduanera",
		"Numero Corr. Origen",
		
		"Num.Comp.pago no domiciliado",
		"Fecha de deposito",
		"Constancia de deposito",
		"Retencion",
		"Estado",
		"ObjectType",
		"DocumentEntry",
		"Codigo Moneda",
		"Clasificacion Bienes",
		"Contrato",
		"PorcPart",
		"IMB",
		"CAR CP",
		"TipoNota",
		"Inconsistencias",
		"ErrTpo1",
		"ErrTpo2",
		"ErrTpo3",
		"ErrTpo4",
		"Indicador Comprobante"
		INTO #Temp
	FROM
	(
		SELECT
			
			"Periodo" = (@ANIO + '-' + @MES),
			"Periodo LE" = (@ANIO + @MES),
			"RUC Empresa",
			"Razon Social Empresa",
			"CAR" = CONCAT("RUC",LEFT("Tipo",2),RIGHT('0000' + CAST("Serie DUA" AS VARCHAR(20)),4),right( '00000000' + CAST( "Numero DUA" AS varchar(20)),10)),
			"Numero Unico",
			"Numero Correlativo del Asiento Contable",
			"Numero correlativo",
			"Fecha Emision" = CONVERT(VARCHAR(10), ("Dia Emision" + '/' + "Mes Emision" + '/' + "Anio Emision")),
			"Fecha Vencimiento" = 
			(
				CONVERT
				(VARCHAR(10),
					(
						CASE
						/*********/
				WHEN LEFT("Tipo",2) IN ('46','50','51','52','53','54') AND ("Anio Vencimiento" <= @ANIO OR ((RIGHT("Anio Vencimiento",4) + RIGHT("Mes Vencimiento",2)) <= @ANIO_MS + @MES_MS)) THEN 
				("Dia Vencimiento" + '/' + "Mes Vencimiento" + '/' + "Anio Vencimiento")
				WHEN LEFT("Tipo",2)='14' then ("Dia Vencimiento" + '/' + "Mes Vencimiento" + '/' + "Anio Vencimiento")
						/*********/
							  WHEN ("Anio Vencimiento" > @ANIO OR ((RIGHT("Anio Vencimiento",4) + RIGHT("Mes Vencimiento",2)) > @ANIO_MS + @MES_MS)) THEN ''--'01/01/0001'
						ELSE ''
						END
					)
				)
			),
			
			"Tipo" = ISNULL(CONVERT(VARCHAR(100), "Tipo"),'00'),
			"Codigo Aduana" = 
			(
				CASE
					WHEN LEFT("Tipo",2) IN ('01','03','04','07','08') THEN RIGHT('0000'+ LTRIM(RTRIM(ISNULL("Codigo Aduana",''))),4)
					WHEN LEFT("Tipo",2) IN ('50','52') THEN RIGHT('000'+ LTRIM(RTRIM(ISNULL("Codigo Aduana",''))),3)	
					WHEN LEFT("Tipo",2) NOT IN ('01','03','04','07','08','50','52') THEN
						CASE
							WHEN ISNULL("Codigo Aduana",'') IN ('','0','00','000','0000') THEN '-'
						ELSE
							CONVERT(VARCHAR(20), ISNULL("Codigo Aduana",'-'))
						END
				END
			),
			"Serie DUA" = 
			(
				CASE
					WHEN LEFT("Tipo",2) IN ('01','03','04','07','08','02','06','10','22','25','34','35','36','46','48','56','89') THEN RIGHT('0000'+ LTRIM(RTRIM(ISNULL("Serie DUA",''))),4)
					WHEN LEFT("Tipo",2) ='46' THEN RIGHT('00000'+ LTRIM(RTRIM(ISNULL("Serie DUA",''))),5)
					WHEN LEFT("Tipo",2) IN ('50','51','52','53','54') THEN RIGHT('0000'+ LTRIM(RTRIM(ISNULL("Serie DUA",''))),4)--3
					WHEN LEFT("Tipo",2) = '05' THEN '3'
					WHEN LEFT("Tipo",2) = '55' THEN '2'
					WHEN LEFT("Tipo",2) NOT IN ('01','03','04','07','08','50','52') THEN
						CASE
							WHEN ISNULL("Serie DUA",'') IN ('','0','00','000','0000') THEN RIGHT('0000',4)
						ELSE
							CONVERT(VARCHAR(20), ISNULL("Serie DUA",'0000'))
						END
				END
			),
			"Fecha DUA" = 
			(
				CASE
					WHEN LEFT("Tipo",2) NOT IN ('50','51','52','53','54') THEN ''
					WHEN LEFT("Tipo",2) IN ('50','51','52','53','54') THEN CAST(COALESCE("Fecha DUA",'') AS VARCHAR(10))
				END
			),
			"Numero DUA" = 
			(
				CASE
					WHEN LEFT("Tipo",2) IN ('01','02','03','04','06','07','08','23','25','34','35') THEN RIGHT('0000000'+ LTRIM(RTRIM("Numero DUA")),7)
					WHEN LEFT("Tipo",2) IN ('50','51','53','52') THEN RIGHT('000000'+ LTRIM(RTRIM(ISNULL("Numero DUA",''))),6)
					WHEN LEFT("Tipo",2) IN ('55','56','05') THEN RIGHT('00000000000'+ LTRIM(RTRIM(ISNULL("Numero DUA",''))),11)
				ELSE CONVERT(VARCHAR(20),"Numero DUA")
				END
			),
			"Campo 10" = 
			(
				CASE WHEN LEFT("Tipo",2)IN('00','03','05','06','07','08','11','12','13','14','15','16','18','19','23','26','28','30','34','35','36','37','55','56','87','88') AND  LEN("Numero DUA") >= 0 THEN
						RIGHT('0000000' + LTRIM(RTRIM("Numero DUA")),7)
					ELSE  ''
				END
			),
			"Tipo Doc. Identidad" = 
			(
				CASE 
					WHEN LEFT(ISNULL("Tipo",'00'),2) = '01' THEN '6' --Agregado
					WHEN ISNULL("Tipo Doc. Identidad",'') = '' THEN ''
				ELSE CONVERT(VARCHAR(1), "Tipo Doc. Identidad")
				END
			),
			"RUC" = 
			(
				CASE WHEN ISNULL("RUC",'') = '' THEN '-'
				ELSE "RUC"
				END
			),
			"Razon Social" = 
			(
				CASE
					WHEN ISNULL("Razon Social",'') = '' THEN '-'
				ELSE CONVERT(VARCHAR(100),"Razon Social")
				END
			),
			"BASE IMPONIBLE A" = CONVERT(DECIMAL(16,2), ROUND("BASE IMPONIBLE A",2)),
			"IGV A" =  CONVERT(DECIMAL(16,2), ROUND("IGV A",2)),
			"BASE IMPONIBLE B" = CONVERT(DECIMAL(16,2), ROUND("BASE IMPONIBLE B",2)),
			"IGV B" = CONVERT(DECIMAL(16,2), ROUND("IGV B",2)),
			"BASE IMPONIBLE C" = CONVERT(DECIMAL(16,2), ROUND("BASE IMPONIBLE C",2)),
			"IGV C" = CONVERT(DECIMAL(16,2), ROUND("IGV C",2)),
			
			"Adquisiones no gravadas" = CONVERT(DECIMAL(16,2), ROUND("Adquisiones no gravadas",2)),
			"ISC" = CONVERT(DECIMAL(16,2), ROUND("ISC",2)),
			"Otros tributos" = CONVERT(DECIMAL(16,2), ROUND(CASE WHEN "Otros tributos" < 0 THEN 0 ELSE "Otros tributos" END, 2)),
			"Importe Total" = CONVERT(DECIMAL(16,2), ROUND("Importe Total",2)),
			
			"Tipo de cambio",
					
			"Fecha Origen" = 
			(
				CASE
					WHEN ISNULL("Fecha Origen",'') = '' THEN ''
					WHEN LEFT("Tipo",2) NOT IN ('07','08','87','88') THEN ''
				ELSE	
					RIGHT('0' + ISNULL(RIGHT(DAY("Fecha Origen"),2),''),2) + '/'+ 
					RIGHT('0' + ISNULL(RIGHT(MONTH("Fecha Origen"),2),''),2) + '/'+ 
					ISNULL(RIGHT(YEAR("Fecha Origen"),4),'')		
				END
			),
			"Tipo Origen" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN('07','08','87','88') THEN CONVERT(VARCHAR(2), ISNULL("Tipo Origen",''))
				ELSE ''
				END
			),
			"Codigo de la Dependencia Aduanera"=
				CASE 
					WHEN LEFT("Tipo Origen",2) IN ('50','52') THEN RIGHT(LTRIM(RTRIM("Serie DUA")),3)
				ELSE ' '
				END
			,
			"Serie Origen" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN('07','08','87','88') THEN RIGHT('0000'+CONVERT(VARCHAR(100), ISNULL("Serie Origen",'')),4)
				ELSE ''
				END
			),
			"Numero Corr. Origen" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN ('07','08','87','88') THEN
						CONVERT(VARCHAR(100), ISNULL("Numero Corr. Origen",''))
				ELSE ''
				END
			),
			"Numero Final",
			
			"Num.Comp.pago no domiciliado" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN('91','97','98') THEN CONVERT(VARCHAR(100), ISNULL("Num.Comp.pago no domiciliado",'00000000000000000000'))
				ELSE '-'
				END
			),
			"Fecha de deposito" = 
			(
				CASE
					WHEN ISNULL("Fecha de deposito",'') = '' THEN ''
					WHEN ISNULL("Constancia de deposito",'0') = '0' THEN ''
				ELSE "Dia Deposito" + '/' + "Mes Deposito" + '/' + "Anio Deposito"
				END
			),
			
			"Constancia de deposito" = CONVERT(VARCHAR(20), ISNULL("Constancia de deposito",'')),
			"Retencion",
			"Estado" = ISNULL(
			(
			CASE
				WHEN LEFT("Tipo",2) IN ('03','16') THEN '0'
				WHEN (RIGHT(YEAR(@FI),4) + RIGHT('0' + RIGHT(MONTH(@FI),2),2)) = ("Anio Emision" + "Mes Emision") AND LEFT("Tipo",2) IN('03')  THEN '0' 
				WHEN (RIGHT(YEAR(@FI),4) + RIGHT('0' + RIGHT(MONTH(@FI),2),2)) = ("Anio Emision" + "Mes Emision") THEN '1'
				WHEN (RIGHT(YEAR(@FI),4) + RIGHT('0' + RIGHT(MONTH(@FI),2),2)) > ("Anio Emision" + "Mes Emision") AND (DATEDIFF(MONTH, "Fecha Emision", "Fecha Contabilizacion") <= 12) THEN '6' -- Dentro de 12 Meses
				WHEN (RIGHT(YEAR(@FI),4) + RIGHT('0' + RIGHT(MONTH(@FI),2),2)) > ("Anio Emision" + "Mes Emision") AND (DATEDIFF(MONTH, "Fecha Emision", "Fecha Contabilizacion") >  12) THEN '7' -- Luego de 12 Meses		
			END	
			),''),
			"ObjectType",
			"DocumentEntry",
			"Codigo Moneda",
			"Clasificacion Bienes",
			"Contrato",
			"PorcPart",
			"IMB",
			"CAR CP",
			"TipoNota",
			"Inconsistencias",
			"ErrTpo1",
			"ErrTpo2",
			"ErrTpo3",
			"ErrTpo4",
			"Indicador Comprobante"
		FROM 
		--"STR_VW_RegistroCompras"

			(
			
				SELECT
					"RUC Empresa" = @vv_RucEmisor,
					"Razon Social Empresa" = @vv_RzSEmisor,
					"Numero Unico",
					"Numero Correlativo del Asiento Contable" = CAST("Numero Unico del Asiento Contable" AS VARCHAR(20)),
					"Numero correlativo",
					"Fecha Contabilizacion",
	
					"Fecha Emision",
					/* Campos para Libros Electronicos */
					'Dia Emision' = RIGHT('0' + ISNULL(RIGHT(DAY("Fecha Emision"),2),''),2),
					'Mes Emision' = RIGHT('0' + ISNULL(RIGHT(MONTH("Fecha Emision"),2),''),2),
					'Anio Emision' = ISNULL(RIGHT(YEAR("Fecha Emision"),4),''),
					/* Campos para Libros Electronicos */
	
					"Fecha Vencimiento",
					/* Campos para Libros Electronicos */
					'Dia Vencimiento' = RIGHT('0' + ISNULL(RIGHT(DAY("Fecha Vencimiento"),2),''),2),
					'Mes Vencimiento' = RIGHT('0' + ISNULL(RIGHT(MONTH("Fecha Vencimiento"),2),''),2),
					'Anio Vencimiento' = ISNULL(RIGHT(YEAR("Fecha Vencimiento"),4),''),
					/* Campos para Libros Electronicos */
	
					"Tipo",
					"Codigo Aduana",
					"Serie DUA",
					"Fecha DUA",
					"Numero DUA",
					"Campo 10",
					"Numero Final",
					"Tipo Doc. Identidad",
					"RUC",
					"Razon Social",
					"BASE IMPONIBLE A",
					"IGV A",
					"BASE IMPONIBLE B",
					"IGV B",
					"BASE IMPONIBLE C",
					"IGV C",
					"Adquisiones no gravadas",
					"ISC",
					"Otros tributos",
					"Importe Total",
					"Num.Comp.pago no domiciliado",
					"Constancia de deposito" = CONVERT(VARCHAR(20), ISNULL("Constancia de deposito",'')),
	
					"Fecha de deposito",
					/* Campos para Libros Electronicos */
					'Dia Deposito' = RIGHT('0' + ISNULL(RIGHT(DAY("Fecha de deposito"),2),''),2),
					'Mes Deposito' = RIGHT('0' + ISNULL(RIGHT(MONTH("Fecha de deposito"),2),''),2),
					'Anio Deposito' = ISNULL(RIGHT(YEAR("Fecha de deposito"),4),''),
					/* Campos para Libros Electronicos */
	
					"Tipo de cambio",
					"Fecha Origen",
					"Tipo Origen",
					"Codigo de la Dependencia Aduanera",
					"Serie Origen",
					"Numero Corr. Origen",
					"Retencion",
					"ObjectType",
					"DocumentEntry",
					"Codigo Moneda",
					"Clasificacion Bienes",
					"Contrato",
					"PorcPart",
					"IMB",
					"CAR CP",
					"TipoNota",
					"Inconsistencias",
					"ErrTpo1",
					"ErrTpo2",
					"ErrTpo3",
					"ErrTpo4",
					"Indicador Comprobante"
				FROM
				(
					--/// OPCH: REGISTRO DE COMPRAS ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN ISNULL(@vv_RER, '') = 'REIR' THEN 'M-RER' --Para Agentes de Retencion
																	WHEN T1.TransType = -2 THEN 'A' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T1.TransType = -3 THEN 'C' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T1."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
						'Numero correlativo' = T0."DocNum",
						'Fecha Contabilizacion' = T0."DocDate",
						'Fecha Emision' = T0."TaxDate",
						'Fecha Vencimiento' = T0."DocDueDate",
						'Tipo' = (T0."U_BPP_MDTD" + ' - ' + (SELECT TOP 1 "U_BPP_TDDD" FROM "@BPP_TPODOC" WHERE "U_BPP_TDTD" = T0."U_BPP_MDTD")),
						'Codigo Aduana' =
						(
							CASE
								WHEN T0."U_BPP_MDTD" = '50' THEN T0."U_BPP_CDAD"
							ELSE T0."U_BPP_MDSD"
							END
						),
						'Serie DUA'= T0."U_BPP_MDSD",
						'Fecha DUA' = YEAR(T0."U_BPP_MDFD"),
						'Numero DUA' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Campo 10' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Tipo Doc. Identidad' = T3."U_BPP_BPTD",
						
						'RUC' = T0."LicTradNum",
						'Razon Social' = T0."CardName",

						'BASE IMPONIBLE A' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(LineTotal) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum"
								ELSE 0
								END
							)
							-
							(
								CASE
									WHEN EXISTS(SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN
										ISNULL((SELECT SUM(LineTotal) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),
		
						'IGV A'=
						(
							ISNULL((SELECT SUM(VatSUM) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSUM) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN EXISTS(SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(VatSUM) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),
						-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

						'BASE IMPONIBLE B' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(LineTotal) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum"
								ELSE 0
								END
							)
							-
							(
								CASE
									WHEN EXISTS (SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(LineTotal) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),

						'IGV B' = 
						(
							ISNULL((SELECT SUM(VatSUM) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSUM) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN EXISTS(SELECT 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(VatSUM) FROM PCH11 WHERE DocEntry = T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0 
								END
							)
						),
		
						'BASE IMPONIBLE C' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(LineTotal) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum" 
								ELSE 0 
								END
							)
							-
							(
								CASE
									WHEN EXISTS (SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(LineTotal) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),
		
						'IGV C' = 
						(
							ISNULL((SELECT SUM(VatSUM) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSUM) FROM PCH3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							-
							(
								CASE
									WHEN EXISTS (SELECT 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(VatSUM) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),
		
						'Adquisiones no gravadas' = 
						(
							CASE WHEN T3.U_BPP_BPTP='SND' OR (SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry=T0.DocEntry AND PC.ItemCode=(SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0))<>0 
					
								THEN 0 ELSE
							(
								ISNULL
								(
									(
										SELECT SUM(LineTotal)
										FROM PCH1 
										WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '') = '08.01')
									),0
								)
								+ 
								ISNULL
								(
									(
										SELECT
											SUM(LineTotal) 
										FROM "PCH3"
										WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '') = '08.01')
									), 0
								)
								-
								(
									CASE
										WHEN ISNULL((SELECT SUM(LineTotal) FROM PCH1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum"
									ELSE 0
									END
								)
								-
								(
									CASE
										WHEN EXISTS(SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry = T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
											ISNULL
											(
												(
													SELECT
														SUM(LineTotal) 
													FROM "PCH11"
													WHERE "DocEntry" = T0."DocEntry" AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'D' AND ISNULL(U_STR_FORMATO, '') = '08.01')
												),0
											)
									ELSE 0
									END
								)
							)
							END
						),

						'ISC' =
						(
							ISNULL
							(
								(
									SELECT
										SUM(C.TaxSUM )
									FROM OSTT A 
									INNER JOIN OSTA B ON A.AbsId = B.Type
									INNER JOIN PCH4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
									WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry 
								),0
							)
						),
		
						'Otros tributos' = 
						(
							(
								CASE
									WHEN
									(
										T0.VatSUM 
										- 
										(
											ISNULL
											(
												(
													SELECT
														SUM(C.TaxSUM )
													FROM OSTT A
													INNER JOIN OSTA B ON A.AbsId = B.Type
													INNER JOIN PCH4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
													WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry
												),0
											)
										)
										-
										(
											ISNULL
											(
												(
													SELECT
														SUM(C."TaxSUM")
													FROM OSTT A
													INNER JOIN OSTA B ON A.AbsId = B.Type
													INNER JOIN PCH4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
													WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry
												),0
											)
										)
									) > 0
									THEN
									(
										T0."VatSum"
										- 
										(
											ISNULL
											(
												(
													SELECT
														SUM(C.TaxSUM)
													FROM OSTT A 
													INNER JOIN OSTA B ON A.AbsId = B.Type
													INNER JOIN PCH4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
													WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry
												),0
											)
										)
										-
										(
											ISNULL
											(
												(
													SELECT
														SUM(C.TaxSum)
													FROM OSTT A
													INNER JOIN OSTA B ON A.AbsId = B.Type
													INNER JOIN PCH4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
													WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry 
												),0
											)
										)
										+
										T0."RoundDif"
									)
								ELSE (T0."RoundDif" + (SELECT ISNULL(SUM(A.TaxSUM),0) FROM PCH4 A WHERE A.DocEntry = T0.DocEntry AND (SELECT TOP 1 AA."U_OTR" FROM OSTC AA WHERE A.StcCode = AA.Code) = 'Si'))
								END
							)
							+
			
							ISNULL((SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry=T0.DocEntry AND PC.ItemCode =(SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0)),0)
						),
		
						'Importe Total' =
						(
							T0.DocTotal 
							+
							(
								SELECT ISNULL(SUM(A.WtAmnt),0) FROM PCH5 A WHERE A.AbsEntry = T0.DocEntry AND (UPPER(A.Category)='I')
							)

							--/// Strat: Reincorporar el monto aplicado desde una solicitud de anticipo
							+
							(
								CASE 
									WHEN EXISTS(SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry = (SELECT TOP 1 "BaseAbs" FROM PCH9 WHERE "DocEntry" = T0.DocEntry) AND ISNULL(TransId, '') = '') THEN 
										(SELECT SUM(DpmAmnt) FROM ODPO WHERE DocEntry = (SELECT TOP 1 BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') = '')
								ELSE 0
								END
							 )
			
							--/// Strat: Añadir el importe de las lineas que se marcaron como "Solo Factura" 
							+
							(
								CASE
									WHEN EXISTS(SELECT TOP 1 'TO' FROM "PCH1" WHERE "TaxOnly" = 'Y' AND DocEntry = T0.DocEntry) THEN
										(SELECT SUM(LineTotal) FROM "PCH1" WHERE TaxOnly = 'Y' AND DocEntry=T0.DocEntry)
								ELSE 0
								END
							 )
						),

						'Num.Comp.pago no domiciliado' = 
						(
							CASE T0."U_BPP_MDTD"
								WHEN '91' THEN T0."U_BPP_SND"
							ELSE NULL
							END
						),
						'Constancia de deposito' = T0."U_BPP_DPNM",
						'Fecha de deposito'	= T0."U_BPP_DPFC",
						'Tipo de cambio' = 
						(
							CAST
							(
								(
									CAST
									(
										(
											CASE 
												WHEN UPPER(T0.DocCur) = 'SOL' THEN NULL
											ELSE T0."DocRate"
											END
										) AS DECIMAL(18,3)
									)
								) AS CHAR(20)
							)
						),
						'Fecha Origen' = 
						(
							--(SELECT TOP 1 B.TaxDate FROM OPCH B WHERE B.U_BPP_MDCD=T0.U_BPP_MDCO AND B.U_BPP_MDSD=T0.U_BPP_MDSO AND T0.U_BPP_MDTO = B.U_BPP_MDTD)
							CASE T0.DocSubType
								WHEN 'DM' THEN (SELECT TOP 1 B.TaxDate FROM OPCH B WHERE B.U_BPP_MDCD=T0.U_BPP_MDCO AND B.U_BPP_MDSD=T0.U_BPP_MDSO AND T0.U_BPP_MDTO = B.U_BPP_MDTD)
							ELSE ''
							END
						),
						'Tipo Origen' = 
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDTO
							ELSE NULL 
							END
						),
						"Codigo de la Dependencia Aduanera" = 
						(
							CASE
								WHEN COALESCE(T0.U_BPP_MDSO, '') IN('50','52') THEN T0."U_BPP_CDAD"
							ELSE '-'
							END
						),
						'Serie Origen' = 
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDSO 
							ELSE NULL 
							END
						),
						'Numero Corr. Origen' = 
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDCO
							ELSE NULL
							END
						),
		
						'ObjectType' = CONVERT(NVARCHAR(15), T0.ObjType),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0.DocEntry) ,
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = 
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM PCH5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp='Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN '1'
							ELSE ''
							END
						),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = (CASE T0."DocType" 
											WHEN 'I' THEN 
													CASE (SELECT (SELECT "ItemType" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT (SELECT "U_BPP_TIPEXIST" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" 
														AND (TX0."LineNum"= 0)) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
											ELSE 
													CASE (SELECT  LEFT("AcctCode",1) FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN '6' THEN '4' ELSE '5' END      -------> QUITAR ESTA LINEA EN LAS 3 SECCIONES
													--CASE WHEN (SELECT LEN("U_STR_TIPEXISTSRV") FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") > 0 THEN (SELECT "U_STR_TIPEXISTSRV" FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") ELSE '5' END
											END),
						'Numero Final' = '',
						'Contrato' = '',
						'PorcPart' = '',
						'IMB' = '',
						'CAR CP' = '',
						'TipoNota' ='',
						'Inconsistencias' = '',
						'ErrTpo1' = '',
						'ErrTpo2' = '',
						'ErrTpo3' = '',
						'ErrTpo4' = '',
						'Indicador Comprobante' = ''
					FROM "OPCH" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					WHERE
						(1 = 1)
					AND	(T1."TransType" = '18')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL("U_excluir", 'N') != 'Y'))
					/*ADD*/ AND T0."U_BPP_MDTD" NOT IN ('91','97','98')
				    AND T3.U_BPP_BPTP != 'SND'
					
					UNION ALL
	
	
					--/// ORPC: NOTA DE CREDITO PROVEEDOR ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN ISNULL(@vv_RER, '') = 'REIR' THEN 'M-RER' --Para Agentes de Retencion
																	WHEN T1.TransType = -2 THEN 'A' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T1.TransType = -3 THEN 'C' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T1."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
						'Numero correlativo' = T0."DocNum",
						'Fecha Contabilizacion' = T0."DocDate",
						'Fecha Emision' = T0."TaxDate",
						'Fecha Vencimiento' = T0."DocDueDate",
						'Tipo' = (T0."U_BPP_MDTD" + ' - ' + (SELECT TOP 1 "U_BPP_TDDD" FROM "@BPP_TPODOC" WHERE "U_BPP_TDTD" = T0."U_BPP_MDTD")),
						'Codigo Aduana' = 
						(
							CASE
								WHEN T0."U_BPP_MDTD" = '50' THEN T0."U_BPP_CDAD"
							ELSE T0."U_BPP_MDSD"
							END
						), 
						'Serie DUA'= T0."U_BPP_MDSD",
						'Fecha DUA' = YEAR(T0."U_BPP_MDFD"),
						'Numero DUA' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Campo 10' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Tipo Doc. Identidad' = T3."U_BPP_BPTD",
						'RUC' = T3."LicTradNum",
						'Razon Social' = 
						(
							CASE
								WHEN T3."U_BPP_BPTP" = 'TPN' THEN ISNULL(T3."U_BPP_BPAP", ' ') + ' ' + ISNULL(T3."U_BPP_BPAM", ' ') + ' ' + ISNULL(T3."U_BPP_BPNO", ' ') 
							ELSE T3."CardName"
							END
						),
		
						'BASE IMPONIBLE A' = 
						(
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'A' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'A' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							+
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'A' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0) > 0 THEN T0."DiscSum"
								ELSE 0
								END
							)
						),
		
						'IGV A' = 
						(
							-
							ISNULL((SELECT SUM(VatSum) FROM RPC1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'A' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0) 
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'A' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
						),
							-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

						'BASE IMPONIBLE B' = 
						(
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'B' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'B' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							+
							(CASE
								WHEN ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum"
							ELSE 0 END
							)
						),
						'IGV B' = 
						(
							-
							ISNULL((SELECT SUM(VatSum) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'B' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'B' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
						),
		
						-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

						'BASE IMPONIBLE C' = 
						(
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'C' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'C' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							+
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) > 0 THEN T0."DiscSum"
								ELSE 0
								END
							)
						),
						'IGV C' = 
						(
							-
							ISNULL((SELECT SUM(VatSum) FROM RPC1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'C' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(VatSum) FROM RPC3 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'C' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
						),
		
						--/// Strat:  Adquisiciones no gravadas - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
						'Adquisiones no gravadas' = 
							CASE WHEN T3.U_BPP_BPTP='SND' OR (SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry=T0.DocEntry AND PC.ItemCode=(SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0))<>0 
				
							THEN 0 ELSE
						(
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'D' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							-
							ISNULL((SELECT SUM(LineTotal) FROM RPC3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'D' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0)
							+
							(
								CASE
									WHEN ISNULL((SELECT SUM(LineTotal) FROM RPC1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '') = 'D' AND ISNULL(U_STR_FORMATO, '') = '08.01')), 0) > 0 THEN T0."DiscSum"
								ELSE 0
								END
							)
						)  
						 END,
						'ISC' =
						(
							- ISNULL
							(
								(
									SELECT
										SUM(C.TaxSum)
									FROM OSTT A 
									INNER JOIN OSTA B ON A.AbsId = B.Type
									INNER JOIN RPC4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N') = 'Y' AND ISNULL(A.U_ISC,'N') = 'Y' AND C.DocEntry = T0.DocEntry
								),0
							)
						),
						'Otros tributos' = 
						(
							-
							(CASE
								WHEN
									(
										T0."VatSum"
										- 
										(ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RPC4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry),0))
										-
										(ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RPC4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry),0))
									) > 0

								THEN
								(
									T0."VatSum"
									- 
									(ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RPC4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry),0))
									-
									(ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RPC4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry),0))
									+
									T0."RoundDif"
								)
							ELSE(T0."RoundDif") + (SELECT ISNULL(SUM(A.TaxSum),0) FROM RPC4 A WHERE A.DocEntry = T0.DocEntry AND (SELECT TOP 1 AA.U_OTR FROM OSTC AA WHERE A.StcCode=AA.Code) = 'Si')
							END
			
							+
						ISNULL((SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry=T0.DocEntry AND PC.ItemCode=(SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0)),0)
						)
						),
		
						'Importe Total' =
							-
							(
								T0."DocTotal" + (SELECT ISNULL(SUM(A.WtAmnt),0) FROM RPC5 A WHERE A.AbsEntry=T0.DocEntry AND (UPPER(A.Category)='I')
							)
			
							--/// Strat: Reincorporar el monto aplicado desde una solicitud de anticipo . . . . . . . 
							+
							(
								CASE
									WHEN EXISTS(SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry = (SELECT TOP 1 BaseAbs FROM RPC9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') = '') THEN
										(SELECT SUM(DpmAmnt) FROM ODPO WHERE DocEntry = (SELECT TOP 1 BaseAbs FROM RPC9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') = '')
								ELSE
									0
								END
							)
			
							--/// Strat: Añadir el importe de las lineas que se marcaron como "Solo Factura" 
							+
							(
								CASE
									WHEN EXISTS(SELECT TOP 1 'TO' FROM RPC1 WHERE TaxOnly = 'Y' AND DocEntry = T0.DocEntry) THEN
										(SELECT SUM(LineTotal) FROM RPC1 WHERE TaxOnly = 'Y' AND DocEntry=T0.DocEntry)
								ELSE 0
								END
							 )
						),
						'Num.Comp.pago no domiciliado' = 
						(
							CASE T0."U_BPP_MDTD" 
								WHEN '91' THEN T0."U_BPP_SND"
							ELSE NULL
							END
						),
						'Constancia de deposito' = T0."U_BPP_DPNM",
						'Fecha de deposito' = T0."U_BPP_DPFC",
						'Tipo de cambio' = 
						(
							CAST
							(
								(
									CAST
									(
										(
											CASE 
												WHEN UPPER(T0.DocCur) = 'SOL' THEN NULL
											ELSE T0."DocRate"
											END
										) AS DECIMAL(18,3)
									)
								) AS CHAR(20)
							)
						),
						'Fecha Origen' = 
						(
							CASE WHEN
								(
									ISNULL((SELECT TOP 1 B."TaxDate" FROM RPC1 A INNER JOIN OPCH B ON A.BaseEntry = B.DocEntry AND A.BaseType =  18 WHERE A.DocEntry = T0.DocEntry), '') = '' AND 
									ISNULL((SELECT TOP 1 B."TaxDate" FROM RPC1 A INNER JOIN ODPO B ON A.BaseEntry = B.DocEntry AND A.BaseType = 204 WHERE A.DocEntry = T0.DocEntry), '') = '' 
								)
								THEN T0."U_BPP_SDocDate"
								WHEN
									(
										ISNULL((SELECT TOP 1 B."TaxDate" FROM RPC1 A INNER JOIN ODPO B ON A.BaseEntry = B.DocEntry AND A.BaseType = 204 WHERE A.DocEntry = T0.DocEntry), '') = ''
									)
								THEN ISNULL((SELECT TOP 1 B."TaxDate" FROM RPC1 A INNER JOIN OPCH B ON A.BaseEntry = B.DocEntry AND A.BaseType = 18 WHERE A.DocEntry = T0.DocEntry), '')
							ELSE ISNULL((SELECT TOP 1 B."TaxDate" FROM RPC1 A INNER JOIN ODPO B ON A.BaseEntry=B.DocEntry AND A.BaseType = 204 WHERE A.DocEntry = T0.DocEntry), '') END
						),
		
						'Tipo Origen' = T0."U_BPP_MDTO",
		
						"Codigo de la Dependencia Aduanera" = 
						(
							CASE
								WHEN COALESCE(T0.U_BPP_MDSO, '') IN('50','52') THEN T0."U_BPP_CDAD"
							ELSE '-'
							END
						),
						'Serie Origen' = T0."U_BPP_MDSO",
						'Numero Corr. Origen' = T0."U_BPP_MDCO",
						'ObjectType' = CONVERT(NVARCHAR(15), T0.ObjType),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0.DocEntry),
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = 
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM RPC5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp='Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN '1'
							ELSE ''
							END
						),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = (CASE T0."DocType" 
											WHEN 'I' THEN 
													CASE (SELECT (SELECT "ItemType" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT (SELECT "U_BPP_TIPEXIST" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" 
														AND (TX0."LineNum"= 0)) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
											ELSE 
													CASE (SELECT  LEFT("AcctCode",1) FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN '6' THEN '4' ELSE '5' END      -------> QUITAR ESTA LINEA EN LAS 3 SECCIONES
													--CASE WHEN (SELECT LEN("U_STR_TIPEXISTSRV") FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") > 0 THEN (SELECT "U_STR_TIPEXISTSRV" FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") ELSE '5' END
											END),
						'Numero Final' ='',
						'Contrato' = '',
						'PorcPart' = '',
						'IMB' = '',
						'CAR CP' = '',
						'TipoNota' = '',--(ISNULL(T0.U_STR_MtvoCD,'')) ,
						'Inconsistencias' = '',
						'ErrTpo1' = '',
						'ErrTpo2' = '',
						'ErrTpo3' = '',
						'ErrTpo4' = '',
						'Indicador Comprobante' = ''
					FROM "ORPC" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					WHERE
						(1 = 1)
					AND	(T1."TransType" = '19')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL("U_excluir", 'N') != 'Y'))
					AND T0."U_BPP_MDTD" NOT IN ('91','97','98')
					AND T3.U_BPP_BPTP != 'SND'
	
					UNION ALL
	
	
					--/// ODPO: FACTURAS DE ANTICIPO ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN ISNULL(@vv_RER, '') = 'REIR' THEN 'M-RER' --Para Agentes de Retencion
																	WHEN T1.TransType = -2 THEN 'A' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T1.TransType = -3 THEN 'C' + CAST(T1."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T1."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
						'Numero correlativo' = T0."DocNum",
						'Fecha Contabilizacion' = T0."DocDate",
						'Fecha Emision' = T0."TaxDate",
						'Fecha Vencimiento' = T0."DocDueDate",
						'Tipo' = (T0."U_BPP_MDTD" + ' - ' + (SELECT TOP 1 "U_BPP_TDDD" FROM "@BPP_TPODOC" WHERE "U_BPP_TDTD" = T0."U_BPP_MDTD")),
						'Codigo Aduana' =
						(
							CASE
								WHEN T0."U_BPP_MDTD" = '50' THEN T0."U_BPP_CDAD"
							ELSE T0."U_BPP_MDSD"
							END
						),
						'Serie DUA'= T0."U_BPP_MDSD",
						'Fecha DUA' = YEAR(T0."U_BPP_MDFD"),
						'Numero DUA' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Campo 10' = CONVERT(NVARCHAR(20), T0."U_BPP_MDCD"),
						'Tipo Doc. Identidad' = T3."U_BPP_BPTD",
						'RUC' = T3."LicTradNum",
						'Razon Social' = 
						(
							CASE
								WHEN T3."U_BPP_BPTP" = 'TPN' THEN ISNULL(T3."U_BPP_BPAP", ' ') + ' ' + ISNULL(T3."U_BPP_BPAM", ' ') + ' ' + ISNULL(T3."U_BPP_BPNO", ' ')
							ELSE T3."CardName"
							END
						),
						'BASE IMPONIBLE A' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) * (DpmPrcnt/100)
							+
							ISNULL((SELECT SUM(LineTotal) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'IGV A' = 
						(
							ISNULL((SELECT SUM(VatSum) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSum) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='A' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'BASE IMPONIBLE B' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) * (DpmPrcnt/100)
							+
							ISNULL((SELECT SUM(LineTotal) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'IGV B' = 
						(
							ISNULL((SELECT SUM(VatSum) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSum) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='B' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'BASE IMPONIBLE C' = 
						(
							ISNULL((SELECT SUM(LineTotal) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) * (DpmPrcnt/100)
							+
							ISNULL((SELECT SUM(LineTotal) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'IGV C' = 
						(
							ISNULL((SELECT SUM(VatSum) FROM DPO1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
							+
							ISNULL((SELECT SUM(VatSum) FROM DPO3 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						),
						'Adquisiones no gravadas' = 
						CASE WHEN T3.U_BPP_BPTP='SND' OR (SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry = T0.DocEntry AND PC.ItemCode = (SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0))<>0 
				
							THEN 0 ELSE
						(
							ISNULL((SELECT SUM(LineTotal) FROM DPO1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) 
							+
							ISNULL((SELECT SUM(LineTotal) FROM DPO3 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						) END
						,
						'ISC' = 
						(
							ISNULL
							(
								(
									SELECT
										SUM(C.TaxSum)
									FROM OSTT A
									INNER JOIN OSTA B ON A.AbsId = B.Type
									INNER JOIN DPO4 C ON B.Code = C.StaCode AND A.AbsId = C.staType
									WHERE
										(ISNULL(B."U_ISC",'N') = 'Y')
									AND (ISNULL(A."U_ISC",'N') = 'Y')
									AND (C."DocEntry" = T0."DocEntry")
								),0
							)
						),
		
						'Otros tributos' = 
						(
							CASE
								WHEN
								(
									T0.VatSum 
									- 
									(
										ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPO4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
									)
									-
									(
										ISNULL((SELECT SUM(C.TaxSum) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPO4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
									)
								) > 0
								THEN
								(
									T0.VatSum
									- 
									(
										ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPO4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
									)
									-
									(
										ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPO4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0))
									+
									T0."RoundDif"
								)
							ELSE (T0."RoundDif") + (SELECT ISNULL(SUM(A.TaxSum),0) FROM DPO4 A WHERE A.DocEntry = T0.DocEntry AND (SELECT TOP 1 AA.U_OTR FROM OSTC AA WHERE A.StcCode = AA.Code) = 'Si')
							END
						),
						'Importe Total'	= 
						(
							T0.DocTotal
							+ 
							(SELECT ISNULL(SUM(A.WtAmnt),0) FROM DPO5 A WHERE A.AbsEntry=T0.DocEntry AND (UPPER(A.Category)='I'))
			
							--/// Strat: Añadir el importe de las lineas que se marcaron como "Solo Factura"
							+
							(
								CASE
									WHEN EXISTS (SELECT TOP 1 'TO' FROM DPO1 WHERE TaxOnly = 'Y' AND DocEntry=T0.DocEntry) THEN	
										(SELECT SUM(LineTotal) FROM DPO1 WHERE TaxOnly = 'Y' AND DocEntry=T0.DocEntry)
								ELSE 0
								END
						  )
						),
						'Num.Comp.pago no domiciliado'=
						(
							CASE T0."U_BPP_MDTD"
								WHEN '91' THEN T0."U_BPP_SND"
							ELSE NULL
							END
						),
						'Constancia de deposito' = T0."U_BPP_DPNM",
						'Fecha de deposito' = T0."U_BPP_DPFC",
						'Tipo de cambio' = 
						(
							CAST
							(
								(
									CAST
									(
										(
											CASE 
												WHEN UPPER(T0.DocCur) = 'SOL' THEN NULL
											ELSE T0."DocRate"
											END
										) AS DECIMAL(18,3)
									)
								) AS CHAR(20)
							)
						),
						'Fecha Origen' = NULL,
						'Tipo Origen' = NULL,
						"Codigo de la Dependencia Aduanera" = '-',
						'Serie Origen' = NULL,
						'Numero Corr. Origen' = NULL,
		
						'ObjectType' = CONVERT(NVARCHAR(15), T0."ObjType"),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0."DocEntry"),
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = 
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM DPO5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp = 'Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN '1'
							ELSE ''
							END 
						),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = (CASE T0."DocType" 
											WHEN 'I' THEN 
													CASE (SELECT (SELECT "ItemType" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT (SELECT "U_BPP_TIPEXIST" FROM OITM TY0 WHERE TY0."ItemCode" =  TX0."ItemCode") FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" 
														AND (TX0."LineNum"= 0)) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
											ELSE 
													CASE (SELECT  LEFT("AcctCode",1) FROM PCH1 TX0 WHERE TX0."DocEntry" = T0."DocEntry" AND (TX0."LineNum"= 0)) WHEN '6' THEN '4' ELSE '5' END      -------> QUITAR ESTA LINEA EN LAS 3 SECCIONES
													--CASE WHEN (SELECT LEN("U_STR_TIPEXISTSRV") FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") > 0 THEN (SELECT "U_STR_TIPEXISTSRV" FROM OPCH TX0 WHERE TX0."DocEntry" = T0."DocEntry") ELSE '5' END
											END),
						'Numero Final' = '',
						'Contrato' = '',
						'PorcPart' = '',
						'IMB' = '',
						'CAR CP' = '',
						'TipoNota' = '',
						'Inconsistencias' = '',
						'ErrTpo1' = '',
						'ErrTpo2' = '',
						'ErrTpo3' = '',
						'ErrTpo4' = '',
						'Indicador Comprobante' = ''
					FROM "ODPO" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					WHERE
						(1 = 1)
					AND	(T1."TransType" = '204')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL(N0."U_excluir", 'N') != 'Y'))
					AND T0."U_BPP_MDTD" NOT IN ('91','97','98')
					AND T3.U_BPP_BPTP != 'SND'
				)R
				WHERE
					(LEFT(ISNULL("Tipo", 'ZA'), 2) != 'ZA')
				AND (ISNULL("Numero DUA", '') NOT IN ('', '0'))

			)TT

		WHERE
			(1 = 1)
		  AND (LEFT("Tipo",2) <> '02')
		--AND (LEFT("Tipo",2) not in  ('02','32','39'))
		AND ("Fecha Contabilizacion" BETWEEN @FI AND @FF)
	)R
	WHERE
		"Numero DUA" NOT LIKE '%AN%'	
	--and left(tipo,2) in ('07','08','87','88','97','98')

	-- ===================================================================
	SELECT "RUC Empresa","Periodo LE","ObjectType","DocumentEntry",
	   "RUC Empresa"											--1
	   +'|'+"Razon Social Empresa"								--2 	
	   +'|'+"Periodo LE" 										--3
	   +'|'+"CAR"												--4
	   +'|'+"Fecha Emision"										--5
	   +'|'+"Fecha Vencimiento"									--6
	   +'|'+LEFT("Tipo",2)										--7
	   +'|'+CAST("Serie DUA" AS VARCHAR(20))					--8
	   +'|'+CAST("Fecha DUA" AS VARCHAR(10))					--9
	   +'|'+"Numero DUA" 										--10
	   +'|'+"Numero Final"										--11
	   +'|'+"Tipo Doc. Identidad" 								--12
	   +'|'+"RUC"												--13
	   +'|'+"Razon Social"										--14
	   +'|'+CAST("BASE IMPONIBLE A" AS VARCHAR(20))				--15
	   +'|'+CAST("IGV A" AS VARCHAR(20)) 						--16
	   +'|'+CAST("BASE IMPONIBLE B" AS VARCHAR(20)) 			--17
	   +'|'+CAST("IGV B" AS VARCHAR(20))						--18
	   +'|'+CAST("BASE IMPONIBLE C" AS VARCHAR(20))				--19
	   +'|'+CAST("IGV C" AS VARCHAR(20))						--20
	   +'|'+CAST("Adquisiones no gravadas" AS VARCHAR(20))		--21
	   +'|'+CAST("ISC" AS VARCHAR(20))  						--22
	   +'|'+'0.00' 												--23 Impuesto consumo bolsas
	   +'|'+CAST("Otros tributos" AS VARCHAR(20))				--24
	   +'|'+CAST("Importe Total" AS VARCHAR(20))				--25
	   +'|'+"Codigo Moneda" 									--26
	   +'|'+ISNULL(RTRIM("Tipo de cambio"),'')					--27
	   +'|'+"Fecha Origen" 										--28
	   +'|'+"Tipo Origen" 										--29
	   +'|'+"Serie Origen"										--30
	   +'|'+CAST(RTRIM("Codigo de la Dependencia Aduanera") AS VARCHAR(5)) --31
	   +'|'+CAST("Numero Corr. Origen" 	AS VARCHAR(20))					--32
	   +'|'+COALESCE("Clasificacion Bienes",'') 				--33
	   +'|'+"Contrato" 											--34
	   +'|'+"PorcPart"											--35
	   +'|'+"IMB"												--36
	   +'|'+"CAR CP"											--37
	   +'|'+"Retencion"											--38
	   +'|'+"TipoNota"											--39
	   +'|'+"Estado"											--40
	   +'|'+"Inconsistencias" 									--41
	   +'|'
	   AS "PLE" 
	FROM #Temp;
END