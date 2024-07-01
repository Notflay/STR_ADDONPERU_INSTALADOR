CREATE FUNCTION RML_TN_LC_1_PlanDeCuentas
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	 clsBlncCom CHAR(3);
	 clsFinanciera CHAR(3);
	 clsBlncGen CHAR(3);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	IF :transaction_type IN ('A','U') THEN
		
		SELECT "U_BPP_CBALC","U_BPP_CLASCTAFIN","U_BPP_CTABALANCE" INTO clsBlncCom,clsFinanciera,clsBlncGen FROM OACT WHERE "AcctCode" = :id;
		
		IF ifnull(:clsBlncCom,'') = '' THEN
			error_message := 'Es obligatorio definir la Clasificación de Balance de Compras'; 
		END IF;
		
		IF ifnull(:clsFinanciera,'') = '' THEN
			error_message := 'Es obligatorio definir la Clasificación de Balance Financiera';
		END IF;
		
		IF ifnull(:clsBlncGen,'') = '' THEN
			error_message := 'Es obligatorio definir la Clasificación de Balance General';
		END IF;
	END IF;
END;