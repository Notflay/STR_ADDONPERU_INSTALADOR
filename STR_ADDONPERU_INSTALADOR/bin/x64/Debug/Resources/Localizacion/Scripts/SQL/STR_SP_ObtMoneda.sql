CREATE PROCEDURE STR_SP_ObtMoneda
(
	 @CardCode VARCHAR(30)
)
AS
BEGIN
SELECT "Currency" FROM "OCRD" WHERE "CardCode" = @CardCode;
END;
