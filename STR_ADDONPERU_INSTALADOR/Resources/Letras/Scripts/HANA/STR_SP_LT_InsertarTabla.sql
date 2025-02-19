CREATE PROCEDURE STR_SP_LT_InsertarTabla
(

	IN p_NomTabla NVARCHAR(100),
	IN p_Valor1 NVARCHAR(20),
	IN p_Valor2 NVARCHAR(20),
	IN p_Valor3 NVARCHAR(250),
	IN p_Valor4 NVARCHAR(20)
)
AS

	SQLString nVarchar(4000);
	ParmDefinition nVarchar(4000);
	Code nVarchar(8);
	--CodeOUT Nvarchar(8);
			
BEGIN
	/**********************************************************************
	Comparamos el nombre de la tabla, si corresponde hace la insercion.
	**********************************************************************/
	IF :p_NomTabla = '@ST_LT_SERL'
	THEN
		
		SELECT (RIGHT('00000000' || TO_VARCHAR(IFNULL((select max("Code") from "@ST_LT_SERL"),0) + 1 ),8)) INTO Code FROM DUMMY;
		INSERT INTO "@ST_LT_SERL" VALUES (:Code, :Code, :p_Valor1, :p_Valor2, :p_Valor3, :p_Valor4);
	ELSE IF	:p_NomTabla = '@ST_LT_CONF'
	THEN
		SELECT (RIGHT('00000000' || TO_VARCHAR(IFNULL((select max("Code") from "@ST_LT_CONF"),0) + 1 ),8)) INTO Code FROM DUMMY;
		INSERT INTO "@ST_LT_CONF" VALUES (:Code, :Code, :p_Valor1, :p_Valor2, :p_Valor3, :p_Valor4);
	END IF;
	END IF;
END;