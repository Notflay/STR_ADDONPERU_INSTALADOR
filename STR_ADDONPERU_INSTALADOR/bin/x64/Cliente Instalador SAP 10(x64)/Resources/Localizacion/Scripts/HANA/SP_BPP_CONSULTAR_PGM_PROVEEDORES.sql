CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_PROVEEDORES
(
FECHAINI DATE,
FECHAFIN DATE,
CODPROVEEDOR NVARCHAR(20),
MONEDA NVARCHAR(20),
FECHAVINI DATE,
FECHAVFIN DATE,
PARAM1 NVARCHAR(20),
PARAM2 NVARCHAR(100)
)
AS
BEGIN
	
CALL SP_BPP_BASE_CONSULTAR_PGM_PROVEEDORES(FECHAINI,FECHAFIN,CODPROVEEDOR,MONEDA,FECHAVINI,FECHAVFIN,TABLA);

SELECT 
"CodigoProveedor"
,"NombreProveedor"
,"NumeroSAP"
,"Moneda"
,"FechaContabilizacion"
,"FechaDocumento"
,"FechaVencimiento"
,"NumeroDocumento"
,"ImporteDoc"
,"MontoPago"
,"Saldo"
,"TipoDocumento"
,"RUC"
,"NombreBanco"
,"CuentaBanco"
,"MonedaBanco"
,T1."ObjType"
,"NumeroCuota"
,"NombreCuota"
,"ImporteRetencion"
,"DetraccionPago"
FROM :TABLA T1
LEFT JOIN OCRD T2 ON T1."CodigoProveedor" = T2."CardCode"
WHERE 
CASE 
WHEN IFNULL(PARAM1,'') = '000' THEN '1'
WHEN IFNULL(PARAM1,'') = '001' THEN T2."GroupCode" 
WHEN IFNULL(PARAM1,'') = '' THEN '1' END 
= CASE 
WHEN IFNULL(PARAM1,'') = '000' THEN  '1'
WHEN IFNULL(PARAM1,'') = '001' THEN PARAM2
WHEN IFNULL(PARAM1,'') = '' THEN '1' END ;

END;