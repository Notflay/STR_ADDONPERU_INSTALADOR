CREATE PROCEDURE STR_SP_Valida_FactElect
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)

AS

BEGIN

	DECLARE MYCOND CONDITION;
	DECLARE EXIT HANDLER FOR MYCOND BEGIN END;
	

END;








