CREATE FUNCTION RML_TN_APP_PGM_001_UDO
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
	
	IF :transaction_type IN ('A') THEN
		declare rsl2 int;
		SELECT COUNT(*) INTO rsl2 FROM "@BPP_PAGM_DET1" WHERE "DocEntry" = :id AND IFNULL("U_BPP_CODPROV",'')='';
		IF :rsl2 > 0
		THEN 
			error_message :='Se tiene que agregar minimo 1 proveedor para continuar con el proceso';
		END IF;
	END IF;
END