CREATE PROCEDURE SP_RML_TN_CLIENTE
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

	/*============================================== OBJETOS ======================================================*/

	-->Plan de Cuentas
	IF @Object_Type = '1' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_1_PlanDeCuentas](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END

	-->Socio de negocio
	IF @Object_Type = '2' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_2_SociosNegocio](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 2
			GOTO Salir
		END
	END

	-->Maestro de Articulos
	IF @Object_Type = '4' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_4_MaestroArticulos](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 4
			GOTO Salir
		END
	END

	-->Oferta de Ventas
	IF @Object_Type = '23' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_23_OfertaVentas](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 23
			GOTO Salir
		END
	END

	-->Pago Recibido
	IF @Object_Type = '24' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_24_PAGORECIBIDO](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 24
			GOTO Salir
		END
	END

	-->Pedido de Cliente
	IF @Object_Type = '17' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_17_PedidoCliente](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 17
			GOTO Salir
		END
	END

	-->Entrega
	IF @Object_Type = '15' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_15_Entrega](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 15
			GOTO Salir
		END
	END

	-->Factura de Deudores
	IF @Object_Type = '13' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_13_FacturaDeudores](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 13
			GOTO Salir
		END
	END

	-->Devoluciones
	IF @Object_Type = '16' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_16_Devoluciones](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 16
			GOTO Salir
		END
	END

	-->Nota de Credito Clientes
	IF @Object_Type = '14' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_14_NotaCreditoCliente](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 14
			GOTO Salir
		END
	END

	-->Pedido
	IF @Object_Type = '22' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_22_Pedido](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 22
			GOTO Salir
		END
	END

	-->Entrada Mercancia
	IF @Object_Type = '20' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_20_EntradaMercancia](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 20
			GOTO Salir
		END
	END

	-->Factura de Proveedor
	IF @Object_Type = '18' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_18_FacturaProveedor](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 18
			GOTO Salir
		END
	END

	-->Notade Credito Proveedor
	IF @Object_Type = '19' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_19_NotaCreditoProveedor](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 19
			GOTO Salir
		END
	END

	-->Pago Efectuado
	IF @Object_Type = '46' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_46_PAGOEFECTUADO](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 46
			GOTO Salir
		END
	END

	-->Entrada de Mercancia
	IF @Object_Type = '59' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_59_ENTRADAMERCANCIA](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 59
			GOTO Salir
		END
	END

	-->Salida de Mercancia
	IF @Object_Type = '60' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_60_SALIDAMERCANCIA](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 60
			GOTO Salir
		END
	END

	-->Transferencias de Stock
	IF @Object_Type = '67' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_67_TRANSFERENCIASTOCK](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 67
			GOTO Salir
		END
	END

	-->Anticipo Ventas
	IF @Object_Type = '203' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_203_ANTICIPOVENTAS](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 203
			GOTO Salir
		END
	END

	-->Anticipo Proveedor
	IF @Object_Type = '204' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_CL_204_AnticipoProveedor](@list_of_cols_val_tab_del, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 204
			GOTO Salir
		END
	END

	Salir:

END