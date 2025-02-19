CREATE PROCEDURE STR_SP_LT_DetalleLetras
(
	/*********************************** 
		Migracion hana: DetalleLetras
		==================
		por: Nilton condori
		Fecha: 12/08/2014
		Comentarios: Este SP fue crado basandose del SP de la version SQL
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/
	IN CodCliente nvarchar(20),
	IN FecIni date,
	IN FecFin date,
	IN Estado nvarchar(10),
	IN banco nvarchar(10)
)
AS

	/*****************************************************************
	declaracion de variable que tomaran los valores de los parametros
	******************************************************************/
	v_CodCliente NVARCHAR(20);
	v_Estado NVARCHAR(10);
	
BEGIN

	/*************************************************************************************************************
	creacion de las tablas temporales: no tienen que ser columnares, porque ya no seria posible el Update y Delete
	***************************************************************************************************************/
	CREATE LOCAL TEMPORARY TABLE #TEMP("TransId" integer, "Letra" nvarchar(100), "Estado" nvarchar(20), "Fecha" date, "Comentario" nvarchar(50), "Banco" nvarchar(100), "ID" INTEGER );
	CREATE LOCAL TEMPORARY TABLE #TEMP1("TransId" integer, "Letra" nvarchar(100), "Estado" nvarchar(20), "Fecha" date, "Comentario" nvarchar(50), "Banco" nvarchar(100), "ID" INTEGER);
	
	
	v_CodCliente := :CodCliente;
	v_Estado := :Estado;
	
	IF :CodCliente = '' THEN
		v_CodCliente := NULL;
	END IF;
	
	IF :Estado = '' THEN
		v_Estado := null;
	END IF;
	
	IF :banco = '' THEN	
	
		/***********************************************************************************
		Se carga toda la consulta a la tabla temporal #TEMP
		************************************************************************************/
		INSERT INTO #TEMP ("TransId", "Letra", "Estado", "Fecha", "Comentario", "Banco", "ID")
		(
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
				
				(select "BankName" from odsc where "BankCode" = T3."U_nomBan") AS "Banco",
				
				TO_INTEGER(ROW_NUMBER() OVER(PARTITION BY T1."Ref2" ORDER BY T0."TransId")) AS "ID"
				
			FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0."TransId" = T1."TransId" 
			LEFT JOIN (select "U_nroInt","U_nomBan" from "@ST_LT_DEPLET" X0 inner join "@ST_LT_DEPDET" X1 on  X0."DocEntry" = X1."DocEntry") T3
			ON T1."TransId" = t3."U_nroInt" WHERE T0."ShortName" = IFNULL(:v_CodCliente, t0."ShortName") AND T1."TransType" = '30' 
			AND t0."RefDate" BETWEEN :FecIni AND :FecFin AND t1."U_LET_EST" = IFNULL(:v_Estado,t1."U_LET_EST")
		);
		
		/****************************************************************************************************
		Se eliminan los registros segun el filtro a la tabla temporal y finalmente se hace la consulta final
		****************************************************************************************************/
		DELETE FROM #TEMP WHERE "ID" = 1 AND "Letra" IN (SELECT "Letra" from #TEMP WHERE "ID" = 2); 
		SELECT * FROM #TEMP	ORDER BY 2;	
		
	ELSE
		
		/***********************************************************************************
		Se carga toda la consulta a la tabla temporal #TEMP
		************************************************************************************/
		INSERT INTO #TEMP1("TransId", "Letra", "Estado", "Fecha", "Comentario", "Banco", "ID")
		(
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
			END  AS "Estado",
			
			T1."RefDate" AS "Fecha", 
			T1."Memo" AS "Comentario",
			
			(select "BankName" from odsc where "BankCode" = T3."U_nomBan") AS "Banco",
			
			TO_INTEGER(ROW_NUMBER() OVER(PARTITION BY T1."Ref2" ORDER BY T0."TransId")) AS "ID"
			
			FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0."TransId" = T1."TransId"
			LEFT JOIN (select "U_nroInt", "U_nomBan" from "@ST_LT_DEPLET" X0 inner join "@ST_LT_DEPDET" X1 on  X0."DocEntry" = X1."DocEntry") T3
			ON T1."TransId" = t3."U_nroInt"	WHERE T0."ShortName" = IFNULL(:v_CodCliente, t0."ShortName") AND T1."TransType" = '30' 
			AND t0."RefDate" BETWEEN :FecIni AND :FecFin AND t1."U_LET_EST" = IFNULL(:v_Estado,t1."U_LET_EST") AND T3."U_nomBan" = :banco
		);
		
		/****************************************************************************************************
		Se eliminan los registros segun el filtro a la tabla temporal y finalmente se hace la consulta final
		****************************************************************************************************/
		DELETE FROM #TEMP1 WHERE ID = 1 AND "Letra" IN (SELECT "Letra" from #TEMP1 WHERE "ID" = 2); 
		SELECT * FROM #TEMP1 ORDER BY 2;
		
	END IF;
	
	/*********************************************************************************
	Se eliminan las tablas temporales, para que sean creadas en la proxima ejecucion
	**********************************************************************************/	
	DROP TABLE #TEMP1;
	DROP TABLE #TEMP;

END;
