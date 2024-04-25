CREATE PROCEDURE STR_SP_LTR_ActEstadoLetra
(
	/*********************************** 
		Migracion hana: Emision de Letras
		==================
		Por: Nerio Flores
		Fecha: 13/08/2014
		Comentarios: Este SP fue crado basandose del SP de la version SQL
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/
	--IN p_codLet NVARCHAR(20), 
	IN p_EstAct INTEGER,
	IN p_EstAnt INTEGER,
	--IN p_Fecha TIMESTAMP,
	IN p_Serie NVARCHAR(10),
	IN p_TipoLet INTEGER
)
AS
BEGIN
	UPDATE "@ST_LT_MSTLET" 
	SET 
	"U_estAct" = RIGHT('000'|| TO_VARCHAR(:p_EstAct),3),
	"U_estAnt" = RIGHT('000'|| TO_VARCHAR(:p_EstAnt),3)
	WHERE
	"U_serie" = :p_Serie
	AND "U_tipo" = (CASE WHEN :p_TipoLet = 1 THEN '001' ELSE '002' END);
END;