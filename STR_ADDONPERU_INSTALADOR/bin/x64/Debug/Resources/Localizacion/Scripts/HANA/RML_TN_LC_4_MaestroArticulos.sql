CREATE FUNCTION RML_TN_LC_4_MaestroArticulos
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	buyunitmsr nvarchar(10);
	invtryUom nvarchar(10);
	salUnitMsr nvarchar(10);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN
	
		SELECT "BuyUnitMsr","SalUnitMsr","InvntryUom" INTO buyunitmsr, salUnitMsr,invtryUom FROM OITM WHERE "ItemCode" = :id;
	
		IF IFNULL(:buyunitmsr,'')='' THEN
			error_message := 'Debe definir la unidad de medida para Compras';
		END IF;
	
		IF IFNULL(:salUnitMsr,'')='' THEN
			error_message := 'Debe definir la unidad de medida para Ventas';
		END IF;
	
		IF IFNULL(:invtryUom,'')='' THEN
			error_message := 'Debe definir la unidad de medida para Inventario';
		END IF;
	END IF;
	
END