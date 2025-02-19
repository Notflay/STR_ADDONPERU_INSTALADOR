CREATE PROCEDURE SP_RML_TN_DOCUMENTOS_ELECTRONICOS
( 
	@object_type nvarchar(20), --> SBO Object Type
	@transaction_type nchar(1), --> [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	@num_of_cols_in_key int,
	@list_of_key_cols_tab_del nvarchar(255),
	@list_of_cols_val_tab_del nvarchar(255),
	@error int out,
	@error_message nvarchar(200) out
	)

AS
BEGIN

	--> Valores de retorno
	DECLARE @enabled bit --> Activa o desactiva las validaciones. Valores: 1-Activa, 0-Desactiva
	
	SELECT @error = 0
	SELECT @error_Message = N''
	SELECT @enabled = 1


	Salir:

END