CREATE PROCEDURE SP_RML_PT_CLIENTE
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN num_of_cols_in_key int,
	IN list_of_key_cols_tab_del nvarchar(255),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)
AS
BEGIN

	error :=0;
	error_message := N'Ok';

	/*============================================== OBJETOS ======================================================*/

	-->Plan de Cuentas
	IF :object_type = '1'  THEN
		CALL RML_PT_CL_1_PlanDeCuentas(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	-->Socio de negocio
	IF :object_type = '2'  THEN
		CALL RML_PT_CL_2_SociosNegocio(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Maestro de Articulos
	IF :object_type = '4'  THEN
		CALL RML_PT_CL_4_MaestroArticulos(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
			
	-->Factura de Deudores
	IF :object_type = '13'  THEN
		CALL RML_PT_CL_13_FacturaDeudores(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Nota de Credito Clientes
	IF :object_type = '14'  THEN
		CALL RML_PT_CL_14_NotaCreditoCliente(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Entrega
	IF :object_type = '15'  THEN
		CALL RML_PT_CL_15_Entrega(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Devoluciones
	IF :object_type = '16'  THEN
		CALL RML_PT_CL_16_Devoluciones(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	-->Pedido de Cliente
	IF :object_type = '17'  THEN
		CALL RML_PT_CL_17_PedidoCliente(:list_of_cols_val_tab_del, :transaction_type) ;	
	END IF;

	-->Factura de Proveedor
	IF :object_type = '18'  THEN
		CALL RML_PT_CL_18_FacturaProveedor(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Notade Credito Proveedor
	IF :object_type = '19'  THEN
		CALL RML_PT_CL_19_NotaCreditoProveedor(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Entrada Mercancia
	IF :object_type = '20'  THEN
		CALL RML_PT_CL_20_EntradaMercancia(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Pedido
	IF :object_type = '22'  THEN
		CALL RML_PT_CL_22_Pedido(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	-->Oferta de Ventas
	IF :object_type = '23'  THEN
		CALL RML_PT_CL_23_OfertaVentas(:list_of_cols_val_tab_del, :transaction_type) ;	
	END IF;

	-->Pago Recibido
	IF :object_type = '24'  THEN
		CALL RML_PT_CL_24_PAGORECIBIDO(:list_of_cols_val_tab_del, :transaction_type) ;	
	END IF;

	-->Pago Efectuado
	IF :object_type = '46'  THEN
		CALL RML_PT_CL_46_PAGOEFECTUADO(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Entrada de Mercancia
	IF :object_type = '59'  THEN
		CALL RML_PT_CL_59_ENTRADAMERCANCIA(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	-->Salida de Mercancia
	IF :object_type = '60'  THEN
		CALL RML_PT_CL_60_SALIDAMERCANCIA(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Transferencias de Stock
	IF :object_type = '67'  THEN
		CALL RML_PT_CL_67_TRANSFERENCIASTOCK(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	-->Anticipo Ventas
	IF :object_type = '203'  THEN
		CALL RML_PT_CL_203_ANTICIPOVENTAS(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;

	-->Anticipo Proveedor
	IF :object_type = '204'  THEN
		CALL RML_PT_CL_204_AnticipoProveedor(:list_of_cols_val_tab_del, :transaction_type) ;
	END IF;
	
	
	-- Resultado	
	SELECT :error, :error_message from dummy;

END;