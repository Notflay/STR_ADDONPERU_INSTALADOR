CREATE PROCEDURE SP_RML_PT_APP_CC_ER
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
	/*VALIDACION DE CAJA CHICA*/
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	/*SOLICITUD DE DINERO*/
	IF :object_type = '171'  THEN
		CALL RML_PT_APP_CC_ER_171_EMPLEADO(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

select :error, :error_message FROM DUMMY;
END;