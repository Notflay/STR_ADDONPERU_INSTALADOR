CREATE FUNCTION RML_TN_CL_204_AnticipoProveedor
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
	
	
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN
             
	END IF;
END