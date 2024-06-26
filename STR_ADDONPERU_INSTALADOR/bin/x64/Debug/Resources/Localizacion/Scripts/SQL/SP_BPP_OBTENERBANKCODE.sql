CREATE PROCEDURE SP_BPP_OBTENERBANKCODE
(
	@bank VARCHAR(5)
)
AS
BEGIN	
	SELECT "BankCode" "BankCode" FROM DSC1 WHERE "BankCode" = @bank AND  "U_BPP_GENTXT" = 'Y';
	/*	SELECT CASE WHEN "BankCode" = '003' THEN '001' END  "BankCode" FROM DSC1 WHERE "BankCode" = :bank AND  "U_BPP_GENTXT" = 'Y'; */
	/* Siempre debe retornar BANKCODE*/
END;