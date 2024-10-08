CREATE FUNCTION RML_TN_CL_203_AnticipoVentas
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS

BEGIN
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN

	END IF;
END