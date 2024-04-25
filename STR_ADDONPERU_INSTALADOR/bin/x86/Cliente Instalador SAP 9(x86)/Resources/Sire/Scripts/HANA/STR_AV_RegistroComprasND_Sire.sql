CREATE PROCEDURE STR_AV_RegistroComprasND_Sire
(
	IN FI DATE,
	IN FF DATE
)
AS
BEGIN
	Temp=(SELECT DISTINCT
	 --"Periodo",
	 RTRIM(REPLACE("PeriodoLE",'-',''),0) AS "Periodo LE",
	 '' AS "CAR",
	 "RUCEmpresa" 				AS "RUC Empresa",
	 "RazonSocialEmpresa" 		AS "Razon Social Empresa",
	 "NumeroUnico" 				AS "Numero Unico",
	 "NumeroUnicoAsientoContable" AS "Numero Correlativo del Asiento Contable",
	 "NumeroCorrelativo" 		AS "Numero correlativo",
	 "FechaEmision" 			AS "Fecha Emision",
	-- "FechaVencimientoN" AS "Fecha Vencimiento",
	 "TipoN" 					AS "Tipo",
	 "CodigoAduanaN" 			AS "Codigo Aduana",
	 "SerieDUAN" 				AS "Serie DUA",
	 
	  case 
	 	when (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry") = '50'
	 	then to_varchar(year("FechaEmision")) 
	 	else --''
	 		"FechaDUAN" 				
	 end AS "Fecha DUA",
	 
	 "NumeroDUAN" 				AS "Numero DUA",
	 --"Campo10N" AS "Campo 10",
	 "TipoDocIdentidadN" 		AS "Tipo Doc. Identidad",
	 "RUCN" 					AS "RUC",
	 "RazonSocialN" 			AS "Razon Social",
	 "BaseImponibleA" 			AS "BASE IMPONIBLE A",
	 "IGVA" 					AS "IGV A",
	 "BaseImponibleB" 			AS "BASE IMPONIBLE B",
	 "IGVB" 					AS "IGV B",
	 "BaseImponibleC" 			AS "BASE IMPONIBLE C",
	 "IGVC" 					AS "IGV C",
	 "AdquisionesNoGravadas" 	AS "Adquisiones no gravadas",
	 "ISC",
	 "Otros" 					AS "Otros tributos",
	 "ImporteTotal" 			AS "Importe Total",
	 "TipoCambio" 				AS "Tipo de cambio",
	 
	 case 
	 	when (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry") = '50'
	 	then (select P1."U_BPP_MDFD" from OPCH P1 where P1."DocEntry" = "DocumentEntry")
	 	else 
	 		"FechaOrigenN" 			
	 end AS "Fecha Origen",
	
	 case 
	 	when (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry") = '50'
	 	then (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry")
	 	else 
	 		"TipoOrigenN" 				
	 end AS "Tipo Origen",
	
	 case 
	 	when (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry") = '50'
	 	then (select P1."U_STR_SerieDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry")
	 	else 
	 		"SerieOrigenN" 			
	 end AS "Serie Origen",
	  
	  case 
	 	when (select P1."U_STR_TipoDua" from OPCH P1 where P1."DocEntry" = "DocumentEntry") = '50'
	 	then (select P1."U_BPP_MDND" from OPCH P1 where P1."DocEntry" = "DocumentEntry")
	 	else 
	 		"NumeroCorrOrigenN" 		
	 end AS "Numero Corr. Origen",
	
	 
	 --"CodigoDependenciaAduaneraN" AS "Codigo de la Dependencia Aduanera",
	 "NumCompPagoNoDomiciliadoN" AS "Num.Comp.pago no domiciliado",
	 --"FechaDepositoN" AS "Fecha de deposito",
	 --"ConstanciaDepositoN" AS "Constancia de deposito",
	 "Retencion", 
	 
	 "ObjectType",
	 "DocumentEntry",
	 "CodigoMoneda" 			AS "Codigo Moneda",
	 --"ClasificacionBienes" AS "Clasificacion Bienes",
	 "PaisSujeto" 				AS "Pais_sujeto",
	 "RazonSocialSujeto"		AS "Razon_social_sujeto",
	 "NumIdentidadSujeto"		AS "Num_Iidentidad_Sujeto",
	 "DomicilioExtranjero"		AS "Dominicio_Extranjero",
	 "NumFiscalBeneficiario"	AS "Num_fiscal_Beneficiario",
	 "RazonSocialBeneficiario"	AS "Razon_Social_beneficiario",
	 "PaisBeneficiario"			AS "Pais_beneficiario",
	 "VinculoContribuyente"		AS "Vinculo_contribuyente",
	 "RentaBruta"				AS "Renta_Bruta",
	 "Deduccion",
	 "RentaNeta"				AS "Renta Neta",
	 "TazaRetencion"			AS "Taza Retencion",
	 "ImpuestoRetenido"			AS "Impuesto Retenido",
	 "ConvenioEvitar"			AS "Convenio_Evitar",
	 "ExoneracionAmplia"		AS "Exoneracion Amplia",
	 "TipoRenta"				AS "Tipo Renta",
	 "ModalidadServicio"		AS "Modalidad Servicio",
	 "Aplicacion76"				AS "Aplicaion 76",
	 '' AS "CAR CP",
	 "Estado",
	 "CampoLibre"				AS "Campo Libre"
	
	 
	FROM "_SYS_BIC"."STR_REP_COMPRAS/CPRAS_ND_LE"(PLACEHOLDER."$$FF$$"=> :FF,PLACEHOLDER."$$FI$$"=> :FI)
	ORDER BY "FechaEmision"ASC);
	SELECT "RUC Empresa",
		   "Periodo LE",
		   "ObjectType",
		   "DocumentEntry",
	       "Periodo LE"														--1
	       ||'|'||"CAR"                    --2
	       ||'|'||TO_VARCHAR("Fecha Emision",'DD/MM/YYYY')		--3
	       ||'|'||"Tipo"                                                        --4
	       ||'|'||"Serie DUA"                                                   --5
	       ||'|'||"Numero DUA"                                                  --6
	      -- ||'|'||"Numero Unico"  									--7
	      -- ||'|'||"Numero Correlativo del Asiento Contable" 		--8
	       ||'|'||"Adquisiones no gravadas" 						--7
	       ||'|'||"Otros tributos" 									--8
	       ||'|'||"Importe Total" 									--9
	       ||'|'||"Tipo Origen" 									--10
	       ||'|'||"Serie Origen"									--11
	       ||'|'||"Fecha DUA" 										--12
	       ||'|'||"Numero Corr. Origen" 							--13
	       ||'|'||IFNULL(CAST("Retencion" AS VARCHAR(3)), '') 		--14
	       ||'|'||"Codigo Moneda" 									--15
	       ||'|'||"Tipo de cambio" 									--16
	       ||'|'||IFNULL(CAST("Pais_sujeto" AS VARCHAR(4)), '') 	--17
	       ||'|'||"Razon_social_sujeto" 							--18
	       ||'|'||"Dominicio_Extranjero"							--19
	       ||'|'||"RUC" 											--20
	       ||'|'||"Num_fiscal_Beneficiario" 						--21
	       ||'|'||"Razon Social" 									--22
	       ||'|'||"Pais_beneficiario" 								--23
	       ||'|'||"Vinculo_contribuyente" 							--24
	       ||'|'||"Renta_Bruta" 									--25
	       ||'|'||"Deduccion" 										--26
	       ||'|'||"Renta Neta" 										--27
	       ||'|'||"Taza Retencion" 									--28
	       ||'|'||"Impuesto Retenido" 								--29
	       ||'|'||"Convenio_Evitar" 								--30
	       ||'|'||"Exoneracion Amplia" 								--31
	       ||'|'||"Tipo Renta" 										--32
	       ||'|'||"Modalidad Servicio" 								--33
	       ||'|'||"Aplicaion 76"                                    --34
	       ||'|'||"CAR CP" 									--35
		  -- ||'|'||"Estado"											--38
	      -- ||'|'||"Campo Libre"  									--39
		   ||'|'
	       AS "PLE" 
	FROM :Temp;-- 
	
	-- ===============================================================================================================================
	 --CALL STR_AV_Registro_ComprasND ('20201201','20201231');
END;