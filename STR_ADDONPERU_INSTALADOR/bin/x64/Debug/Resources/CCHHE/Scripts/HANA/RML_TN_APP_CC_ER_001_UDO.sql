CREATE FUNCTION RML_TN_APP_CC_ER_001_UDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	ttcch decimal(19,6);
	sldcch decimal(19,6);
	flgsld char(1);
	cnt int;
	inct int=0;

BEGIN
	-- CAJA CHICA
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type IN('A','U')
	THEN
	
			SELECT SUM("IMT") INTO ttcch FROM(
			SELECT 
				CASE T0."U_CC_MNDA" WHEN 'SOL' THEN
					CASE T1."U_CC_MNDC" WHEN 'SOL' THEN
						"U_CC_TTLN"
					ELSE
						("U_CC_TTLN"*(SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_CC_FCDC"))
					END
				ELSE
					CASE T1."U_CC_MNDC" WHEN 'SOL' THEN
						("U_CC_TTLN")/(SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_CC_FCDC")
					ELSE
						"U_CC_TTLN" 
					END
				END AS "IMT" 
			FROM "@STR_CCHCRG" T0 INNER JOIN "@STR_CCHCRGDET" T1 ON T0."DocEntry" = T1."DocEntry" 
			WHERE T0."DocEntry" = :id AND "U_CC_SLCC" = 'Y' AND "U_CC_ESTD" IN ('CRE','ERR')
			) AS TX0;
			SELECT "U_CC_SLDI" - :ttcch INTO sldcch  FROM "@STR_CCHCRG" WHERE "DocEntry" = :id;
			SELECT TOP 1 "U_STR_SLNG" INTO flgsld FROM "@BPP_CAJASCHICAS" T0 INNER JOIN "@STR_CCHCRG" T1 ON T0."Code" = T1."U_CC_NMBR" WHERE T1."DocEntry" = :id;
			IF :sldcch < 0 AND IFNULL(:flgsld,'N')<> 'Y'
			THEN
				error_message := 'El monto total de los documentos registrados (' || ttcch || '), es mayor al saldo de esta caja chica';
			END IF;
	
			-- Validaciones de CREACIÓN para CAJA CHICA
			SELECT COUNT(*) INTO cnt FROM "@STR_CCHCRGDET" WHERE "DocEntry" = :id AND (IFNULL("U_CC_DIM1",'')='' OR IFNULL("U_CC_DIM2",'')='' 
			OR IFNULL("U_CC_DIM3",'')=''  OR IFNULL("U_CC_DIM4",'')='');
			IF :cnt > 0
			THEN
				error_message := 'Las dimensiones de Centro de Costos es obligatorio a nivel detalle';
			END IF;
			
			--------------------------------------------------------
			-- Validación de Socio de Negocio Inactivo
			--------------------------------------------------------
			
			SELECT COUNT(*) INTO inct FROM "@STR_CCHCRGDET" T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."U_CC_CDPV" WHERE T0."DocEntry" = :id AND T1."frozenFor" = 'Y'; 
			IF :inct > 0
			THEN
				 SELECT T1."LineId" INTO inct -- Almacena el número de línea
				 FROM "@STR_CCHCRGDET" T1
				 INNER JOIN OCRD T0 ON T0."CardCode" = T1."U_CC_CDPV"
				 WHERE T1."DocEntry" = :id AND T0."frozenFor" = 'Y'
				 LIMIT 1; -- Selecciona solo un registro
			
				error_message := CONCAT(CONCAT('El Socio de Negocio de la línea ',:inct),' se encuentra inactivo');
			END IF;
			
			--------------------------------------------------------
			-- Validación de Partida presupuestal en base al CC - CRP
			--------------------------------------------------------
			/*
	SELECT COUNT(*) INTO part FROM "@STR_CCHCRGDET" where "DocEntry" = :id AND "U_CC_DIM1" <> SUBSTRING("U_CC_CMP1", 7, 3);
	IF :part > 0
	THEN
		 SELECT T1."LineId" INTO part -- Almacena el número de línea
		 FROM "@STR_CCHCRGDET" T1 where T1."DocEntry" = :id 
		 AND T1."U_CC_DIM1" <> SUBSTRING(T1."U_CC_CMP1", 7, 3) 
		 LIMIT 1; -- Selecciona solo un registro
	
		 error := 1;
		 error_message := CONCAT('La partida ingresada no corresponde al CC seleccionado en la línea ',:part);
	END IF;
	*/
			
	END IF;	
END