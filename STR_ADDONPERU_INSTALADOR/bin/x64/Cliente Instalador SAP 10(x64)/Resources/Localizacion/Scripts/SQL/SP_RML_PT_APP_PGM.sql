CREATE PROCEDURE SP_RML_PT_APP_PGM
( 
	@object_type nvarchar(20), --> SBO Object Type
	@transaction_type nchar(1), --> [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	@list_of_cols_val_tab_del nvarchar(255),
	@error int out,
	@error_message nvarchar(200) out
	)
AS
BEGIN
	--> Valores de retorno


	Salir:
END
