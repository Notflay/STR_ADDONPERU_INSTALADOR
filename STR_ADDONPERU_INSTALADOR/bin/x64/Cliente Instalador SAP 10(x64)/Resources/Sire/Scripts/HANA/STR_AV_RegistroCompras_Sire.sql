CREATE PROCEDURE STR_AV_RegistroCompras_Sire
(
	IN FI DATE,
	IN FF DATE
)
AS
BEGIN
	Temp=(SELECT DISTINCT
	 "Periodo",
	 "PeriodoLE" AS "Periodo LE",
	 "RUCEmpresa" AS "RUC Empresa",
	 "RazonSocialEmpresa" AS "Razon Social Empresa",
	 "NumeroUnico" AS "Numero Unico",
	 "NumeroUnicoAsientoContable" AS "Numero Correlativo del Asiento Contable",
	 "NumeroCorrelativo" AS "Numero correlativo",
	 "FechaEmision" AS "Fecha Emision",
	 "FechaVencimientoN" AS "Fecha Vencimiento",
	 "TipoN" AS "Tipo",
	 "CodigoAduanaN" AS "Codigo Aduana",
	 "SerieDUAN" AS "Serie DUA",
	 "FechaDUAN" AS "Fecha DUA",
	 "NumeroDUAN" AS "Numero DUA",
	 "Campo10N" AS "Campo 10",
	 "TipoDocIdentidadN" AS "Tipo Doc. Identidad",
	 "RUCN" AS "RUC",
	 "RazonSocialN" AS "Razon Social",
	  "BaseImponibleA" AS "BASE IMPONIBLE A",
	 "IGVA" AS "IGV A",
	 "BaseImponibleB" AS "BASE IMPONIBLE B",
	 "IGVB" AS "IGV B",
	 "BaseImponibleC" AS "BASE IMPONIBLE C",
	 "IGVC" AS "IGV C",
	 "AdquisionesNoGravadas" AS "Adquisiones no gravadas",
	 "ISC",
	 "Otros" AS "Otros tributos",
	 "ImporteTotal" AS "Importe Total",
	 "TipoCambio" AS "Tipo de cambio",
	 
	 "FechaOrigenN" AS "Fecha Origen",
	 "TipoOrigenN" AS "Tipo Origen",
	 "SerieOrigenN" AS "Serie Origen",
	 "CodigoDependenciaAduaneraN" AS "Codigo de la Dependencia Aduanera",
	 "NumeroCorrOrigenN" AS "Numero Corr. Origen",
	 "NumCompPagoNoDomiciliadoN" AS "Num.Comp.pago no domiciliado",
	 "FechaDepositoN" AS "Fecha de deposito",
	 CASE WHEN "ConstanciaDepositoN" = '0'
	  THEN '' ELSE "ConstanciaDepositoN" END
	  AS "Constancia de deposito",
	 "Retencion", 
	 "Estado",
	 "ObjectType",
	 "DocumentEntry",
	 "CodigoMoneda" AS "Codigo Moneda",
	 "ClasificacionBienes" AS "Clasificacion Bienes",
	 "Contrato",
	 "ErrTpo1",
	 "ErrTpo2",
	 "ErrTpo3",
	 "ErrTpo4",
	 "IndicadorComprobante" AS "Indicador Comprobante"
	
	 
	FROM "_SYS_BIC"."STR_REP_COMPRAS/CPRAS_DOM_LE"(PLACEHOLDER."$$FF$$"=> :FF,PLACEHOLDER."$$FI$$"=> :FI)
	
	ORDER BY "FechaEmision"ASC);
	SELECT 
		   "RUC Empresa",
		   "Periodo",
		   "ObjectType",
		   "DocumentEntry",
		   "RUC Empresa"									--1
		   ||'|'||"Razon Social Empresa"					--2
		   ||'|'||LEFT("Periodo LE",'6')					--3
		   ||'|'||''										--4
		   ||'|'||TO_VARCHAR("Fecha Emision",'DD/MM/YYYY') 	--5
		   ||'|'|| CASE WHEN "Tipo" = '14' AND "Estado" != '2' THEN "Fecha Vencimiento" ELSE '' END	--7			
		   ||'|'||LEFT("Tipo",2) 								--8
		   ||'|'||"Serie DUA" 									--9
		   ||'|'||"Fecha DUA" 									--10
		   ||'|'||"Numero DUA" 									--11
		   ||'|'||"Campo 10" 									--12
		   ||'|'||"Tipo Doc. Identidad" 						--13
		   ||'|'||"RUC" 										--14
		   ||'|'||"Razon Social" 								--15
		   ||'|'||"BASE IMPONIBLE A" 							--16
		   ||'|'||"IGV A" 										--17
		   ||'|'||"BASE IMPONIBLE B" 							--18
		   ||'|'||"IGV B" 										--19
		   ||'|'||"BASE IMPONIBLE C" 							--20
		   ||'|'||"IGV C" 										--21
		   ||'|'||"Adquisiones no gravadas" 					--22
		   ||'|'||"ISC"  										--23
           ||'|'||'0.00'  										--24 ---new
		   ||'|'||"Otros tributos" 								--25
		   ||'|'||"Importe Total" 								--26
		   ||'|'||"Codigo Moneda" 								--27
		   ||'|'||"Tipo de cambio" 								--28
		   ||'|'||"Fecha Origen" 								--29
		   ||'|'||"Tipo Origen" 								--30
		   ||'|'||CASE WHEN "Serie Origen" = '-' THEN '' ELSE "Serie Origen" END								--31
		   ||'|'||"Codigo de la Dependencia Aduanera" 			--32
		   ||'|'||CASE WHEN "Numero Corr. Origen" = '-' THEN '' ELSE	"Numero Corr. Origen" END			--33
		   ||'|'||"Fecha de deposito" 							--34
		   ||'|'||"Constancia de deposito" 						--35
		   ||'|'||IFNULL(CAST("Retencion" AS VARCHAR(3)), '') 	--36
		   ||'|'||IFNULL(CAST("Clasificacion Bienes" AS VARCHAR(3)), '') --37
		   ||'|'||"Contrato" 									--38
		   ||'|'||"ErrTpo1" 									--39
		   ||'|'||"ErrTpo2" 									--40
		   ||'|'||"ErrTpo3" 									--41
		   ||'|'||"ErrTpo4" 									--42
		   ||'|'||"Indicador Comprobante" 						--43
		   ||'|'||"Estado" 										--44
		   ||'|'
		   AS "PLE" 
	FROM :Temp;
	
	-- ===============================================================================================================================
	--CALL STR_AV_Registro_Compras ('20181101','20181103');
END;