CREATE PROCEDURE STR_SP_LT_EmisionLetras
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
	IN NumEmi INTEGER
)
AS
	/*****************************************************************
	declaracion de variable que tomaran los valores de los parametros
	******************************************************************/
	VALOR1 INTEGER;
	VALOR2 INTEGER;

BEGIN
	
	/*************************************************************************************************************
	creacion de las tablas temporales: no tienen que ser columnares, porque ya no seria posible el Update y Delete
	***************************************************************************************************************/
	CREATE LOCAL TEMPORARY TABLE #TEMPCAB("U_CardCode" NVARCHAR(30), "U_CardName" NVARCHAR(200), "U_EmiDate" TIMESTAMP, "U_CantLet" INTEGER, 
											"Address" NVARCHAR(100));
											
	CREATE LOCAL TEMPORARY TABLE #TEMPDOC("D_LineaDoc" INTEGER, "D_DocEntry" INTEGER, "D_TipoDoc" NVARCHAR(10), "D_Legal" NVARCHAR(50), "D_Monto" DECIMAL, 
											"D_Moneda" NVARCHAR(10), "D_Fecha" TIMESTAMP, "D_MontoDoc" DECIMAL, "D_Porcentaje" INTEGER);
											
	CREATE LOCAL TEMPORARY TABLE #TEMPLET("L_LineaLetra" INTEGER, "L_Dias" SMALLINT, "L_Moneda" NVARCHAR(10), "L_Monto" DECIMAL, "L_Asiento" INTEGER, 
											"L_Letra" NVARCHAR(20), "L_VencLetra" TIMESTAMP);
											
	CREATE LOCAL TEMPORARY TABLE #FINAL("C_CardCode" NVARCHAR(20), "C_CardName" NVARCHAR(200), "C_FecEmi" DATE, "C_CantLet" INTEGER, "C_NumCanje" INTEGER, 
											"C_Dato1" NVARCHAR(200), "C_Dato2" NVARCHAR(200), "D_LineaDoc" INTEGER, "D_DocEntry" INTEGER, 
											"D_TipoDoc" NVARCHAR(10), "D_Legal" NVARCHAR(20), "D_Monto" NUMERIC(19,6), "D_Moneda" NVARCHAR(10), 
											"D_Fecha" DATE, "D_MontoDoc" NUMERIC(19,6), "D_Dato1" NVARCHAR(20), "D_Dato2" NVARCHAR(20), "D_PorcCanje" INTEGER, 
											"L_LineaLetra" INTEGER, "L_Dias" INTEGER, "L_Moneda" NVARCHAR(10), "L_Monto" NUMERIC(19,6), "L_Asiento" INTEGER, 
											"L_Letra" NVARCHAR(20), "L_VencLet" DATE, "L_Dato1" NVARCHAR(20), "L_Dato2" NVARCHAR(20));
	
	/***********************************************************************************
		Se cargan todas las consultas a las tablas temporales correspondientes
	************************************************************************************/
	INSERT INTO #TEMPCAB("U_CardCode", "U_CardName", "U_EmiDate", "U_CantLet", "Address")
	(
		select "U_CardCode", "U_CardName", "U_EmiDate", "U_CantLet", t1."Address" 
		from "@ST_LT_EMILET" t0 inner join OCRD t1 on t0."U_CardCode" = t1."CardCode" 
		where t0."DocEntry" = :NumEmi
	);
	
	INSERT INTO #TEMPDOC("D_LineaDoc", "D_DocEntry", "D_TipoDoc", "D_Legal", "D_Monto", "D_Moneda", "D_Fecha", "D_MontoDoc", "D_Porcentaje")
	(
		select 
		ROW_NUMBER() over(order by t1."U_DocEntry") AS "D_LineaDoc", t1."U_DocEntry" AS "D_DocEntry", t1."U_tipDoc" AS "D_TipoDoc", 
		t1."U_numLeg" AS "D_Legal", t1."U_Pago" AS "D_Monto", t1."U_DocCurr" AS "D_Moneda",
		(select tx."DocDate" from OINV tx where tx."DocEntry" = t1."U_DocEntry" and t1."U_tipDoc" = 'FA') AS "D_Fecha",
		"U_Total" AS "D_MontoDoc",
		TO_INTEGER(round("U_Total" / t1."U_Pago" * 100,0)) AS "D_Porcentaje"
		from "@ST_LT_ELDOCS" t1 where t1."U_chkSel" = 'Y' and t1."DocEntry" = :NumEmi
	);
	
	INSERT INTO #TEMPLET("L_LineaLetra", "L_Dias", "L_Moneda", "L_Monto", "L_Asiento", "L_Letra", "L_VencLetra")
	(
		select 
		ROW_NUMBER() over(order by t2."U_NumAsi") AS "L_LineaLetra", t2."U_diaLet" AS "L_Dias", t2."U_DocCurr" AS "L_Moneda", 
		case when t2."U_DocCurr" = 'SOL' then t2."U_ImpML" else t2."U_ImpME" end  AS "L_Monto", 
		t2."U_NumAsi" AS "L_Asiento", t2."U_codLet" AS "L_Letra", t2."U_VencDate" AS "L_VencLetra" 
		from "@ST_LT_ELLETRAS" t2 where t2."DocEntry" = :NumEmi
	);
	
	/*********************************************************************************************************************
		Se cargan las variables con las consultas: En las condicionales IF, no se pueden incluir sub queries directamentes
	***********************************************************************************************************************/
	select(select COUNT(*) from #TEMPDOC)into VALOR1 from dummy;
	select(select COUNT(*) from #TEMPLET)into VALOR2 from dummy;


	IF :VALOR1 > :VALOR2
	THEN
	
		INSERT INTO #FINAL("D_LineaDoc", "D_DocEntry", "D_TipoDoc", "D_Legal", "D_Monto", "D_Moneda", "D_Fecha", "D_MontoDoc", "D_PorcCanje", "L_LineaLetra", 
						"C_CardCode", "C_CardName", "C_FecEmi", "C_CantLet", "C_NumCanje", "C_Dato1")
		(
			select t0.*, "D_LineaDoc", t1."U_CardCode", t1."U_CardName", t1."U_EmiDate", t1."U_CantLet", :NumEmi, t1."Address" from #TEMPDOC t0 , #TEMPCAB t1
		);
		
			/***********************************************************************************
			Aplicando el Update a la tabla temporal #FINAL
			************************************************************************************/
			update #FINAL T0
			set T0."L_Asiento" = t1."L_Asiento",
				T0."L_Dias" = t1."L_Dias",
				T0."L_Letra" = t1."L_Letra",
				T0."L_Moneda" = t1."L_Moneda",
				T0."L_Monto" = t1."L_Monto",
				T0."L_VencLet" = t1."L_VencLetra" 
			from #FINAL T0 inner join #TEMPLET t1 on T0."L_LineaLetra" = t1."L_LineaLetra";
		--)
	ELSE
		INSERT INTO #FINAL("L_LineaLetra", "L_Dias", "L_Moneda", "L_Monto", "L_Asiento", "L_Letra", "L_VencLet", "D_LineaDoc", "C_CardCode", "C_CardName", 
						"C_FecEmi", "C_CantLet", "C_NumCanje", "C_Dato1")
		(
			select t0.*, "L_LineaLetra", t1."U_CardCode", t1."U_CardName", t1."U_EmiDate", t1."U_CantLet", :NumEmi, t1."Address" from #TEMPLET t0 , #TEMPCAB t1
		);	
			/***********************************************************************************
			Aplicando el Update a la tabla temporal #FINAL
			************************************************************************************/
			update #FINAL T0
			set T0."D_DocEntry" = t1."D_DocEntry",
				T0."D_Legal" = t1."D_Legal",
				T0."D_Moneda" = t1."D_Moneda",
				T0."D_Monto" = t1."D_Monto",
				T0."D_TipoDoc" = t1."D_TipoDoc",
				T0."D_MontoDoc" = t1."D_MontoDoc",
				T0."D_PorcCanje" = t1."D_Porcentaje",
				T0."D_Fecha" = t1."D_Fecha" 
			from #FINAL T0 inner join #TEMPDOC t1 on T0."D_LineaDoc" = t1."D_LineaDoc";
	END IF;
	
	/***********************************************************************************
		Resultado final a mostrar
	************************************************************************************/
	select * from #FINAL;

	/***********************************************************************************
		Importante: Eliminar las tablas temporales al final del procedimiento.
	************************************************************************************/
	DROP TABLE #TEMPCAB;
	DROP TABLE #TEMPDOC;
	DROP TABLE #TEMPLET;	
	DROP TABLE #FINAL;
	
END;