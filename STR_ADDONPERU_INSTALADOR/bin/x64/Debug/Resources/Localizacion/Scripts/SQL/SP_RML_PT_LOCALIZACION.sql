CREATE PROCEDURE SP_RML_PT_LOCALIZACION
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


	-->Plan de Cuentas
	IF @object_type = '1'  BEGIN
		EXEC RML_PT_LC_1_PlanDeCuentas @list_of_cols_val_tab_del, @transaction_type ;
	END
	
	-->Socio de negocio
	IF @object_type = '2'  BEGIN
		EXEC RML_PT_LC_2_SociosNegocio @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Maestro de Articulos
	IF @object_type = '4'  BEGIN
		EXEC RML_PT_LC_4_MaestroArticulos @list_of_cols_val_tab_del, @transaction_type ;
	END
			
	-->Factura de Deudores
	IF @object_type = '13'  BEGIN
		EXEC RML_PT_LC_13_FacturaDeudores @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Nota de Credito Clientes
	IF @object_type = '14'  BEGIN
		EXEC RML_PT_LC_14_NotaCreditoCliente @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Entrega
	IF @object_type = '15'  BEGIN
		EXEC RML_PT_LC_15_Entrega @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Devoluciones
	IF @object_type = '16'  BEGIN
		EXEC RML_PT_LC_16_Devoluciones @list_of_cols_val_tab_del, @transaction_type ;
	END
	
	-->Pedido de Cliente
	IF @object_type = '17'  BEGIN
		EXEC RML_PT_LC_17_PedidoCliente @list_of_cols_val_tab_del, @transaction_type ;	
	END

	-->Factura de Proveedor
	IF @object_type = '18'  BEGIN
		EXEC RML_PT_LC_18_FacturaProveedor @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Notade Credito Proveedor
	IF @object_type = '19'  BEGIN
		EXEC RML_PT_LC_19_NotaCreditoProveedor @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Entrada Mercancia
	IF @object_type = '20'  BEGIN
		EXEC RML_PT_LC_20_EntradaMercancia @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Pedido
	IF @object_type = '22'  BEGIN
		EXEC RML_PT_LC_22_Pedido @list_of_cols_val_tab_del, @transaction_type ;
	END
	
	-->Oferta de Ventas
	IF @object_type = '23'  BEGIN
		EXEC RML_PT_LC_23_OfertaVentas @list_of_cols_val_tab_del, @transaction_type ;	
	END

	-->Pago Recibido
	IF @object_type = '24'  BEGIN
		EXEC RML_PT_LC_24_PAGORECIBIDO @list_of_cols_val_tab_del, @transaction_type ;	
	END

	-->Pago Efectuado
	IF @object_type = '46'  BEGIN
		EXEC RML_PT_LC_46_PAGOEFECTUADO @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Entrada de Mercancia
	IF @object_type = '59'  BEGIN
		EXEC RML_PT_LC_59_ENTRADAMERCANCIA @list_of_cols_val_tab_del, @transaction_type ;
	END
	
	-->Salida de Mercancia
	IF @object_type = '60'  BEGIN
		EXEC RML_PT_LC_60_SALIDAMERCANCIA @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Transferencias de Stock
	IF @object_type = '67'  BEGIN
		EXEC RML_PT_LC_67_TRANSFERENCIASTOCK @list_of_cols_val_tab_del, @transaction_type ;
	END
	
	-->Anticipo Ventas
	IF @object_type = '203'  BEGIN
		EXEC RML_PT_LC_203_ANTICIPOVENTAS @list_of_cols_val_tab_del, @transaction_type ;
	END

	-->Anticipo Proveedor
	IF @object_type = '204'  BEGIN
		EXEC RML_PT_LC_204_AnticipoProveedor @list_of_cols_val_tab_del, @transaction_type ;
	END

	Salir:
END