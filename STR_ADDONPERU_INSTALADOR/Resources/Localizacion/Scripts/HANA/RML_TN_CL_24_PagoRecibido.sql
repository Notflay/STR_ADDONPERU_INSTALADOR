CREATE FUNCTION RML_TN_CL_24_PagoRecibido
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS

BEGIN
	IF :transaction_type IN ('A','U') THEN

	 END IF;
END