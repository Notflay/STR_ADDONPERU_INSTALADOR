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
	
	IF :transaction_type = 'A' OR :transaction_type = 'U'
	THEN	
		-- Validaciones de CREACIÓN para EAR
		SELECT COUNT(*) INTO cnt FROM "@STR_EARCRGDET" WHERE "DocEntry" = id AND (IFNULL("U_ER_DIM1",'')='' OR IFNULL("U_ER_DIM2",'')='' 
		OR IFNULL("U_ER_DIM3",'')=''  OR IFNULL("U_ER_DIM4",'')='');
		IF :cnt > 0
		THEN
			error_message := 'Las dimensiones de Centro de Costos es obligatorio a nivel detalle';
		END IF;
		
		--------------------------------------------------------
		-- Validación de Socio de Negocio Inactivo
		--------------------------------------------------------
		
		SELECT COUNT(*) INTO inct FROM "@STR_EARCRGDET" T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."U_ER_CDPV" WHERE T0."DocEntry" = id AND T1."frozenFor" = 'Y'; 
		IF :inct > 0
		THEN
			 SELECT T1."LineId" INTO inct -- Almacena el número de línea
			 FROM "@STR_EARCRGDET" T1
			 INNER JOIN OCRD T0 ON T0."CardCode" = T1."U_ER_CDPV"
			 WHERE T1."DocEntry" = id AND T0."frozenFor" = 'Y'
			 LIMIT 1; -- Selecciona solo un registro
		
			 error_message := CONCAT(CONCAT('El Socio de Negocio de la línea ',:inct),' se encuentra inactivo');
		END IF;
		
		--------------------------------------------------------
		-- Validación de Partida presupuestal en base al CC - CRP
		--------------------------------------------------------
		/*
		SELECT COUNT(*) INTO part FROM "@STR_CCHCRGDET" where "DocEntry" = id AND "U_CC_DIM1" <> SUBSTRING("U_CC_CMP1", 7, 3);
		IF :part > 0
		THEN
		 SELECT T1."LineId" INTO part -- Almacena el número de línea
		 FROM "@STR_CCHCRGDET" T1 where T1."DocEntry" = id 
		 AND T1."U_CC_DIM1" <> SUBSTRING(T1."U_CC_CMP1", 7, 3) 
		 LIMIT 1; -- Selecciona solo un registro
	
		 error := 1;
		 error_message := CONCAT('La partida ingresada no corresponde al CC seleccionado en la línea ',:part);
		END IF;
		*/
			
	END IF;	
END