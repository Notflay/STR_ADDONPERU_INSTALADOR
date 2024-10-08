CREATE PROCEDURE SP_RML_PT_APP_PMD
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)
--RETURNS VARCHAR(200)
AS
BEGIN
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
/*VALIDACION DE PAGO MASIVOS DETRACCIONES*/

	IF :object_type = 'BPP_PAYDTR' THEN
		CALL RML_PT_APP_PMD_001_UDO(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
END;