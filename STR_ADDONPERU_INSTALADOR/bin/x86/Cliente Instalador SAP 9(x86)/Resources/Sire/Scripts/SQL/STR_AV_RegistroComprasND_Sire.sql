CREATE PROCEDURE STR_AV_RegistroComprasND_Sire
			
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
	DECLARE @ANIOiodo NVARCHAR(8)
	DECLARE @R_Fecha_MS date
	

	SET @R_Fecha_MS = [dbo].[STR_FN_FECHA_PRIMER_DIA_DEL_MES_SIGUIENTE](@FF)
	SET @MES_MS = RIGHT('0' + RIGHT(MONTH(@R_Fecha_MS),2),2)
	SET @ANIO_MS = YEAR(@R_Fecha_MS)
	SET @MES = CONVERT(CHAR(2), MONTH(@FF))
	SET @ANIO = CONVERT(CHAR(4), YEAR(@FF))
	
	IF LEN(@MES) = 1
	BEGIN
		SET @MES = '0' + @MES
	END
	
	SELECT
		"Periodo",---01
		"Periodo LE",--01
		"RUC Empresa",--21
		"Razon Social Empresa",--19
		'' AS"CAR",
		"CAR CP",
		"Numero Unico",--02
		"Numero Correlativo del Asiento Contable",--03
		"Numero correlativo",
		"Fecha Emision",--04
		"Tipo",--05
		"Serie DUA",--06
		"Fecha DUA",--13
		"Numero DUA",---07
		"Tipo Doc. Identidad",--
		"RUC",--21
		"Razon Social",----23
		"BASE IMPONIBLE A",
		"IGV A",-------15
		"BASE IMPONIBLE B",--
		"IGV B",--
		"BASE IMPONIBLE C",--
		"IGV C",--
		"Adquisiones no gravadas",--8
		"ISC",--
		"Otros tributos",--9
		"Importe Total",---10
		 "Tipo de cambio",--17
		"Tipo Origen",--11
		"Serie Origen",--12
		"Numero Corr. Origen",--14
		"Num.Comp.pago no domiciliado",
		"Estado",--36
		"ObjectType",
		"DocumentEntry",
		"Codigo Moneda",---16
		"Retencion",
		"Pais_sujeto",--18
		"Razon_social_sujeto ",--19
		"Dominicio_Extranjero",--20
		"Num_Iidentidad_Sujeto",
		"Num_fiscal_Beneficiario",
		"Razon_Social_beneficiario",----23
		"Pais_beneficiario",---24
		"Vinculo_contribuyente",--------25
		
		(CASE WHEN ISNUMERIC("Taza Retencion")=1 THEN CAST("Renta_Bruta" AS DECIMAL (16,2))ELSE NULL END) AS "Renta_Bruta",--------------------------26
		"Deduccion",--------------------------------------------------------------------27
		(CASE WHEN ISNUMERIC("Taza Retencion")=1 THEN CAST("Renta Neta" AS DECIMAL(16,2))ELSE NULL END) AS "Renta Neta",-----------------------------28
		(CASE WHEN ISNUMERIC("Taza Retencion")=1 THEN CAST("Taza Retencion"AS DECIMAL(16,2))ELSE NULL END) AS "Taza Retencion",---------------------29
		(CASE WHEN ISNUMERIC("Taza Retencion")=1 THEN CAST("Impuesto Retenido" AS DECIMAL(16,2))ELSE NULL END) AS "Impuesto Retenido",--------------30
		"Convenio_Evitar",
		"Exoneracion Amplia",
		"Tipo Renta",
		"Modalidad Servicio",
		"Aplicaion 76",
		"Campo Libre"

		INTO #Temp
		
	
		
	FROM
	(
		SELECT
			"Periodo" = (@ANIO + '-' + @MES),
			"Periodo LE" = (@ANIO + @MES),
			"RUC Empresa",
			"Razon Social Empresa",

			"CAR" = --"Numero DUA",
			CONCAT(RIGHT('00000000000' + "RUC",11),LEFT("Tipo",2),RIGHT('0000' + CAST("Serie DUA" AS VARCHAR(20)),4),RIGHT( '0000000000' + CAST( "Numero DUA" AS varchar(20)),10)),
					
			"CAR CP" = '',

			"Numero Unico",
			"Numero Correlativo del Asiento Contable",
			
			"Numero correlativo",
			
			"Fecha Emision" = CONVERT(VARCHAR(10), ("Dia Emision" + '/' + "Mes Emision" + '/' + "Anio Emision")),
			"Mes Emision",
			"Anio Emision",
		
			
			
			"Tipo" = ISNULL(CONVERT(VARCHAR(100), "Tipo"),'00'),
			
			"Serie DUA" = 
			(
				CASE
					WHEN LEFT("Tipo",2) IN ('00','91','97','98') THEN
						CASE
							WHEN ISNULL("Serie DUA",'') IN ('','0','00','000','0000') THEN CONVERT(VARCHAR(20),'')--'0000'CAMBIO
						ELSE
							CONVERT(VARCHAR(20), ISNULL("Serie DUA",'0000'))
							--CONVERT(VARCHAR(20), RIGHT('0000'+ LTRIM(RTRIM("Serie DUA")),4))
						END
				END
			),
			"Fecha DUA",
			/* = 
			(
				CASE
					WHEN LEFT("Tipo",2) NOT IN ('50','52') THEN '0'
					WHEN LEFT("Tipo",2) IN ('50','52') THEN "Fecha DUA"
				END
			),
			*/
			"Numero DUA" = --
			(
				CASE
					WHEN LEFT("Tipo",2) IN ('00','91','97','98') THEN
					CASE	
						WHEN ISNULL("Numero DUA",'') IN ('','0','00','000','0000','00000','000000','0000000') THEN CONVERT(VARCHAR(20),'00000000000000000000')
					ELSE
						CONVERT(VARCHAR(20), RIGHT('00000000000000000000'+ LTRIM(RTRIM("Numero DUA")),20))
					END
					--WHEN LEFT("Tipo",2) IN('21','28','50','52') THEN CONVERT(VARCHAR(20), ISNULL("Serie DUA",'-')) --// FALTA MAS OPCIONES
				ELSE CONVERT(VARCHAR(20),"Numero DUA")
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
				ELSE REPLACE(REPLACE(CONVERT(VARCHAR(100),"Razon Social"),'ü','u'),'ñ','n')
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
			
			
			"Tipo Origen" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN('07','08','87','88','97','98','91') THEN CONVERT(VARCHAR(2), ISNULL("Tipo Origen",''))
				ELSE ''
				END
			),
		
			"Serie Origen" = CONVERT(VARCHAR(100), ISNULL("Serie Origen",'')),
			"Numero Corr. Origen" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN ('07','08','87','88','97','98','91') THEN
						CONVERT(VARCHAR(100), ISNULL("Numero Corr. Origen",''))
				ELSE ''
				END
			),

			"Num.Comp.pago no domiciliado" = 
			(
				CASE 
					WHEN LEFT("Tipo",2) IN('91','97','98') THEN CONVERT(VARCHAR(100), ISNULL("Num.Comp.pago no domiciliado",''))
				ELSE ''
				END
			),
			"Estado" = ISNULL(
			(
			CASE
				WHEN LEFT(TIPO,2) IN ('03','16','07','91') THEN '0'
				WHEN CONVERT(CHAR(4),YEAR(@FI))+(CASE WHEN LEN(MONTH(@FI))=1 THEN '0'+ CONVERT(CHAR(2),MONTH(@FI))ELSE CONVERT(CHAR(2),MONTH(@FI))END) = (CONVERT(CHAR(4), "Anio Emision") + (CASE WHEN LEN("Mes Emision")=1 THEN '0'+ CONVERT(CHAR(2),"Mes Emision")ELSE CONVERT(CHAR(2),"Mes Emision")END))
				AND LEFT("Tipo",2) IN('03')  THEN '0' 
				WHEN CONVERT(CHAR(4),YEAR(@FI))+(CASE WHEN LEN(MONTH(@FI))=1 THEN '0'+ CONVERT(CHAR(2),MONTH(@FI))ELSE CONVERT(CHAR(2),MONTH(@FI))END) = (CONVERT(CHAR(4), "Anio Emision") + (CASE WHEN LEN("Mes Emision")=1 THEN '0'+ CONVERT(CHAR(2),"Mes Emision")ELSE CONVERT(CHAR(2),"Mes Emision")END)) THEN '0' 
				WHEN CONVERT(CHAR(4),YEAR(@FI))+(CASE WHEN LEN(MONTH(@FI))=1 THEN '0'+ CONVERT(CHAR(2),MONTH(@FI))ELSE CONVERT(CHAR(2),MONTH(@FI))END) > (CONVERT(CHAR(4), "Anio Emision") + (CASE WHEN LEN("Mes Emision")=1 THEN '0'+ CONVERT(CHAR(2),"Mes Emision")ELSE CONVERT(CHAR(2),"Mes Emision")END)) AND (DATEDIFF(MONTH, "Fecha Emision", "Fecha Contabilizacion") <= 12) THEN '9' -- Dentro de 12 Meses
				WHEN CONVERT(CHAR(4),YEAR(@FI))+(CASE WHEN LEN(MONTH(@FI))=1 THEN '0'+ CONVERT(CHAR(2),MONTH(@FI))ELSE CONVERT(CHAR(2),MONTH(@FI))END) > (CONVERT(CHAR(4), "Anio Emision") + (CASE WHEN LEN("Mes Emision")=1 THEN '0'+ CONVERT(CHAR(2),"Mes Emision")ELSE CONVERT(CHAR(2),"Mes Emision")END)) AND (DATEDIFF(MONTH, "Fecha Emision", "Fecha Contabilizacion") >  12) THEN '0' -- Luego de 12 Meses		
			END	
			),''),
			"ObjectType",
			"DocumentEntry",
			"Codigo Moneda",
			"Pais_sujeto",
			"Razon_social_sujeto ",
			"Dominicio_Extranjero",
			"Num_Iidentidad_Sujeto",
			"Num_fiscal_Beneficiario",
			"Razon_Social_beneficiario",
			"Pais_beneficiario",
			"Vinculo_contribuyente",
			"Renta_Bruta",
			"Deduccion",
			"Renta Neta",
			"Taza Retencion",
			"Impuesto Retenido",
			"Convenio_Evitar",
			"Exoneracion Amplia",
			"Tipo Renta",
			"Modalidad Servicio",
			"Aplicaion 76",
			"Retencion",
			"Campo Libre"
		FROM 
		--"STR_VW_RegistroCompras"

			(
			
				SELECT
					"RUC Empresa" = (SELECT TOP 1 "TaxIdNum" FROM "OADM"),
					"Razon Social Empresa" = (SELECT TOP 1 "PrintHeadr" FROM "OADM"),
					"Numero Unico",
					--"Numero Correlativo del Asiento Contable" = ('M' + CAST("Numero Unico" AS VARCHAR(20))),
					"Numero Correlativo del Asiento Contable" = CAST("Numero Unico del Asiento Contable" AS VARCHAR(20)),
					
					"Numero correlativo",
	
					"Fecha Contabilizacion",
					/* Campos para Libros Electronicos */
					'Dia Contabilizacion' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Contabilizacion",'D'),'01'),
					'Mes Contabilizacion' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Contabilizacion",'M'),'01'),
					'Anio Contabilizacion' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Contabilizacion",'A'),'0001'),
					/* Campos para Libros Electronicos */
	
					"Fecha Emision",
					/* Campos para Libros Electronicos */
					'Dia Emision' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Emision",'D'),'01'),
					'Mes Emision' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Emision",'M'),'01'),
					'Anio Emision' = ISNULL("DBO"."STR_FN_Get_Dia_Mes_Anio"("Fecha Emision",'A'),'0001'),
					/* Campos para Libros Electronicos */
					"Tipo",
					"Serie DUA",
					"Fecha DUA",
					"Numero DUA",
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
					ISNULL("Tipo de cambio",'') AS "Tipo de cambio",
					"Tipo Origen",
					"Serie Origen",
					"Numero Corr. Origen",
					"ObjectType",
					"DocumentEntry",
					"Codigo Moneda",
					"Retencion",
					"Pais_sujeto",
					"Razon_social_sujeto ",
					"Dominicio_Extranjero",
					"Num_Iidentidad_Sujeto",
					"Num_fiscal_Beneficiario",
					"Razon_Social_beneficiario",
					"Pais_beneficiario",
					"Vinculo_contribuyente",
					"Renta_Bruta",
					"Deduccion",
					"Renta Neta",
					"Taza Retencion",
					"Impuesto Retenido",
					"Convenio_Evitar",
					"Exoneracion Amplia",
					"Tipo Renta",
					"Modalidad Servicio",
					"Aplicaion 76",
					"Campo Libre"
				FROM
				(
					--/// OPCH: REGISTRO DE COMPRAS ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN T3.WTLiable = 'Y' THEN 'M-RER' --Para Agentes de Retencion
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
									WHEN EXISTS (SELECT 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
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
									WHEN EXISTS (SELECT TOP 1 'SA' FROM ODPO WHERE DocEntry IN(SELECT BaseAbs FROM PCH9 WHERE DocEntry=T0.DocEntry) AND ISNULL(TransId, '') <> '') THEN 
										ISNULL((SELECT SUM(VatSUM) FROM PCH11 WHERE DocEntry=T0.DocEntry AND BaseType='204' AND LineType='D' AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='C' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
								ELSE 0
								END
							)
						),
		
						'Adquisiones no gravadas' = 
						
						 
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
		
						--'Importe Total'	= 0,
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
							ELSE NULL
							END
						),
						'Tipo Origen' =T0.U_STR_TipoDua ,
						/*
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDTO
							ELSE NULL 
							END
						),
						*/
						
						'Serie Origen' = T0.U_STR_SerieDua ,
						/*
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDSO 
							ELSE NULL 
							END
						),
						*/
						'Numero Corr. Origen' = T0.U_BPP_MDND,
						/*
						(
							CASE T0.DocSubType 
								WHEN 'DM' THEN T0.U_BPP_MDCO
							ELSE NULL
							END
						),
						*/
						'ObjectType' = CONVERT(NVARCHAR(15), T0.ObjType),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0.DocEntry) ,
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = isnull(
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM PCH5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp='Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN 1
							ELSE null
							END
						),''),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = CASE T0.DocType 
													WHEN 'I' THEN 
														CASE (SELECT TOP 1 (SELECT ItemType FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM PCH1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT TOP 1 (SELECT U_BPP_TIPEXIST FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM PCH1 TX0 WHERE TX0.DocEntry = T0.DocEntry) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
													ELSE 
														CASE (SELECT TOP 1 LEFT(AcctCode,1) FROM PCH1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN '6' THEN '4' ELSE '5' END
												  END,
						'Pais_sujeto'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),
						'Razon_social_sujeto '=T3.CardName,
						'Dominicio_Extranjero'='',---20
						'Num_Iidentidad_Sujeto'=T3.LicTradNum,----21
						'Num_fiscal_Beneficiario'='',---22
						'Razon_Social_beneficiario'=T3.CardName,--23
						'Pais_beneficiario'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),---24
						'Vinculo_contribuyente'=isnull(T3.U_STR_TipoVinc,'') ,--25
						'Renta_Bruta'=
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
						)
						,--26
						'Deduccion'='',--27
						'Renta Neta'=T0.DocTotal,--28
						'Taza Retencion'=CONVERT(decimal(12,2),(SELECT (RATE/1.18)FROM PCH5 WHERE ABSENTRY=T0.DOCENTRY)),--29
						'Impuesto Retenido'=T0.WTSum,--30
						'Convenio_Evitar'='09',-------31
						'Exoneracion Amplia'='',----32
						'Tipo Renta'='00',---33
						'Modalidad Servicio'='',--34
						'Aplicaion 76'='',--35
						'Campo Libre'=T0.DocNum--37
					FROM "OPCH" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					--INNER JOIN ""
					WHERE
						(1 = 1)
					AND (T3.U_BPP_BPTP='SND')
					AND	(T1."TransType" = '18')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL("U_excluir", 'N') != 'Y'))
					/*ADD*/ AND T0."U_BPP_MDTD"  IN ('00','91','97','98')
					
					UNION ALL
	
	
					--/// ORPC: NOTA DE CREDITO PROVEEDOR ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN T3.WTLiable = 'Y' THEN 'M-RER' --Para Agentes de Retencion
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
							CASE WHEN T0."U_BPP_MDTD" 
								= '91' THEN T0."U_BPP_SND"
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
		
						'Tipo Origen' = T0."U_STR_TipoDua",
		
						
						'Serie Origen' = T0."U_STR_SerieDua",
						'Numero Corr. Origen' = T0."U_BPP_MDND",
						'ObjectType' = CONVERT(NVARCHAR(15), T0.ObjType),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0.DocEntry),
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = isnull(
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM RPC5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp='Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN 1
							ELSE null
							END
						),''),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = CASE T0.DocType 
													WHEN 'I' THEN 
														CASE (SELECT TOP 1 (SELECT ItemType FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM RPC1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT TOP 1 (SELECT U_BPP_TIPEXIST FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM RPC1 TX0 WHERE TX0.DocEntry = T0.DocEntry) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
													ELSE 
														CASE (SELECT TOP 1 LEFT(AcctCode,1) FROM RPC1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN '6' THEN '4' ELSE '5' END
												  END,
						'Pais_sujeto'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),
						'Razon_social_sujeto '=T3.CardName,
						'Dominicio_Extranjero'='',---20
						'Num_Iidentidad_Sujeto'=T3.LicTradNum,----21
						'Num_fiscal_Beneficiario'='',---22
						'Razon_Social_beneficiario'=T3.CardName,--23
						'Pais_beneficiario'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),---24
						'Vinculo_contribuyente'=isnull(T3.U_STR_TipoVinc,'') ,--25
						'Renta_Bruta'=
						
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
						),--26
						'Deduccion'='',--27
						'Renta Neta'=T0.DocTotal,--28
						'Taza Retencion'=CONVERT(decimal(12,2),(SELECT (RATE/1.18)FROM PCH5 WHERE ABSENTRY=T0.DOCENTRY)),--29
						'Impuesto Retenido'=T0.WTSum,--30
						'Convenio_Evitar'='09',-------31
						'Exoneracion Amplia'='',----32
						'Tipo Renta'='00',---33
						'Modalidad Servicio'='',--34
						'Aplicaion 76'='',--35
						'Campo Libre'=T0.DocNum--37
					FROM "ORPC" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					WHERE
						(1 = 1)
						AND (T3.U_BPP_BPTP='SND')
					AND	(T1."TransType" = '19')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL("U_excluir", 'N') != 'Y'))
					/*ADD*/ AND T0."U_BPP_MDTD"  IN ('00','91','97','98')
	
					UNION ALL
	
	
					--/// ODPO: FACTURAS DE ANTICIPO ============================================================================
					SELECT
						'Numero Unico' = T1."TransId",
						'Numero Unico del Asiento Contable' = (CASE WHEN T3.WTLiable = 'Y' THEN 'M-RER' --Para Agentes de Retencion
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
						/*
						---------------ANTERIOR STANDAR
						CASE WHEN T3.U_BPP_BPTP='SND' OR (SELECT TOP 1 PC.LineTotal FROM PCH1 PC WHERE PC.DocEntry = T0.DocEntry AND PC.ItemCode = (SELECT TOP 1 OI.ItemCode FROM OITM OI WHERE OI.ItemCode=PC.ItemCode AND  ISNULL(OI.U_BPP_PrPc,0)<>0))<>0 
				
							THEN 0 ELSE
						(
							ISNULL((SELECT SUM(LineTotal) FROM DPO1 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0) 
							+
							ISNULL((SELECT SUM(LineTotal) FROM DPO3 WHERE DocEntry = T0.DocEntry AND TaxCode IN(SELECT ISNULL(U_STR_IMPUESTO, '') FROM "@STR_CLMIMP" WHERE ISNULL(U_STR_COLUMNA, '')='D' AND ISNULL(U_STR_FORMATO, '')='08.01')), 0)
						) END
						,
						*/
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
												WHEN UPPER(T0.DocCur) = 'SOL' THEN 0
											ELSE T0."DocRate"
											END
										) AS DECIMAL(18,3)
									)
								) AS CHAR(20)
							)
						),
						'Fecha Origen' = NULL,
						'Tipo Origen' = T0.U_STR_TipoDua,
						
						'Serie Origen' = T0.U_STR_SerieDua,
						'Numero Corr. Origen' =T0.U_BPP_MDND,
		
						'ObjectType' = CONVERT(NVARCHAR(15), T0."ObjType"),
						'DocumentEntry' = CONVERT(NVARCHAR(15), T0."DocEntry"),
		
						/*------------Campos adiconales para los electronicos------------*/	
						/*F_31*/
						'Retencion' = isnull(
						(
							CASE
								WHEN ISNULL((SELECT TOP 1 'Z' FROM DPO5 T15 INNER JOIN OWHT T16 ON T15.WTCode=T16.WTCode AND T16.U_RetImp = 'Y' WHERE T15.AbsEntry=T0.DocEntry),'') = 'Z' THEN 1
							ELSE NULL
							END 
						),''),
						'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
						'Clasificacion Bienes' = CASE T0.DocType 
													WHEN 'I' THEN 
														CASE (SELECT TOP 1 (SELECT ItemType FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM DPO1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN 'F' THEN '2'
														WHEN 'I' THEN CASE WHEN (SELECT TOP 1 (SELECT U_BPP_TIPEXIST FROM OITM TY0 WHERE TY0.ItemCode =  TX0.ItemCode) FROM RPC1 TX0 WHERE TX0.DocEntry = T0.DocEntry) IN ('01','02','03','04','05') THEN '1' ELSE '3' END END
													ELSE 
														CASE (SELECT TOP 1 LEFT(AcctCode,1) FROM DPO1 TX0 WHERE TX0.DocEntry = T0.DocEntry) WHEN '6' THEN '4' ELSE '5' END
												  END,
						'Pais_sujeto'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),
						'Razon_social_sujeto '=T3.CardName,
						'Dominicio_Extranjero'='',---20
						'Num_Iidentidad_Sujeto'=T3.LicTradNum,----21
						'Num_fiscal_Beneficiario'='',---22
						'Razon_Social_beneficiario'=T3.CardName,--23
						'Pais_beneficiario'=isnull((SELECT TOP 1 BnkBchDgts FROM OCRY TY WHERE TY.CODE=T3.Country),''),---24
						'Vinculo_contribuyente'=isnull(T3.U_STR_TipoVinc,'') ,--25
						'Renta_Bruta'=(
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
						),--26
						'Deduccion'='',--27
						'Renta Neta'=T0.DocTotal,--28
						'Taza Retencion'= CONVERT(decimal(12,2),(SELECT (RATE/1.18)FROM PCH5 WHERE ABSENTRY=T0.DOCENTRY)),--29
						'Impuesto Retenido'=T0.WTSum,--30
						'Convenio_Evitar'='09',-------31
						'Exoneracion Amplia'='',----32
						'Tipo Renta'='00',---33
						'Modalidad Servicio'='',--34
						'Aplicaion 76'='',--35
						'Campo Libre'=T0.DocNum--37
					FROM "ODPO" T0 
					INNER JOIN "OJDT" T1 ON T1."TransId"  = T0."TransId"
					INNER JOIN "OFPR" T2 ON T2."AbsEntry" = T1."FinncPriod"
					INNER JOIN "OCRD" T3 ON T3."CardCode" = T0."CardCode"
					WHERE
						(1 = 1)
					AND (T3.U_BPP_BPTP='SND')
					AND	(T1."TransType" = '204')
					AND (T0."U_BPP_MDSD" <> 'ANL')
					AND (ISNULL(T0."CANCELED", '') <> 'Y')
					AND (T0."U_BPP_MDTD" IN(SELECT N0."U_BPP_TDTD" FROM "@BPP_TPODOC" N0 WHERE ISNULL(N0."U_excluir", 'N') != 'Y'))
					/*ADD*/ AND T0."U_BPP_MDTD"  IN ('00','91','97','98')
				)R
				WHERE
					(LEFT(ISNULL("Tipo", 'ZA'), 2) != 'ZA')
				AND (ISNULL("Numero DUA", '') NOT IN ('', '0'))


			)TT

		WHERE
			(1 = 1)
		AND (LEFT("Tipo",2) <> '02')
		AND ("Fecha Contabilizacion" BETWEEN @FI AND @FF)
	)R
	WHERE
	--(CONVERT(INT,(LEFT(Periodo,4)) + CONVERT(INT, RIGHT(Periodo,2)) ) 
	-->= (CONVERT(INT, "Anio Emision") + CONVERT(INT, "Mes Emision"))) and
	
	 "Numero DUA" NOT LIKE '%AN%'	
	 and left(tipo,2) in ('00','91','97','98')

	SELECT "RUC Empresa",
		   "Periodo LE",
		   "ObjectType",
		   "DocumentEntry",
		"Periodo LE"											--1
	   +'|'+ "CAR"												--2
	   +'|'+ "Fecha Emision"									--3
	   +'|'+LEFT("Tipo",2)										--4
	   +'|'+CAST("Serie DUA" AS VARCHAR(20))					--5
	   +'|'+"Numero DUA" 										--6
	   +'|'+CAST("Adquisiones no gravadas" AS VARCHAR(20))		--7
	   +'|'+CAST("Otros tributos" AS VARCHAR(20))				--8
	   +'|'+CAST("Importe Total" AS VARCHAR(20))				--9
	   +'|'+"Tipo Origen" 										--10
	   +'|'+"Serie Origen"										--11
	   +'|'+CASE WHEN "Tipo Origen" IN ('50','52') THEN
			right("Fecha Emision",4)ELSE ''	END					--12
		--+'|'+right("Fecha Emision",4)							
		+'|'+CAST("Numero Corr. Origen" 	AS VARCHAR(20))		--13
		+'|'+ cast(isnull("Retencion",'0')	as varchar(12))		--14
		+'|'+"Codigo Moneda"									--15
		+'|'+RTRIM("Tipo de cambio")							--16
		+'|'+ cast("Pais_sujeto" as varchar(4))					--17
		+'|'+ "Razon_social_sujeto "							--18
		+'|'+ "Dominicio_Extranjero"							--19
		+'|'+ "Num_Iidentidad_Sujeto"							--20
		+'|'+ "Num_fiscal_Beneficiario"							--21
		+'|'+ "Razon_Social_beneficiario"						--22
		+'|'+ cast("Pais_beneficiario" as varchar(4))			--23
		+'|'+ "Vinculo_contribuyente"							--24
		+'|'+ cast(isnull("Renta_Bruta",'0') as varchar(12))	--25
		+'|'+ "Deduccion"										--26
		+'|'+ cast(isnull("Renta Neta",'0') as varchar(12))		--27
		+'|'+ cast(isnull("Taza Retencion",'0') as varchar(12))	--28
		+'|'+ cast(isnull("Impuesto Retenido",'0') as varchar(12))--29
		+'|'+ "Convenio_Evitar"									--30
		+'|'+ "Exoneracion Amplia"								--31
		+'|'+ "Tipo Renta"										--32
		+'|'+ "Modalidad Servicio"								--33
		+'|'+ "Aplicaion 76"									--34
		+'|'+ "CAR CP"											--35
		+'|'
	   AS "PLE" 
	FROM #Temp;

END