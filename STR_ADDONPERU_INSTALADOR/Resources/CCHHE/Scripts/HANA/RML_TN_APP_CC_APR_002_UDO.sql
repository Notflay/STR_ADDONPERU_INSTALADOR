CREATE FUNCTION RML_TN_APP_CC_APR_002_UDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	cantidad int;
	numoper varchar(10);
BEGIN
	-- CAJA CHICA
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type ='U'
	THEN
			-- VALIDA CAJA CHICA CARGA DETALLE
			DECLARE cursor CURSOR_EAR_DET FOR
       	 	SELECT  ROW_NUMBER() OVER () AS "Orden",*
       	 	FROM "@STR_EARAPRDET"  
        	WHERE "DocEntry" = :id;
        	
        	SELECT COUNT(*) INTO cantidad FROM "@STR_EARAPRDET"  
        	WHERE "DocEntry" = :id;
        	
        	SELECT "U_ER_NMPE" INTO numoper FROM "@STR_EARAPR" WHERE "DocEntry"  = :id;
        	
        	IF :cantidad = 0 THEN
        		error_message := 'Se tiene que aperturar minimo una linea';
        		RETURN;
        	END IF;
        		
        	IF IFNULL(:numoper,'') = '' THEN
        		error_message := 'No se registró el pago efectuado de la apertura';
        		RETURN;
        	END IF;	
			-- 
			FOR DATA AS CURSOR_EAR_DET
			DO
			
				IF IFNULL(DATA."U_ER_CDCT",'') = '' THEN
					error_message := 'Linea: '|| DATA."Orden"  || ' | No se registró la Cuenta contable';
					break;
				END IF;
				
				IF IFNULL(DATA."U_ER_NMER",'') = '' THEN
					error_message := 'Linea: '|| DATA."Orden"  || ' | No se registró el Núm. de Entrega a Rendir';
					break;
				END IF;
				
			END FOR;
			
	END IF;	
END