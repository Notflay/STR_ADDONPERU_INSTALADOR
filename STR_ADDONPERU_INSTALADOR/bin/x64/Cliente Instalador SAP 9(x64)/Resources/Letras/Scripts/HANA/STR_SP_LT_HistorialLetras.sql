CREATE PROCEDURE STR_SP_LT_HistorialLetras
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
	IN Letra NVARCHAR(50)
)
AS
BEGIN 
	SELECT 
		T0."TransId" AS "TransId",
		T1."Ref2" AS "Letra", 
		CASE   
			WHEN T1."U_LET_EST" = '002' THEN 'Cartera'  
			WHEN T1."U_LET_EST" = '003' THEN 'Enviado Cobranza'  
			WHEN T1."U_LET_EST" = '004' THEN 'Cobranza Libre'  
			WHEN T1."U_LET_EST" = '005' THEN 'Cobranza Garantía'  
			WHEN T1."U_LET_EST" = '006' THEN 'Enviado Descuento'  
			WHEN T1."U_LET_EST" = '007' THEN 'Descuento' 
			WHEN T1."U_LET_EST" = '008' THEN 'Protesto'  
		ELSE '0'  
		END AS "Estado",
		T1."RefDate" AS "Fecha", 
		T1."Memo" AS "Comentario",
		CAST(ROW_NUMBER() OVER(PARTITION BY T1."Ref2" ORDER BY T0."TransId") AS INTEGER) AS "ID"
	FROM "OJDT" T1 
	INNER JOIN "JDT1" T0 ON T0."TransId" = T1."TransId"
	WHERE T1."Ref2" = :Letra;
END;