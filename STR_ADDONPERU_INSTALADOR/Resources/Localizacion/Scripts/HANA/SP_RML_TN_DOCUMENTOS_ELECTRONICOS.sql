CREATE PROCEDURE SP_RML_TN_DOCUMENTOS_ELECTRONICOS
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN num_of_cols_in_key int,
	IN list_of_key_cols_tab_del nvarchar(255),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)

AS
enabled int;

BEGIN

DECLARE MYCOND CONDITION;
DECLARE EXIT HANDLER FOR MYCOND BEGIN END;

enabled := 1;
error :=0;
error_message := N'Ok';

	--Exclusivo para Addon Facturacion electronica
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------

	
	-- Resultado
	SELECT :error, :error_message from dummy;

END;