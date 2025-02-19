CREATE PROCEDURE STR_SP_LT_MaestroLetra
(
	/*********************************** 
		Migracion hana: MaestroLetra
		==================
		por: Nilton condori
		Fecha: 13/08/2014
		Comentarios: Este SP fue crado basandose del SP de la version SQL
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/
	IN p_CodLet NVARCHAR(20),
	IN p_EstAct INTEGER,
	IN p_EstAnt INTEGER,
	IN p_Fecha TIMESTAMP,
	IN p_Serie NVARCHAR(10),
	IN p_TipoRen INTEGER,
	IN p_TipoLet INTEGER
)
AS
	/***********************
	declaracion de variable
	************************/
	v_Name NVARCHAR(60);
	v_Code NVARCHAR(16);
	v_CodStrLet NVARCHAR(20);
	v_NCodLet DECIMAL;			
			
BEGIN
	/***************************************************************
		Nomenclatura del Locate, funcion que reemplaza al CHARINDEX
	****************************************************************/
	IF IFNULL(LOCATE(:p_CodLet, '-', 1), 0)<>0 THEN
		IF(:p_CodLet <> '-1')				
		THEN
			v_NCodLet := SUBSTRING(:p_CodLet, 1, LOCATE(:p_CodLet, '-', 1) - 1);
		ELSE
			v_NCodLet := :p_CodLet;
		END IF;				
	ELSE
		v_NCodLet := :p_CodLet;
	END IF;	
	
	SELECT(Select IFNULL(max(TO_INTEGER("Code")),0) + 1 from "@ST_LT_MSTLET" )INTO v_Code FROM DUMMY;
	v_Name := ('Letra ' || :v_Code);
	
	IF(:p_TipoRen = 0) --Se genera una nueva letra
	THEN
		IF(:v_NCodLet = -1)
		THEN
			SELECT(Select IFNULL(max("U_codLet"),0) + 1 from "@ST_LT_MSTLET"  where "U_cdStLet" like 'LET%' and "U_serie" =  :p_Serie And "U_tipo" = case when :p_TipoLet = 1 then '001' else '002' end) INTO v_NCodLet FROM DUMMY;
		END IF;	
		v_CodStrLet := 'LET' || RIGHT('0000000000' || TO_VARCHAR(:v_NCodLet),10);
	
	ELSE--Se renueva una letra
	
		v_CodStrLet := 'LET' || RIGHT('0000000000' || TO_VARCHAR(:v_NCodLet),10) || '-' || RIGHT('00' || TO_VARCHAR(:p_TipoRen),2);
	END IF;
	
	/*****************************************************************
	Se inserta los datos en la tabla "@ST_LT_MSTLET"
	******************************************************************/
	INSERT INTO "@ST_LT_MSTLET" VALUES (:v_Code, :v_Name, :p_Fecha, :v_NCodLet, :v_CodStrLet, RIGHT('000' || TO_VARCHAR(:p_EstAct),3), RIGHT('000' || TO_VARCHAR(:p_EstAnt),3), :p_Serie, case when :p_TipoLet = 1 then '001' else '002' end);
END;