CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_PROVEEDORES
    @FECHAINI DATE,
    @FECHAFIN DATE,
    @CODPROVEEDOR NVARCHAR(20),
    @MONEDA NVARCHAR(20),
    @FECHAVINI DATE,
    @FECHAVFIN DATE,
    @PARAM1 NVARCHAR(20),
    @PARAM2 NVARCHAR(100)
AS
BEGIN
    DECLARE @TABLEPAGOS AS TABLE (
        CodigoProveedor NVARCHAR(50),
        NombreProveedor NVARCHAR(100),
        NumeroSAP INT,
        Moneda NVARCHAR(20),
        FechaContabilizacion DATE,
        FechaDocumento DATE,
        FechaVencimiento DATE,
        NumeroDocumento NVARCHAR(50),
        ImporteDoc DECIMAL(18, 2),
        MontoPago DECIMAL(29,6),
        Saldo DECIMAL(29,6),
        TipoDocumento NVARCHAR(50),
        RUC NVARCHAR(20),
        NombreBanco NVARCHAR(100),
        CuentaBanco NVARCHAR(50),
        MonedaBanco NVARCHAR(10),
        ObjType NVARCHAR(10),
        NumeroCuota INT,
        NombreCuota NVARCHAR(100),
        ImporteRetencion DECIMAL(18, 2),
        DetraccionPago NVARCHAR(50)
    );
    
    INSERT INTO @TABLEPAGOS 
    EXEC [dbo].[SP_BPP_BASE_CONSULTAR_PGM_PROVEEDORES] @FECHAINI, @FECHAFIN, @CODPROVEEDOR, @MONEDA, @FECHAVINI, @FECHAVFIN;

    SELECT 
        CodigoProveedor,
        NombreProveedor,
        NumeroSAP,
        Moneda,
        FechaContabilizacion,
        FechaDocumento,
        FechaVencimiento,
        NumeroDocumento,
        ImporteDoc,
        MontoPago,
        Saldo,
        TipoDocumento,
        RUC,
        NombreBanco,
        CuentaBanco,
        MonedaBanco,
        T1.ObjType,
        NumeroCuota,
        NombreCuota,
        ImporteRetencion,
        DetraccionPago
    FROM @TABLEPAGOS T1
    LEFT JOIN OCRD T2 ON T1.CodigoProveedor = T2.CardCode
    WHERE 
        CASE 
            WHEN ISNULL(@PARAM1,'') = '000' THEN '1'
            WHEN ISNULL(@PARAM1,'') = '001' THEN T2.GroupCode 
            WHEN ISNULL(@PARAM1,'') = '' THEN '1' 
			WHEN ISNULL(@PARAM1,'') = '-' THEN '1'  
        END 
        = 
        CASE 
            WHEN ISNULL(@PARAM1,'') = '000' THEN  '1'
            WHEN ISNULL(@PARAM1,'') = '001' THEN @PARAM2
            WHEN ISNULL(@PARAM1,'') = '' THEN '1' 
			WHEN ISNULL(@PARAM1,'') = '-' THEN '1' 
        END;

END