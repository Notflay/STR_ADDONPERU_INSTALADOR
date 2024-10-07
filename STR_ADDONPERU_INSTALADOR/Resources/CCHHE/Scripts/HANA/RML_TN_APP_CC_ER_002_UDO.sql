CREATE FUNCTION RML_TN_APP_CC_ER_002_UDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	cnt int;
	inct int=0;

BEGIN
	-- ENTREGA A RENDIR
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type IN('A','U')
	THEN		
		DECLARE cursor CURSOR_EAR_DET FOR
       	SELECT  ROW_NUMBER() OVER () AS "Orden",*
       	FROM "@STR_EARCRGDET"  
       	WHERE IFNULL("U_ER_CDPV",'') <> '' 
        AND "DocEntry" = :id AND "U_ER_ESTD" <> 'OK';
		
		FOR DATA AS CURSOR_EAR_DET
			DO
			
				IF IFNULL(DATA."U_ER_DIM1",'') = '' THEN
					error_message := 'Linea: '|| DATA."Orden"  || ' | La dimensión 1 es obligatoria';
					break;
				END IF;
				
				IF IFNULL(DATA."U_ER_DIM3",'') = '' THEN
					error_message := 'Linea: '|| DATA."Orden"  || ' | La dimensión 3 es obligatoria';
					break;
				END IF;
				/*
				IF IFNULL(DATA."U_CC_DIM1",'') = '' THEN
					error_message := 'Linea: '|| DATA."LineId"  || ' | La dimensión 5 es obligatoria';
				END IF;
				*/
				
				SELECT COUNT(*) INTO inct FROM OCRD WHERE "CardCode" = DATA."U_ER_CDPV" AND "frozenFor" = 'Y'; 
				IF :inct > 0
				THEN
					error_message := 'Linea: '|| DATA."Orden"  || ' | El Socio de Negocio se encuentra inactivo';
					break;
				END IF;
				
		END FOR;
		--------------------------------------------------------
		-- Validación de Partida presupuestal en base al CC - CRP
		--------------------------------------------------------
			
	END IF;	
END