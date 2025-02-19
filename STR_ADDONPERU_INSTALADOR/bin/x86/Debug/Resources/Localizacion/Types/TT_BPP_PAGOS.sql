CREATE TYPE "TT_BPP_PAGOS" AS TABLE ( "CodigoProveedor" NVARCHAR(50) CS_STRING,
	 "NombreProveedor" NVARCHAR(200) CS_STRING,
	 "NumeroSAP" INT CS_INT,
	 "Moneda" NVARCHAR(10) CS_STRING,
	 "FechaContabilizacion" TIMESTAMP,
	 "FechaDocumento" TIMESTAMP,
	 "FechaVencimiento"TIMESTAMP,
	 "NumeroDocumento" NVARCHAR(50) CS_STRING,
	 "ImporteDoc" DECIMAL(21,
	6) CS_FIXED,
	 "MontoPago" DECIMAL(23,6) CS_FIXED,
	 "Saldo" DECIMAL(23,6) CS_FIXED,
	 "TipoDocumento" NVARCHAR(50) CS_STRING,
	 "RUC" NVARCHAR(50) CS_STRING,
	 "NombreBanco" NVARCHAR(250) CS_STRING,
	 "CuentaBanco" NVARCHAR(50) CS_STRING,
	 "MonedaBanco" NVARCHAR(10) CS_STRING,
	 "ObjType" NVARCHAR(20) CS_STRING,
	 "NumeroCuota" INT CS_INT,
	 "NombreCuota" NVARCHAR(25) CS_STRING,
	 "ImporteRetencion" DECIMAL(21,
	6) CS_FIXED,
	 "DetraccionPago" NVARCHAR(50) CS_STRING ) 