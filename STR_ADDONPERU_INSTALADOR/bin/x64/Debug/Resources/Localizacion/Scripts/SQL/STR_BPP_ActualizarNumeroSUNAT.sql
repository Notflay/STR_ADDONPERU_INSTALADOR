CREATE PROCEDURE STR_BPP_ActualizarNumeroSUNAT
(
	@NUMPAGO NVARCHAR(20),
	@NUMSAP NVARCHAR(20),
	@FECHAEJE NVARCHAR(20),
	@OPERACION INT
)
AS 
BEGIN
	-- 0: Pago Detraccion
	-- 1: Pago Proveedor
	IF (@OPERACION = '0') 
	BEGIN
		UPDATE OPCH SET "U_BPP_DPNM" =  @NUMPAGO,"U_BPP_DPFC" =  @FECHAEJE WHERE "DocEntry" = @NUMSAP;
	END;
	IF (@OPERACION = '1') 
	BEGIN
		-- Se migrará al campo "U_STR_NUMPAGO" a actualizar para pago de proveedor
		UPDATE OPCH SET "U_BPP_DPNM" =  @NUMPAGO  WHERE "DocEntry" = @NUMSAP;
	END;
END;