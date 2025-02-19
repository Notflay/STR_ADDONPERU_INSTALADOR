CREATE PROCEDURE SP_RML_TN_APP_PGM
( 
	@object_type nvarchar(20), --> SBO Object Type
	@transaction_type nchar(1), --> [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	@num_of_cols_in_key int,
	@list_of_key_cols_tab_del nvarchar(255),
	@id nvarchar(255),
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
							 
	/*============================================== OBJETOS ======================================================*/

	-->Plan de Cuentas
	IF @Object_Type = 'BPP_PAGM' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_PGM_001_UDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END

	Salir:
END