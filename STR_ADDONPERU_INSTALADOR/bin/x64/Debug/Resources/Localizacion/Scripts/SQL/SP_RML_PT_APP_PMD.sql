CREATE PROCEDURE SP_RML_PT_APP_PMD
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
	DECLARE @enabled bit --> Activa o desactiva las validaciones. Valores: 1-Activa, 0-Desactiva
	
	SELECT @error = 0
	SELECT @error_Message = N''
	SELECT @enabled = 1

	IF @Object_Type = 'BPP_PAYDTR' AND @enabled = 1
	BEGIN
		EXEC [dbo].[RML_PT_APP_PMD_001_UDO] @list_of_cols_val_tab_del, @transaction_type
	END

	Salir:
END
