CREATE PROCEDURE STR_SP_LT_CargarCuentas()
AS
BEGIN
	select *, (select tx."FormatCode" from OACT tx where tx."AcctCode" = "U_cuenta") AS "FormatCode" from "@ST_LT_CONF";
END;







