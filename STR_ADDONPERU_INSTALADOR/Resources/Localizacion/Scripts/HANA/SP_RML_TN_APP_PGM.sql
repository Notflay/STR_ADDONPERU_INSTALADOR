CREATE PROCEDURE SP_RML_TN_APP_PGM
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
-- * * * * * * * * * * * * * * * * * * * * * * * * * * Pago Masivo de Proveedores * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	IF :object_type = 'BPP_PAGM' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_APP_PGM_001_UDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
select :error, :error_message FROM DUMMY;
END;