CREATE PROCEDURE SP_RML_TN_CLIENTE
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
	IF :object_type = '1' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_1_PlanDeCuentas(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Socio de negocio
	IF :object_type = '2' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_2_SociosNegocio(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 2 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Maestro de Articulos
	IF :object_type = '4' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_4_MaestroArticulos(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 4 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Oferta de Ventas
	IF :object_type = '23' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_23_OfertaVentas(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Pago Recibido
	IF :object_type = '24' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_24_PAGORECIBIDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 24 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Pedido de Cliente
	IF :object_type = '17' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_17_PedidoCliente(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 17 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Entrega
	IF :object_type = '15' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_15_Entrega(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 15 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Factura de Deudores
	IF :object_type = '13' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_13_FacturaDeudores(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 13 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Devoluciones
	IF :object_type = '16' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_16_Devoluciones(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 16 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Nota de Credito Clientes
	IF :object_type = '14' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_14_NotaCreditoCliente(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 14 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Pedido
	IF :object_type = '22' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_22_Pedido(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 22 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Entrada Mercancia
	IF :object_type = '20' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_20_EntradaMercancia(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 20 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Factura de Proveedor
	IF :object_type = '18' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_18_FacturaProveedor(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 18 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Notade Credito Proveedor
	IF :object_type = '19' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_19_NotaCreditoProveedor(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 19 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Pago Efectuado
	IF :object_type = '46' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_46_PagoEfectuado(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 46 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Entrada de Mercancia
	IF :object_type = '59' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_59_EntradaMercancia(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 59 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Salida de Mercancia
	IF :object_type = '60' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_60_SalidaMercancia(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 60 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Transferencias de Stock
	IF :object_type = '67' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_67_TransferenciaStock(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 67 INTO error FROM DUMMY;
		END IF;
	END IF;

	-->Anticipo Ventas
	IF :object_type = '203' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_203_AnticipoVentas(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 203 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	-->Anticipo Proveedor
	IF :object_type = '204' AND IFNULL(:error,0) = 0 THEN
		SELECT RML_TN_CL_204_AnticipoProveedor(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 204 INTO error FROM DUMMY;
		END IF;
	END IF;

	SELECT :error, :error_message from dummy;


-- Resultado
SELECT :error, :error_message from dummy;

END;