CREATE PROCEDURE STR_SP_LT_DatosLetras
(
	/*********************************** 
		Migracion hana: Obtiene datos de letras
		==================
		Por: Nerio Flores
		Fecha: 13/08/2014
		Comentarios: Este SP ES NUEVO
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/

	IN p_Serie NVARCHAR(20),
	IN P_CodLetra NVARCHAR(20)
)
AS
BEGIN
	SELECT 
	EL."DocEntry", 
	EL."U_codLet", 
	MS."U_estAct" as "Estado", 
	EL."U_NumAsi", 
	EL."U_ImpML", 
	EL."U_ImpME"  
	FROM "@ST_LT_ELLETRAS" EL 
	LEFT JOIN "@ST_LT_MSTLET" MS 
	ON TO_DECIMAL(MS."Code") = (SELECT MAX(TO_DECIMAL(MS2."Code")) 
								FROM "@ST_LT_MSTLET" MS2 
								WHERE  MS2."U_cdStLet" = EL."U_codLet") 
	WHERE MS."U_serie" = :p_Serie AND MS."U_tipo" = '001' AND 
	EL."DocEntry" = (select max(DL."DocEntry") from "@ST_LT_ELLETRAS" DL, "@ST_LT_EMILET" EL2 
					  where DL."U_codLet" = :P_CodLetra AND EL2."U_SerLetra" = :p_Serie AND
					  DL."DocEntry" = EL2."DocEntry");
END;