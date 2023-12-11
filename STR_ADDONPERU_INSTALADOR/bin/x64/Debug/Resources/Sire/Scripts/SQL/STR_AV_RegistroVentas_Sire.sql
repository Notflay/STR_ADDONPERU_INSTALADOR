CREATE PROC [dbo].[STR_AV_RegistroVentas_Sire]
(
	@FI DATETIME ='20220701',
	@FF	DATETIME ='20220708'
	
)
AS
BEGIN
	DECLARE @MES CHAR(2)
	DECLARE @ANIO CHAR(4)
	DECLARE @AN INT=1
	SET @MES = CONVERT(CHAR(2), MONTH(@FF))
	SET @ANIO = CONVERT(CHAR(4), YEAR(@FF))
	
	IF LEN(@MES) = 1
	BEGIN
		SET @MES = '0' + @MES
	END

	/*************************************************/
	------------------------------ Registro Electronico 
SELECT 
		[Periodo RL],
		[Periodo],
		[RUC Empresa],
		[Razon Social Empresa],
		[CAR], 
		[Numero Correlativo],
		[Numero Correlativo Asiento Contable],
		[Fecha Emision] = [Fecha Emision_LE],
		/*(
			CONVERT
				(VARCHAR(10),
					(
						CASE
							WHEN (CONVERT(VARCHAR(4),YEAR([Fecha Emision])) + RIGHT('0'+CAST(MONTH([Fecha Emision]) AS VARCHAR(2)),2)) > (CONVERT(VARCHAR(4), @ANIO) + CONVERT(VARCHAR(2),@MES)) THEN [Fecha Emision_LE]
						ELSE [Fecha Emision_LE]
						END
					)
				)
		),*/

		[Fecha Vencimiento] = CASE WHEN LEFT("Tipo",2) = ('14') AND [Estado] != '2' THEN [Fecha Vencimiento_LE] ELSE '' END,
		/*(
			CONVERT
				(VARCHAR(10),
					(
						CASE
							WHEN LEFT("Tipo",2) IN ('14') AND [Estado] != '2' THEN '01/01/0001'
							WHEN (CONVERT(VARCHAR(4),YEAR([Fecha Vencimiento])) + RIGHT('0'+CAST(MONTH([Fecha Vencimiento]) AS VARCHAR(2)),2)) > (CONVERT(VARCHAR(4), @ANIO) + CONVERT(VARCHAR(2),@MES)) THEN [Fecha Vencimiento_LE]
						ELSE [Fecha Vencimiento_LE]
						END
					)
				)	
		),*/
		[Tipo],
		[Serie],
		[Numero],
		[Campo 9],
		[Tipo Doc. Identidad],
		[RUC],
		[Razon Social],
		[Total Facturado],
		[Base Imponible],
		[Exonerada],
		[Inafecta],
		[ISC],
		[IGV],
		[Campo 21],
		[Campo 22],
		[Otros],
		[Importe Total],
		[Tipo de Cambio],
		[Fecha Doc Original],
		[Tipo Tabla 10],
		[Serie Doc Original],
		[Numero Doc Original],
		[Estado],
		--[Valor FOB],
		[ObjectType],
		[DocumentEntry],
		[DsctoBaseImponible],
		[DsctoImpuestoGeneral], 
		[Codigo Moneda],
		[Contrato],
		[TipoNota],
		[InternoSunat1], 
		[Referencial],
		[Tipo Operacion],
		[Inconsistencias],
		[InternoSunat2]
		INTO #Temp
	FROM 
	
	(
		SELECT
			[Periodo RL] = (@ANIO + '' + @MES),
			[Periodo]= (CASE WHEN ISNULL([Periodo],'') = '' THEN @ANIO + @MES ELSE [Periodo] END),
			[RUC Empresa],
			[Razon Social Empresa],
			[CAR] = 
			CONCAT([RUC Empresa],LEFT("Tipo",2),CAST("Serie" AS VARCHAR(20)),RIGHT( '0000000000' + CAST( "Numero" AS VARCHAR(20)),10)),
	
			[Numero Correlativo] = ISNULL(CONVERT(VARCHAR(40), [Numero Correlativo]),'0000'),
			[Numero Correlativo Asiento Contable] = ISNULL(CONVERT(VARCHAR(40), [Numero Correlativo Asiento Contable]),'M0000'),
			[Fecha Emision],
			[Fecha Emision_LE] = 
			(
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'D'),'01') + '/' + 
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'M'),'01') + '/' + 
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'A'),'0001')
			),
			[Fecha Vencimiento],
			[Fecha Vencimiento_LE] = 
			(
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'D'),'01') + '/' + 
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'M'),'01') + '/' + 
				ISNULL([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision_LE],'A'),'0001')
			),
			[Tipo] = 
			(
				CASE
					WHEN ISNULL([Tipo],'') = '' THEN '00'
				ELSE CONVERT(VARCHAR(100), LEFT([Tipo],2))
				END
			),
			[Serie] = 
			(
				CASE
					WHEN LEFT(Tipo,2) ='05' THEN '3'--CONVERT(CHAR(1), RIGHT([Serie],1))
					WHEN LEFT(Tipo,2) ='55' THEN '2'
					WHEN LEFT([Tipo],2) = '00' THEN CONVERT(VARCHAR(20), '-')
					WHEN LEFT([Tipo],2)IN ('01','03','04','07','08','56') THEN  CONVERT(VARCHAR(20), RIGHT('0000'+[Serie],4))

				ELSE CONVERT(VARCHAR(20),[Serie])
				END
			),
			[Numero] =
			--NUMERO DE DOCUMENTO DE 7 DIGITOS 
			CASE 
				WHEN LEFT(TIPO,2) IN ('01','03','04','06','07','08','23') THEN CONVERT(VARCHAR(7), RIGHT('0000000' + Numero, 7))
			-- NUMERO DE DOCUMENTO DE 11 DIGITOS
				WHEN LEFT(TIPO,2) IN ('05','55','56') THEN  CONVERT(VARCHAR(11), RIGHT('00000000000'+Numero,11))
			-- NUMERO DE DOCUMENTO DE 20+ DIGITOS
			ELSE CONVERT(VARCHAR(20),Right([Numero],7))
			END ,
			[Campo 9] = '',
			[Tipo Doc. Identidad] = 
			(
				CASE
					WHEN ISNULL([Tipo Doc. Identidad],'') = '' THEN '0'
				ELSE CONVERT(VARCHAR(15), [Tipo Doc. Identidad])
				END
			),
			[RUC] = 
			(
				CASE
					WHEN ISNULL([Tipo Doc. Identidad],'') = '' THEN '99999999999'
					WHEN ISNULL([RUC],'') = '' THEN '-'
				ELSE [RUC]
				END
			),
			[Razon Social] = 
			(
				CASE
					WHEN ISNULL([Razon Social],'') = '' THEN '-'
				ELSE CONVERT(VARCHAR(60),[Razon Social])
				END
			),
			[Total Facturado] = CASE WHEN ISNULL([Tipo Doc. Identidad],'') IN ('','0') THEN '0.01' ELSE CONVERT(DECIMAL(15,2), [Total Facturado]) END ,
			[Base Imponible] = CONVERT(DECIMAL(15,2), ISNULL([Base Imponible],0)),
			[Exonerada] = CONVERT(DECIMAL(15,2), ISNULL([Exonerada],0)),
			[Inafecta] = CONVERT(DECIMAL(15,2), ISNULL([Inafecta],0)),
			[ISC] = CONVERT(DECIMAL(15,2), ISNULL([ISC],0)),
			[IGV] = CONVERT(DECIMAL(15,2), ISNULL( [IGV],0)),
			[Campo 21] = '0.00',
			[Campo 22] = '0.00',
			[Otros] = CONVERT(DECIMAL(15,2), ISNULL([Otros],0)),
			[Importe Total] = CONVERT(DECIMAL(15,2), ISNULL([Importe Total],0)),
			[Tipo de Cambio] = CONVERT(VARCHAR(5), CONVERT(DECIMAL(15,3), ISNULL([Tipo de Cambio],NULL))),
		
			[Fecha Doc Original] = 
			(
				CASE
					WHEN ISNULL([Fecha Doc Original],'') = '' THEN ''
					WHEN  LEFT([Tipo],2) IN ('07','08','87','88','97','98') AND ISNULL([Fecha Emision],'') <> '' THEN ([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'D') + '/' + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'M') + '/' + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'A'))
				ELSE ([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'D') + '/' + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'M') + '/' + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Doc Original],'A'))
				END
			),
			[Tipo Tabla 10] = 
			(
				CASE
					WHEN LEFT([Tipo],2) IN ('07','08','87','88','97','98') AND ISNULL([Fecha Emision],'') <> ''  THEN CONVERT(VARCHAR(2),[Tipo Tabla 10])
				ELSE ''
				END
			),
			[Serie Doc Original] = 
			(
				CASE
					WHEN LEFT([Tipo],2) IN ('07','08','87','88','97','98') AND ISNULL(CONVERT(VARCHAR(10),[Fecha Emision]),'') <> '' THEN 
						CASE
							WHEN LEFT([Tipo],2) IN ('07','08') THEN 
							 CASE 
								WHEN LEN(ISNULL([Serie Doc Original],'')) <= 4 THEN CONVERT(VARCHAR(20),(RIGHT('0000'+LTRIM(RTRIM([Serie Doc Original])),4)))
								WHEN LEN(ISNULL([Serie Doc Original],'')) > 6 THEN CONVERT(VARCHAR(20),(RIGHT(LTRIM(RTRIM([Serie Doc Original])),6)))
							 END
							WHEN LEFT([Tipo],2) IN ('07','08') THEN CONVERT(VARCHAR(20),[Serie Doc Original])
						END
					WHEN LEFT([Tipo],2) NOT IN ('07','08','87','88','97','98') THEN CONVERT(VARCHAR(20),'')
					ELSE ''
				END
			),
			[Numero Doc Original] = 
			(
				CASE
					WHEN LEFT([Tipo],2) IN ('07','08','87','88','97','98') AND ISNULL([Fecha Emision],'') <> '' AND [Tipo Tabla 10] <> '12' THEN CONVERT(VARCHAR(20), [Numero Doc Original])
					WHEN ISNULL([Numero Doc Original],'') = '' THEN ''
				END
			),
			[Estado] = 
			(
				CASE
					WHEN ISNULL([Fecha Emision],'') = '' THEN '2' 
					WHEN ([Periodo] = (@ANIO + '' + @MES)) THEN '1'
					WHEN [Operacion] IN ('I','E') THEN
					(
						CASE 
							WHEN ([Fecha Emision] < @FI) THEN 
							(
								CASE
									WHEN ([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision],'A')   +  [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision],'M')) <  ([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Documento],'A') + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Documento],'M')) THEN '8'
								END
							)
						END
					)
				END
			),
			--[Valor FOB],
			[ObjectType],
			[DocumentEntry],
			[DsctoBaseImponible],
			[DsctoImpuestoGeneral], 
			[Codigo Moneda],
			[Contrato],
			[TipoNota],
			[InternoSunat1], 
			[Referencial],
			[Tipo Operacion],
			[Inconsistencias],
			[InternoSunat2]
		FROM 
			--[STR_VW_RegistroVentas]
		(
			SELECT
				[RUC Empresa] = (SELECT TOP 1 [TaxIdNum] FROM [OADM]),
				[Razon Social Empresa] = (SELECT TOP 1 [PrintHeadr] FROM [OADM]),
				[Periodo] = ([DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision],'A') + [DBO].[STR_FN_Get_Dia_Mes_Anio]([Fecha Emision],'M')),
				[Numero Correlativo],
				[Numero Correlativo Asiento Contable],
				[Fecha Documento],
				[Fecha],
				[Fecha Emision],
				[Fecha Emision_LE] = [Fecha Emision],
				[Fecha Vencimiento],
				[Fecha Vencimiento_LE] = [Fecha Vencimiento],
				[Tipo],
				[Serie],
				[Numero],
				[Tipo Doc. Identidad],
				[RUC],
				[Razon Social],
				[Total Facturado],
				[Base Imponible],
				[Exonerada],
				[Inafecta],
				[ISC],
				[IGV],
				[Otros],
				[Importe Total],
				[Tipo de Cambio],
				[Fecha Doc Original],
				[Tipo Tabla 10],
				[Serie Doc Original],
				[Numero Doc Original],
				[Operacion],
				--"Valor FOB",
				[ObjectType],
				[DocumentEntry],
				[DsctoBaseImponible],
				[DsctoImpuestoGeneral], 
				[Codigo Moneda],
				[Contrato],
				[TipoNota],
				[InternoSunat1], 
				[Referencial],
				[Tipo Operacion],
				[Inconsistencias],
				[InternoSunat2]
			FROM
			(
				--/// OINV: FACTURA DE CLIENTE ============================================================================
				SELECT 
					'Numero Correlativo' = T0.[TransId],
					--'Numero Correlativo Asiento Contable' = ('M' + CAST(T0.[TransId] AS VARCHAR(20))),
					'Numero Correlativo Asiento Contable' = (CASE	WHEN T1.U_STR_AR = 'Y' THEN 'RER-M' --Para Agentes de Retencion
																	WHEN T2.TransType = -2 THEN 'A' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T2.TransType = -3 THEN 'C' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T0."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
					'Fecha Documento' = T0.[DocDate],
					'Fecha' = T0.[TaxDate],
					'Fecha Emision' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL
						ELSE T0.[TaxDate]
						END
					)
					,
					'Fecha Vencimiento' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL
						ELSE T0.[DocDueDate]
						END
					),
					'Tipo' = (SELECT TOP 1 ISNULL([U_BPP_TDTD], '') + '-' + ISNULL([U_BPP_TDDD], '') FROM [@BPP_TPODOC] WHERE ISNULL([U_BPP_TDTD], '') = ISNULL(T0.[U_BPP_MDTD], '')),
					'Serie' = ISNULL(T0.[U_BPP_MDSD], ''),
					'Numero' = ISNULL(T0.U_BPP_MDCD, ''),
					'Tipo Doc. Identidad' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry = A0.TrgetEntry)='999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE T1.[U_BPP_BPTD]
						END
					),
		
					'RUC' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS (SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE T1.[LicTradNum]
						END
					),
		
					'Razon Social' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 'Anulado'
							WHEN EXISTS (SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 'Anulado'
						ELSE
							CASE
								WHEN T1.[U_BPP_BPTP] = 'TPN' THEN ISNULL(T1.[U_BPP_BPAP], ' ')+' '+ ISNULL(T1.[U_BPP_BPAM], ' ')+' '+ ISNULL(T1.[U_BPP_BPNO], ' ') 
							ELSE T1.[CardName]
							END   
							END
					),
		
					'Total Facturado' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0 
						ELSE
							CASE
								WHEN T1.U_BPP_BPTP='SND' /*T0.[DocSubType] = 'IX'*/ THEN(T0.[DocTotal] - T0.[VatSum])
							ELSE 0 
							END 
						END
					),
		
					'Base Imponible' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND  (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
						(
				
							CASE
								WHEN T0.[DocSubType] <> 'IX' THEN 	
					
								--//STRAT:20131216 check de solo impuesto 
							CASE WHEN NOT  EXISTS (SELECT top 1 'A' FROM INV1 I WHERE I.DocEntry=T0.DocEntry and TaxOnly='Y')
				
							THEN
									ISNULL(( SELECT SUM(ISNULL("SUMA", 0)) FROM (
										SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) --SUM(LineTotal) 
												- CASE WHEN "TaxCode" = 'INM'THEN T0.[DiscSum] / 2 ELSE 0 END "SUMA"
										FROM INV1 WHERE DocEntry=T0.DocEntry AND 
												TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')
												GROUP BY TaxCode )
												TTSOURCE), 0)
					
								--/// STRAT: 13092012 Descuenta Anticipo  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								- 
								(
									CASE
										WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END )--SUM(LineTotal)
											FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt]
									ELSE 0
									END
								)
					
								--/// STRAT: 15012013 descuenta portes- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN 0 ELSE LineTotal END )--SUM(LineTotal) 
										FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
									ELSE 0 
									END	
					
								)
					
								ELSE 0 END
					
							ELSE 0 END
						)
						END
					),
		
					'Exonerada' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry)  THEN 0
				
						ELSE
						(
							CASE
								WHEN T0.[DocSubType] <> 'IX' AND T1.U_BPP_BPTP<>'SND' THEN
								--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								ISNULL((
										SELECT SUM(ISNULL("SUMA", 0)) FROM (
														SELECT 
															SUM(CASE WHEN "TaxCode"='INM'THEN LineTotal / 2 ELSE LineTotal  END ) - 
															CASE WHEN "TaxCode" = 'INM'THEN T0.[DiscSum] / 2 ELSE 0 END "SUMA"
														FROM	INV1 
														WHERE	DocEntry = T0.DocEntry 
														AND		("TaxCode" = 'INM' OR "TaxCode" IN (SELECT	U_STR_IMPUESTO 
																									FROM	[@STR_CLMIMP] 
																									WHERE	U_STR_COLUMNA='B' 
																									AND		ISNULL(U_STR_FORMATO, '') = '14.01'))
														GROUP BY "TaxCode"
														) TTSOURCE
											), 0)
					
								--/// STRAT: 13092012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END )--SUM(LineTotal) 
										FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt]
									ELSE 0 
									END
								)
					
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE WHEN (ISNULL((SELECT SUM(LineTotal) FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN(SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
									ELSE 0
									END
								)
							ELSE 0 END
						)
						END
					),
		
					'Inafecta' =  
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							CASE 
								WHEN T0.[DocSubType] <> 'IX' THEN
								--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								ISNULL((SELECT SUM(LineTotal) FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
					
								--/// STRAT: 13092012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt]
										ELSE 0
									END
								)
					
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM INV1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
									ELSE 0
									END
								)
							ELSE 0 
							END
						END
					),
					'ISC' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN INV4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
						END
					),
		
					'IGV' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN INV4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
						END
					),					
					'Otros' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							(
								T0.VatSUM
								-
								ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN INV4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
								-
								ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN INV4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
								+
								T0.[RoundDif]
							)
						END
					),
		
					--/// STRAT - Cambio en importe total: Se añadio al DocTotal el campo WTAmnt de INV5
					--/// STRAT Caso 3656  - Cambio en importe total: Se añadio la resta del gasto Adicional, debido a la funcionalidad de percepciones ABFrance
					--/// Fecha : 17/12/2014
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
		
					'Importe Total' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE T0.[DocTotal] + (SELECT ISNULL(SUM(A.WtAmnt),0)- (case when t0.doccur='sol' then isnull(t0.totalexpns,0) else isnull(t0.totalexpSC,0) end ) FROM INV5 A WHERE A.AbsEntry=T0.DocEntry AND (UPPER(A.[Category]) = 'I'))
						END
					),
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
		
					'Tipo de Cambio' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL
						ELSE
							CASE
								WHEN UPPER(T0.DocCur) = 'SOL' THEN NULL	
							ELSE CAST(T0.DocRate AS DECIMAL(19, 3))
							END
						END
					),
					'Fecha Doc Original' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE 
							CASE
								WHEN T0.DocSubType ='DN' THEN CONVERT(NVARCHAR(10),T0.U_BPP_SDocDate,112)
							ELSE ''
							END  
						END
					),
					'Tipo Tabla 10' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE 
							CASE T0.DocSubType 
								WHEN 'DN' THEN ISNULL(T0.U_BPP_MDTO,'') 
							ELSE ''
							END
						END
					),
					'Serie Doc Original' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE
							CASE T0.DocSubType 
								WHEN 'DN' THEN ISNULL(SUBSTRING(T0.U_BPP_MDSO, 1, CASE WHEN (CHARINDEX('-', T0.U_BPP_MDSO)-1) < 0 THEN Len(T0.U_BPP_MDSO)  ELSE CHARINDEX('-', T0.U_BPP_MDSO)-1 END ),'')
							ELSE ''
							END 
						END
					),
					'Numero Doc Original' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE
							CASE T0.DocSubType
								WHEN 'DN' THEN  ISNULL(T0.U_BPP_MDCO,'')
							ELSE ''
							END 
						END
					),
					'Operacion' = T0.[U_BPP_OPER],
					--'Valor FOB' = 0,
					'ObjectType' = CONVERT(NVARCHAR(15), T0.[ObjType]),
					'DocumentEntry' = CONVERT(NVARCHAR(15), T0.[DocEntry]),
					'DsctoBaseImponible' = T0.[DiscSum],
					'DsctoImpuestoGeneral' = 
						(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
							ELSE 
								CASE WHEN GrosProfit = 0 THEN 0 
								ELSE  ISNULL(((T0.GrosProfit + T0."DiscSum") * (VatSum/GrosProfit)) - VatSum,0) END
						END
						),
					'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
					'Contrato' = '',
					'TipoNota' = '',
					'InternoSunat1' = '',
					'Referencial' = '',
					'Tipo Operacion' = '',
					'Inconsistencias' = '',
					'InternoSunat2' = ''

				FROM [OINV] T0
				INNER JOIN [OCRD] T1 ON T1.CardCode = T0.CardCode
				INNER JOIN [OJDT] T2 ON T2.TransId = T0.TransId
				WHERE
					(ISNULL(T0.[CANCELED], '') != 'C')
				AND (ISNULL(T0.[U_BPP_MDTD], '') != '')
				AND (ISNULL(T0.[U_BPP_MDTD], '') NOT IN('','NC'))
				AND (ISNULL(T0.[U_BPP_MDSD], '') NOT IN('','999'))
				
				AND (T0.[U_BPP_MDTD] IN(SELECT T0.[U_BPP_TDTD] FROM [@BPP_TPODOC] T0 WHERE ISNULL(T0.[U_excluir], 'N') != 'Y'))
	
	
				UNION ALL
	
	
				--/// ORIN: NOTA DE CREDITO ============================================================================
	
				SELECT DISTINCT
					'Numero Correlativo' = T0.[TransId],
					--'Numero Correlativo Asiento Contable' = ('M' + CAST(T0.[TransId] AS VARCHAR(20))),
					'Numero Correlativo Asiento Contable' = (CASE   WHEN T1.U_STR_AR = 'Y' THEN 'RER-M' --Para Agentes de Retencion
																	WHEN T2.TransType = -2 THEN 'A' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T2.TransType = -3 THEN 'C' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T0."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
					'Fecha Documento' = T0.[DocDate],
					'Fecha' = T0.[TaxDate],
					'Fecha Emision' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN T0.[Indicator] = 'ZA' THEN NULL
						ELSE T0.[TaxDate]
						END
					),
					'Fecha Vencimiento' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN T0.[Indicator] = 'ZA' THEN NULL
						ELSE T0.[DocDueDate]
						END
					),
					'Tipo' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN '07-Nota de Credito'
							WHEN T0.Indicator = 'ZA' THEN '07-Nota de Credito'
						ELSE  (SELECT TOP 1 ISNULL(U_BPP_TDTD, '') + '-' + ISNULL(U_BPP_TDDD, '') FROM [@BPP_TPODOC] WHERE ISNULL(U_BPP_TDTD, '')=ISNULL(T0.U_BPP_MDTD, ''))
						END
					),
					'Serie' = ISNULL(T0.[U_BPP_MDSD], ''),
					'Numero' = ISNULL(T0.[U_BPP_MDCD], ''),
					'Tipo Doc. Identidad' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN T0.[Indicator] = 'ZA' THEN ''
						ELSE T1.[U_BPP_BPTD]
						END
					),
					'RUC' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN T0.[Indicator] = 'ZA' THEN ''
						ELSE T1.[LicTradNum]

						END
					),
					'Razon Social' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 'Anulado' 
							WHEN T0.[Indicator] = 'ZA' THEN 'Anulado'
						ELSE
							CASE
								WHEN T1.[U_BPP_BPTP] = 'TPN' THEN ISNULL(T1.[U_BPP_BPAP], ' ')+' '+ ISNULL(T1.[U_BPP_BPAM], ' ')+' '+ ISNULL(T1.[U_BPP_BPNO], ' ') 
							ELSE T1.[CardName]
							END 
						END					
					),
					'Total Facturado' = 
					(
						CASE 
							WHEN (SELECT TOP 1 B.[DocSubType] FROM OINV B WHERE (B.[U_BPP_MDTD] = T0.[U_BPP_MDTO]) AND (B.[U_BPP_MDSD] = T0.[U_BPP_MDSO])  AND  (B.[U_BPP_MDCD] = T0.[U_BPP_MDCO])) = 'IX' THEN
								CASE
									WHEN T0."CANCELED" = 'Y' THEN 0
									WHEN T0.Indicator = 'ZA' THEN 0 
								ELSE 
								(
									-
									ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
									+
									(
										CASE WHEN (ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt] 
										ELSE 0
										END
									)
									+
									(
										CASE
											WHEN (ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
										ELSE 0
										END
									)
								)
								END			
						ELSE 0
						END
					),
					'Base Imponible' =
					(
						CASE 
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.[Indicator] = 'ZA' THEN 0 
						ELSE 
						-
						(
							--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							(
								ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
							)

							--/// STRAT: 13092012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								CASE
									WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt]
								ELSE 0 
								END
							)
				
							--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								CASE
									WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
								ELSE 0 
								END
							)
						)
						END				
					),
		
					'Exonerada' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.[Indicator] = 'ZA' THEN 0 
						ELSE 
							CASE
								WHEN (SELECT TOP 1 B.[DocSubType] FROM OINV B WHERE (B.[U_BPP_MDTD] = T0.[U_BPP_MDTO]) AND (B.[U_BPP_MDSD] = T0.[U_BPP_MDSO])  AND  (B.[U_BPP_MDCD] = T0.[U_BPP_MDCO])) != 'IX' THEN
									-
									--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
									
									ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM' THEN LineTotal/2 ELSE LineTotal END ) 
											FROM RIN1 WHERE DocEntry=T0.DocEntry AND "TaxCode" ='INM' OR "TaxCode" IN  (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01') ), 0)
									--// STRAT: 13092012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
									+
									(
										CASE WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM' THEN LineTotal/2 ELSE LineTotal END )
										FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0))>0
										THEN T0.DpmAmnt ELSE  0 END
									)
					
									--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
									+
									(
										CASE
											WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM' THEN LineTotal/2 ELSE LineTotal END )--SUM(LineTotal) 
											FROM RIN1 WHERE DocEntry=T0.DocEntry AND "TaxCode"='INM' OR TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
										ELSE 0
										END
									)
							ELSE
								ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN -(LineTotal/2) ELSE 0 END )
											FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode ='INM'),0)
							END 
						END
					),
					'Inafecta' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.[Indicator] = 'ZA' THEN 0 
						ELSE
						(
							--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
							)
				
							--/// STRAT: 13092012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							+
							(
								CASE
									WHEN (ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DpmAmnt]
								ELSE 0 
								END
							)
				
							--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							+
							(
								CASE
									WHEN (ISNULL((SELECT SUM(LineTotal) FROM RIN1 WHERE DocEntry=T0.DocEntry AND TaxCode in (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
								ELSE 0
								END
							)
						)
						END
					),
					'ISC'=
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.Indicator = 'ZA' THEN 0 
						ELSE 
						-
						(
							ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RIN4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
						)
						END
					),
					'IGV' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.[Indicator] = 'ZA' THEN 0
						ELSE
							- ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RIN4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
						END
					),
					'Otros'=
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.[Indicator] = 'ZA' THEN 0
						ELSE 
						-
						(
							T0.[VatSum]
							-
							(
								ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RIN4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
							)
							-
							(
								ISNULL((SELECT SUM(C.TaxSum ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN RIN4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
							)
							+
							T0.[RoundDif]
						)
						END
					),
		
					--/// STRAT Caso 3656  - Cambio en importe total: Se añadio la resta del gasto Adicional, debido a la funcionalidad de percepciones ABFrance
					--/// Fecha : 17/12/2014
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
		
					'Importe Total' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN T0.Indicator = 'ZA' THEN 0 
						ELSE 
						-
						(
							T0.[DocTotal] + (SELECT ISNULL(SUM(A.WtAmnt),0)- (case when t0.doccur='sol' then isnull(t0.totalexpns,0) else isnull(t0.totalexpSC,0) end ) FROM RIN5 A WHERE A.AbsEntry=T0.DocEntry AND (UPPER(A.Category) = 'I'))
						)
						END
					),
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
		
					'Tipo de Cambio' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN T0.[Indicator] = 'ZA' THEN '1.000'
						ELSE 
							CASE 
								WHEN UPPER(T0.[DocCur]) = 'SOL' THEN NULL	
							ELSE CAST(T0.[DocRate] AS DECIMAL(19, 3))
							END
						END
					),
					'Fecha Doc Original' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN T0.[Indicator] = 'ZA' THEN NULL
						ELSE 
							CASE
								WHEN 
								(
									ISNULL((SELECT TOP 1 B.DocDate FROM RIN1 A INNER JOIN OINV B ON A.BaseEntry=B.DocEntry  AND A.BaSEType=13 WHERE A.DocEntry=T0.DocEntry),'')='' AND
									ISNULL((SELECT TOP 1 B.DocDate FROM RIN1 A INNER JOIN [ODPI] B ON A.BaseEntry=B.DocEntry  AND A.BaSEType=203 WHERE A.DocEntry=T0.DocEntry),'')=''
								)
								THEN T0.[U_BPP_SDocDate]
								WHEN
								(
									ISNULL((SELECT TOP 1 B.DocDate FROM RIN1 A INNER JOIN [ODPI] B ON A.BaseEntry=B.DocEntry  AND A.BaSEType=203 WHERE A.DocEntry=T0.DocEntry),'')=''
								)
								THEN ISNULL((SELECT TOP 1 B.DocDate FROM RIN1 A INNER JOIN OINV B ON A.BaseEntry=B.DocEntry  AND A.BaSEType=13 WHERE A.DocEntry=T0.DocEntry),'')
							ELSE ISNULL((SELECT TOP 1 B.DocDate FROM RIN1 A INNER JOIN [ODPI] B ON A.BaseEntry=B.DocEntry  AND A.BaSEType=203 WHERE A.DocEntry=T0.DocEntry),'')
							END
						END
					),
					'Tipo Tabla 10' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN isnull(T0.Indicator,'') = 'ZA' THEN ''
							--when isnull(T0.Indicator,'') ='' then '0'
						ELSE
							case when ISNULL(T0.U_BPP_MDTO,'') !='' then ISNULL(T0.U_BPP_MDTO,'')
							else '0'
								end 
					 
						END
					),
					'Serie Doc Original' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN T0.[Indicator] = 'ZA' THEN '' 
						ELSE ISNULL(SUBSTRING(T0.U_BPP_MDSO, 1,CASE WHEN (CHARINDEX('-', T0.U_BPP_MDSO)-1)<0 THEN LEN(T0.U_BPP_MDSO)  ELSE CHARINDEX('-', T0.U_BPP_MDSO)-1 END ),'') 
						END
					),
					'Numero Doc Original' = 
					(
						CASE 
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN T0.[Indicator] = 'ZA' THEN '' 
						ELSE ISNULL(T0.[U_BPP_MDCO],'')
						END
					),
					'Operacion' = T0.[U_BPP_OPER],
					--'Valor FOB' = 0,
					'ObjectType' = CONVERT(NVARCHAR(15), T0.[ObjType]),
					'DocumentEntry' = CONVERT(NVARCHAR(15), T0.[DocEntry]),
					'DsctoBaseImponible' = T0.[DiscSum],
					'DsctoImpuestoGeneral' = 
						(CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
							ELSE 
							CASE WHEN GrosProfit = 0 THEN 0 
								ELSE ISNULL(((T0.GrosProfit + T0."DiscSum") * (VatSum/GrosProfit)) - VatSum,0) END
							END
						),
					'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
					'Contrato' = '',
					'TipoNota' = '',
					'InternoSunat1' = '',
					'Referencial' = '',
					'Tipo Operacion' = '',
					'Inconsistencias' = '',
					'InternoSunat2' = ''
				FROM [ORIN] T0
				INNER JOIN [OCRD] T1 ON T1.CardCode = T0.CardCode
				INNER JOIN [OJDT] T2 ON T2.TransId = T0.TransId
				WHERE 
					(ISNULL(T0.[CANCELED], '') != 'C')
				AND (ISNULL(T0.[U_BPP_MDTD], '') != '')
				AND (ISNULL(T0.[U_BPP_MDTD], '') NOT IN('','NC'))
				AND (ISNULL(T0.[U_BPP_MDSD], '') NOT IN('','999'))
				AND (T0.[U_BPP_MDTD] IN(SELECT T0.[U_BPP_TDTD] FROM [@BPP_TPODOC] T0 WHERE ISNULL(T0.[U_excluir], 'N') != 'Y'))
	
	
				UNION ALL
	
	
				--/// ODPI: ANTICIPO DE CLIENTES ============================================================================
				SELECT DISTINCT
					'Numero Correlativo' = T0.[TransId],
					--'Numero Correlativo Asiento Contable' = ('M' + CAST(T0.[TransId] AS VARCHAR(20))),
					'Numero Correlativo Asiento Contable' = (CASE	WHEN T1.U_STR_AR = 'Y' THEN 'RER-M' --Para Agentes de Retencion
																	WHEN T2.TransType = -2 THEN 'A' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
																	WHEN T2.TransType = -3 THEN 'C' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
																	ELSE 'M' + CAST(T0."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento
					'Fecha Documento' = T0.[DocDate],
					'Fecha' = T0.[TaxDate],
					'Fecha Emision' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS(SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL
						ELSE T0.[TaxDate]
						END
					),
					'Fecha Vencimiento' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL
						ELSE T0.[DocDueDate]
						END 
					),
					'Tipo' = (SELECT TOP 1 ISNULL([U_BPP_TDTD], '') + '-' + ISNULL([U_BPP_TDDD] , '') FROM [@BPP_TPODOC] WHERE ISNULL([U_BPP_TDTD], '')=ISNULL(T0.[U_BPP_MDTD], '')),
					'Serie' = ISNULL(T0.[U_BPP_MDSD], ''),
					'Numero' = ISNULL(T0.[U_BPP_MDCD], ''),
					'Tipo Doc. Identidad' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE T1.[U_BPP_BPTD]
						END
					),
					'RUC' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN ''
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN ''
						ELSE T1.[LicTradNum]
						END
					),
		
					--/// Modificacion de la razon social del socio del negocio . . . . . . . . . . . . 
					'Razon Social' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 'ANULADO'
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry = A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 'ANULADO'
						ELSE
							CASE
								WHEN T1.[U_BPP_BPTP] = 'TPN' THEN ISNULL(T1.[U_BPP_BPAP], ' ')+' '+ ISNULL(T1.[U_BPP_BPAM], ' ')+' '+ ISNULL(T1.[U_BPP_BPNO], ' ') 
							ELSE T1.[CardName]
							END 
						END					
					),
					'Total Facturado' = 0,
					'Base Imponible' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
						(/*
							--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
				
							--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								CASE
									WHEN (ISNULL((SELECT SUM( CASE WHEN "TaxCode"='INM'THEN LineTotal/2 ELSE LineTotal END ) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.DiscSum
								ELSE 0 
								END
							)*/
							
							SELECT  CASE WHEN "TaxCode"='INM' THEN
									(ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.DiscSum
									ELSE 0 
									END
								))/2 
								ELSE
								ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.DiscSum
									ELSE 0 
									END
								) 
								END
							FROM
							(SELECT "TaxCode"
							 FROM DPI1 WHERE DocEntry=T0.DocEntry group by "TaxCode")T
						)
						END
					),
					'Exonerada' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
						(
							--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
				
							--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								CASE
									WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
								ELSE 0 
								END
							)

							
						)
						END
					),
					'Inafecta' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
						(/*
							--/// 21082012 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
				
							--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
							-
							(
								CASE
									WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='C' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.[DiscSum]
								ELSE 0
								END
							)*/

							SELECT  CASE WHEN "TaxCode"='INM' THEN
									(ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='A' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.DiscSum
									ELSE 0 
									END
								))/2 
								ELSE
								ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)
								--/// STRAT: 15012013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
								-
								(
									CASE
										WHEN (ISNULL((SELECT SUM(LineTotal) FROM DPI1 WHERE DocEntry=T0.DocEntry AND TaxCode IN (SELECT U_STR_IMPUESTO FROM [@STR_CLMIMP] WHERE U_STR_COLUMNA='B' AND ISNULL(U_STR_FORMATO, '')='14.01')), 0)) > 0 THEN T0.DiscSum
									ELSE 0 
									END
								) 
								END
							FROM
							(SELECT "TaxCode"
							 FROM DPI1 WHERE DocEntry=T0.DocEntry group by "TaxCode")T
						)
						END
					),
					'ISC' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPI4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0) 
						END
					),
					'IGV' = 
					(
						CASE 
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE 
							ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPI4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
						END
					),
					'Otros' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE				
							(
									T0.[VatSum]
									-
									ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPI4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_IGV,'N')='Y' AND ISNULL(A.U_IGV,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
									-
									ISNULL((SELECT SUM(C.TaxSUM ) FROM OSTT A  INNER JOIN OSTA B ON A.AbsId = B.Type INNER JOIN DPI4 C ON B.Code = C.StaCode AND A.AbsId = C.staType WHERE ISNULL(B.U_ISC,'N')='Y' AND ISNULL(A.U_ISC,'N')='Y' AND C.DocEntry= T0.DocEntry ),0)
									+
									T0.[RoundDif]
							)
						END
					),
		
	
					--/// STRAT Caso 3656  - Cambio en importe total: Se añadio la resta del gasto Adicional, debido a la funcionalidad de percepciones ABFrance
					--/// Fecha : 17/12/2014
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					'Importe Total' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS (SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
						ELSE
							T0.[DocTotal] + 
						ISNULL((SELECT SUM(ISNULL(A.WtAmnt,0))- (case when t0.doccur='sol' then isnull(t0.totalexpns,0) else isnull(t0.totalexpSC,0) end )
							FROM DPI5 A WHERE A.AbsEntry=T0.DocEntry AND (UPPER(A.Category)='I')),0)
			
						END
					),
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					-----------------------------------------------------------------------------------------------------------------------------------------------------------
					'Tipo de Cambio' = 
					(
						CASE
							WHEN T0."CANCELED" = 'Y' THEN NULL
							WHEN EXISTS(SELECT TOP 1 'Z' FROM DPI1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN NULL

						ELSE
							CASE 
								WHEN UPPER(T0.DocCur) = 'SOL' THEN '1.000'
								ELSE CAST(T0.DocRate AS DECIMAL(19, 3))
							END
						END
					),
		
					'Fecha Doc Original' = NULL,
					'Tipo Tabla 10' = '',
					'Serie Doc Original' = '',
					'Numero Doc Original' = '',
					'Operacion' = T0.[U_BPP_OPER],
					--'Valor FOB' = 0,
					'ObjectType' = CONVERT(NVARCHAR(15), T0.[ObjType]),
					'DocumentEntry' = CONVERT(NVARCHAR(15), T0.[DocEntry]),
					'DsctoBaseImponible' = T0.[DiscSum],
					'DsctoImpuestoGeneral' = 
						(CASE
							WHEN T0."CANCELED" = 'Y' THEN 0
							WHEN EXISTS(SELECT TOP 1 'Z' FROM INV1 A0 WHERE A0.TargetType = 14 AND (SELECT TOP 1 U_BPP_MDSD FROM ORIN WHERE DocEntry=A0.TrgetEntry) = '999' AND A0.DocEntry=T0.DocEntry) THEN 0
							ELSE 
								CASE WHEN GrosProfit = 0 THEN 0 
								ELSE ISNULL(((T0.GrosProfit + T0."DiscSum") * (VatSum/GrosProfit)) - VatSum,0) END
							END
						),
					'Codigo Moneda' = (SELECT ISOCurrCod FROM OCRN WHERE CurrCode = T0.DocCur),
					'Contrato' = '',
					'TipoNota' = '',
					'InternoSunat1' = '',
					'Referencial' = '',
					'Tipo Operacion' = '',
					'Inconsistencias' = '',
					'InternoSunat2' = ''
				FROM [ODPI] T0
				INNER JOIN [OCRD] T1 ON T1.[CardCode] = T0.[CardCode]
				INNER JOIN [OJDT] T2 ON T2.TransId = T0.TransId
				WHERE
					(ISNULL(T0.[CANCELED], '') != 'C')
				AND (ISNULL(T0.[U_BPP_MDTD], '') != '')
				AND (ISNULL(T0.[U_BPP_MDTD], '') NOT IN ('','NC'))
				AND (ISNULL(T0.[U_BPP_MDSD], '') NOT IN('', '999'))
				AND (T0.[U_BPP_MDTD] IN(SELECT T0.[U_BPP_TDTD] FROM [@BPP_TPODOC] T0 WHERE ISNULL(T0.[U_excluir], 'N') != 'Y'))
			)R WHERE [Numero] NOT IN ('', '0')
		)TT
		WHERE 
		--	[Operacion] IN ('I','E','N') 
			--AND 
			ISNULL([Tipo],'') != '' 
		AND LEFT(ISNULL([Tipo],'09'),2) != ('09') 
		AND ([Fecha] BETWEEN @FI AND @FF)
	)TB
		UNION ALL 

		SELECT
			'Periodo RL' = (@ANIO + '' + @MES),
			'Periodo' = (CONVERT(varchar(20), YEAR(@FI))+ '' + @MES),
			'RUC Empresa' = (SELECT TOP 1 [TaxIdNum] FROM [OADM]),
			'Razon Social Empresa' = (SELECT TOP 1 [PrintHeadr] FROM [OADM]),
			'CAR' = '',
			'Numero correlativo'  ='1' + T1.U_BPP_NmCr,
			'Numero correlativo asiento' = 'M' + '1' + T1.U_BPP_NmCr,
			--'Numero correlativo asiento' = (CASE WHEN T1.WTLiable = 'Y' THEN 'RER-M' --Para Agentes de Retencion
			--															WHEN T2.TransType = -2 THEN 'A' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Apertura
			--															WHEN T2.TransType = -3 THEN 'C' + CAST(T0."TransId" AS VARCHAR(20)) --Para Asientos de Cierre
			--															ELSE 'M' + CAST(T0."TransId" AS VARCHAR(20)) END), --Para Asientos de Movimiento

			'Fecha Emision' = '01/01/0001',
			'Fecha Vencimiento' ='01/01/0001',
			'Tipo' = (SELECT TOP 1 ISNULL([U_BPP_TDTD], '') FROM [@BPP_TPODOC] WHERE ISNULL([U_BPP_TDTD], '')=ISNULL(T0.U_BPP_DocSnt, '')),
			'Serie' = '0' + RIGHT(ISNULL(T0.[U_BPP_Serie], ''),3),
			'Numero' = ISNULL(T1.U_BPP_NmCr, ''),
			'Campo 9'='',
			'Tipo Doc. Identidad' = '0',
			'RUC' = '-',
			'Anulado '/*+ISNULL(T0.U_BPP_Cmnt,'')*/ AS 'Razon Social',
			'Total Facturado' = 0,
			'Base imponible' = 0,
			'Exonerada' = 0,
			'Inafecta' = 0,
			'ISC' = 0,
			'IGV' = 0,
			'Campo 21' = '0.00',
			'Campo 22' = '0.00',
			'Otros' = 0,
			'Importe Total' = 0,
			'Tipo de cambio' = NULL,
			'Fecha doc original' = '',
			'Tipo tabla 10' = '',
			'Serie doc Original' = '',
			'Numero doc Original' = '',
			'Estado'='2',
			--'FOB'='0',
			'ObjectType' = '',
			'DocumentEntry' = '',
			'DsctoBaseImponible' = '0.00',
			'DsctoImpuestoGeneral' = '0.00',
			'Codigo Moneda' = 'PEN',
			'Contrato' = '',
			'TipoNota' = '',
			'InternoSunat1' = '',
			'Referencial' = '',
			'Tipo Operacion' = '',
			'Inconsistencias' = '',
			'InternoSunat2' = ''

		FROM [@BPP_ANULCORR] T0 
		INNER JOIN [@BPP_ANULCORRDET] T1 on T0.DocEntry=T1.DocEntry
		WHERE 
			((SELECT TOP 1 ISNULL([U_BPP_TDTD], '') FROM [@BPP_TPODOC] WHERE ISNULL([U_BPP_TDTD], '')=ISNULL(T0.U_BPP_DocSnt, '')) = '09')
		AND (T0.U_BPP_FchAnl BETWEEN @FI AND @FF)
		AND (@AN = 1)
		AND (ISNULL(T1.U_BPP_NmCr,'') != '')

		-- ====================================================================================================
		SELECT 
			   "RUC Empresa","Periodo RL"
			   ,"ObjectType","DocumentEntry",
			   "RUC Empresa"		                             			--1
			+'|'+ "Razon Social Empresa"									--2
			+'|'+ "Periodo RL"												--3
			+'|'+ "CAR"				                                		--4
			+'|'+ "Fecha Emision"											--5
			+'|'+ "Fecha Vencimiento"										--6
			+'|'+ "Tipo"													--7
	 		+'|'+ "Serie"													--8
	 		+'|'+ "Numero"													--9
            +'|'+ "Campo 9"													--10
			+'|'+ "Tipo Doc. Identidad"										--11
			+'|'+ "RUC"														--12
	 		+'|'+ "Razon Social"											--13
	 		+'|'+	CAST("Total Facturado" AS VARCHAR(14))					--14
	 		+'|'+	CAST("Base Imponible" AS VARCHAR(14))					--15
			+'|'+	CAST(CAST("DsctoBaseImponible" AS NUMERIC(17,2)) AS VARCHAR(14))--16
			+'|'+	CAST("IGV" AS VARCHAR(14))								--17
			+'|'+	CAST(CAST("DsctoImpuestoGeneral" AS NUMERIC(17,2))	AS VARCHAR(14))	--18
			+'|'+	CAST("Exonerada" AS VARCHAR(14))						--19
			+'|'+	CAST("Inafecta"	AS VARCHAR(14))							--20
			+'|'+	CAST("ISC"	AS VARCHAR(14))								--21
			+'|'+	"Campo 21"												--22
			+'|'+	"Campo 22"												--23
			+'|'+	'0.00'													--24	New Plastico
			+'|'+	CAST("Otros" AS VARCHAR(14))							--25
			+'|'+	CAST("Importe Total" AS VARCHAR(14))					--26
			+'|'+	CAST("Codigo Moneda"AS VARCHAR(5))						--27
			+'|'+	ISNULL(RTRIM("Tipo de cambio"),'')						--28
			+'|'+	"Fecha Doc Original"									--29
			+'|'+	"Tipo Tabla 10"											--30
			+'|'+	CAST("Serie Doc Original" AS VARCHAR(20))				--31
			+'|'+	CAST("Numero Doc Original" AS VARCHAR(20))				--32
			+'|'+	"Contrato"												--33
			+'|'+	"TipoNota"												--34
			+'|'+	ISNULL("Estado",'1')									--35
			+'|'+	"InternoSunat1"											--36
			+'|'+	"Referencial"											--37
			+'|'+	"Tipo Operacion"										--38
			+'|'+	"Inconsistencias"										--39
			+'|'+	"InternoSunat2"											--40
			+'|'
			AS "PLE" 
		FROM #Temp
	-- ====================================================================
END;