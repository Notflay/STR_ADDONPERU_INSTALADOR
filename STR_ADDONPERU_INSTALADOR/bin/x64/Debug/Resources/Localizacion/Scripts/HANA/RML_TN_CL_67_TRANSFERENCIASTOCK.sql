CREATE FUNCTION RML_TN_CL_67_TRANSFERENCIASTOCK
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS

BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type IN ('A','U') THEN

	END IF;
END