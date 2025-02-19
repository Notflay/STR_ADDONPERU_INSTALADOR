CREATE FUNCTION RML_TN_LC_1_PlanDeCuentas
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R1 INT;
    DECLARE @DOCTYPE NCHAR(1);
    DECLARE @R4 INT;
	DECLARE @clsBlncCom NVARCHAR(3);
	DECLARE @clsFinanciera NVARCHAR(3);
	DECLARE @clsBlncGen NVARCHAR(3);

    SET @error_message = '';

    IF @transaction_type IN ('A','U') BEGIN
		
		SELECT @clsBlncCom = "U_BPP_CBALC", @clsFinanciera = "U_BPP_CLASCTAFIN", @clsBlncGen = "U_BPP_CTABALANCE"
		FROM OACT WHERE "AcctCode" = @id;
		
		IF ISNULL(@clsBlncCom,'') = '' BEGIN
			SET @error_message = 'Es obligatorio definir la Clasificación de Balance de Compras'; 
		END 
		
		IF ISNULL(@clsFinanciera,'') = '' BEGIN
			SET @error_message = 'Es obligatorio definir la Clasificación de Balance Financiera';
		END 
		
		IF ISNULL(@clsBlncGen,'') = '' BEGIN
			SET @error_message = 'Es obligatorio definir la Clasificación de Balance General';
		END 
	END 

    RETURN @error_message;
END

