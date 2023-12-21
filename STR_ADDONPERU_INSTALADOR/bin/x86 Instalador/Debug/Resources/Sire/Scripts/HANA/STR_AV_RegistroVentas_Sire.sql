CREATE PROCEDURE STR_AV_RegistroVentas_Sire
(
	IN FI DATE,
	IN FF DATE
)
AS
BEGIN

Temp=(
	SELECT
	DISTINCT
	 "PeriodoRL" AS "Periodo RL",
	 "PeriodoN" AS "Periodo",
	 "RUCEmpresa" AS "RUC Empresa",
	 "RazonSocialEmpresa" AS "Razon Social Empresa",
	 "NumeroCorrelativoN" AS "Numero Correlativo",
	 "NumCorrAsientoN" AS "Numero Correlativo Asiento Contable",
	 "FechaEmisionLE" AS "Fecha Emision",
	 "FechaVencimientoLE" AS "Fecha Vencimiento",
	 "TipoN" AS "Tipo",
	 "SerieN" AS "Serie",
	 "NumeroN" AS "Numero",
	 "Campo9" AS "Campo 9",
	 "TipoDocIdentidadN" AS "Tipo Doc. Identidad",
	 "RUCN" AS "RUC",
	 "RazonSocialN" AS "Razon Social",
	 "TotalFacturadoN" AS "Total Facturado",
	 "BaseImponible" AS "Base Imponible",
	 "Exonerada",
	 "Inafecta",
	 "ISC",
	 "IGV",
	 
	 "Campo20" AS "Campo 21",
	 "Campo21" AS "Campo 22",
	 "Otros",
	 "ImporteTotal" AS "Importe Total",
	 "TipoCambioN" AS "Tipo de Cambio",
	 
	 "FechaDocOriginalN" AS "Fecha Doc Original",
	 "TipoTabla10N" AS "Tipo Tabla 10",
	 IFNULL("SerieDocOriginalN",'0000') AS "Serie Doc Original",
	 COALESCE("NumeroDocOriginalN",'') AS "Numero Doc Original",
	 "Estado",
	 "ObjectType",
	 "DocumentEntry",
	 "DsctoBaseImponible",
	 "DsctoImpuestoGeneral", 
	 
	 "CodigoMoneda" AS "Codigo Moneda",
	 "Contrato",
	 "ErrTpo1",
	 "IndicadorComprobante" AS "Indicador Comprobante"
	FROM "_SYS_BIC"."STR_REP_VENTAS/VTAS_LE"(PLACEHOLDER."$$FF$$"=> :FF,PLACEHOLDER."$$FI$$"=> :FI)	
	ORDER BY "Serie","Numero", "FechaEmisionLE" ASC);
	
	SELECT "RUC Empresa","Periodo",
		"ObjectType",
	 	"DocumentEntry",
		"RUC Empresa"									--1
		||'|'||"Razon Social Empresa"					--2
		||'|'||"Periodo RL"								--3
		||'|'||''										--4
		||'|'||							
CASE 
	 WHEN IFNULL("Fecha Emision",'') = ''  THEN  CONCAT('01/'||RIGHT("Periodo RL",'2')||'/',LEFT("Periodo RL",'4'))  --'01/01/0001'
	 ELSE "Fecha Emision" END										--5
		
		||'|'|| CASE WHEN "Tipo" = '14' AND "Estado" != '2' THEN "Fecha Vencimiento" ELSE '' END	--6					--5
		||'|'|| "Tipo"									--7
	 	||'|'|| "Serie"									--8
	 	||'|'|| "Numero"								--9
	 	||'|'|| "Campo 9"								--10
		||'|'|| "Tipo Doc. Identidad"					--11
		||'|'|| "RUC"									--12
	 	||'|'|| "Razon Social"							--13
	 	||'|'|| "Total Facturado"						--14
	 	||'|'|| "Base Imponible"						--15
		||'|'|| "DsctoBaseImponible"					--16
		||'|'||	"IGV"									--17
		||'|'||	"DsctoImpuestoGeneral"					--18
		||'|'||	"Exonerada"								--19
		||'|'||	"Inafecta"								--20
		||'|'||	"ISC"									--21
		||'|'||	CASE WHEN IFNULL("Campo 21",'')	= '' THEN '0.00' ELSE "Campo 21" END	--22
		||'|'||	CASE WHEN IFNULL("Campo 22",'')	= '' THEN '0.00' ELSE "Campo 22" END	--23							--23
		||'|'||	'0.00'									--24	New Plastico
		||'|'||	"Otros"									--25
		||'|'||	"Importe Total"							--26
		||'|'||	"Codigo Moneda"							--27
		||'|'||	CASE WHEN "Codigo Moneda" <> 'PEN' THEN "Tipo de Cambio" ELSE	''	END --28
		||'|'||	"Fecha Doc Original"					--29
		||'|'||	"Tipo Tabla 10"							--30
		||'|'||	"Serie Doc Original"					--31
		||'|'||	"Numero Doc Original"					--32
		||'|'||	"Contrato"								--33
		
		/*
		||'|'||	"ErrTpo1"								--34
		||'|'||	"Indicador Comprobante"					--35
		||'|'||	"Estado"								--36*/
		||'|'
		AS "PLE" 
	FROM :Temp;
	-- ===============================================================================================================================
	-- CALL STR_AV_RegistroVentas_LE ('20201201','20201215');
END;