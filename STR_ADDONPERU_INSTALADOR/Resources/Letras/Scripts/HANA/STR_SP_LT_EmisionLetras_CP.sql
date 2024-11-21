CREATE PROCEDURE STR_SP_LT_EmisionLetras_CP
(
	/*********************************** 
		Migracion hana: Emision de Letras
		==================
		Por: Nerio Flores
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
	Valor_01 INTEGER;
	Valor_02 INTEGER;
BEGIN
	CREATE LOCAL TEMPORARY TABLE #TEMPCAB("U_CardCode" NVARCHAR(15), "U_CardName" NVARCHAR(100), "U_EmiDate" TIMESTAMP, "U_CantLet" INTEGER, "Address" NVARCHAR(100));
	CREATE LOCAL TEMPORARY TABLE #TEMPDOC("D_LineaDoc" INTEGER, "D_DocEntry" INTEGER, "D_TipoDoc" NVARCHAR(10), "D_Legal" NVARCHAR(50), "D_Monto" DECIMAL, "D_Moneda" NVARCHAR(5), "D_Fecha" TIMESTAMP, "D_MontoDoc" DECIMAL, "D_Porcentaje" DECIMAL);
	CREATE LOCAL TEMPORARY TABLE #TEMPLET("L_LineaLetra" INTEGER, "L_Dias" INTEGER, "L_Moneda" VARCHAR(10), "L_Monto" DECIMAL, "L_Asiento" INTEGER, "L_Letra" VARCHAR(20), "L_VencLetra" TIMESTAMP);
	
	
	INSERT INTO #TEMPCAB("U_CardCode", "U_CardName", "U_EmiDate", "U_CantLet", "Address")
	(
		SELECT T0."U_CardCode", T0."U_CardName", T0."U_EmiDate", T0."U_CantLet", T1."Address"
		FROM "@ST_LT_EMILETCP" T0 
		INNER JOIN "OCRD" T1 ON T0."U_CardCode" = T1."CardCode" 
		WHERE T0."DocEntry" = :NumEmi
	);

	
	INSERT INTO #TEMPDOC("D_LineaDoc", "D_DocEntry", "D_TipoDoc", "D_Legal", "D_Monto", "D_Moneda", "D_Fecha", "D_MontoDoc", "D_Porcentaje")
	(	
		SELECT 
			TO_INTEGER(ROW_NUMBER() OVER(ORDER BY T1."U_DocEntry")) AS "D_LineaDoc", T1."U_DocEntry" AS "D_DocEntry", 
			T1."U_tipDoc" AS "D_TipoDoc", T1."U_numLeg" AS "D_Legal", T1."U_Pago" AS "D_Monto", T1."U_DocCurr" AS "D_Moneda",
			(
				SELECT F0."DocDate" FROM "OPCH" F0 WHERE F0."DocEntry" = T1."U_DocEntry" AND T1."U_tipDoc" = 'FA'
			) AS "D_Fecha",
			"U_Total" AS "D_MontoDoc",
			CAST(ROUND((T1."U_Total" / T1."U_Pago" * 100),0) AS INTEGER) AS "D_Porcentaje"
		FROM "@ST_LT_ELDOCSCP" T1 
		WHERE T1."U_chkSel" = 'Y' AND T1."DocEntry" = :NumEmi
	);
	
	
	INSERT INTO #TEMPLET("L_LineaLetra", "L_Dias", "L_Moneda", "L_Monto", "L_Asiento", "L_Letra", "L_VencLetra")
	(
		SELECT 
			TO_INTEGER(ROW_NUMBER() OVER(ORDER BY T2."U_NumAsi")) AS "L_LineaLetra", T2."U_diaLet" AS "L_Dias", T2."U_DocCurr" AS "L_Moneda",
			CASE 
				WHEN T2."U_DocCurr" = 'SOL' THEN T2."U_ImpML" ELSE T2."U_ImpME" 
			END AS "L_Monto", 
			T2."U_NumAsi" AS "L_Asiento", T2."U_codLet" AS "L_Letra", T2."U_VencDate" AS "L_VencLetra" 
		FROM "@ST_LT_ELLETRASCP" T2 
		WHERE T2."DocEntry" = :NumEmi
	);

	CREATE LOCAL TEMPORARY TABLE #FINAL("C_CardCode" NVARCHAR(20), "C_CardName" NVARCHAR(200), "C_FecEmi" TIMESTAMP, "C_CantLet" INTEGER, "C_NumCanje" INTEGER, "C_Dato1" NVARCHAR(200), "C_Dato2" NVARCHAR(200), "D_LineaDoc" INTEGER, "D_DocEntry" INTEGER, "D_TipoDoc" NVARCHAR(10), "D_Legal" NVARCHAR(20), "D_Monto" NUMERIC(19,6), "D_Moneda" NVARCHAR(10), "D_Fecha" TIMESTAMP, "D_MontoDoc" NUMERIC(19,6), "D_Dato1" NVARCHAR(20), "D_Dato2" NVARCHAR(20), "D_PorcCanje" INTEGER, "L_LineaLetra" INTEGER, "L_Dias" INTEGER, "L_Moneda" NVARCHAR(10), "L_Monto" NUMERIC(19,6), "L_Asiento" INTEGER, "L_Letra" NVARCHAR(20), "L_VencLet" TIMESTAMP, "L_Dato1"	NVARCHAR(20), "L_Dato2" NVARCHAR(20));
	
	SELECT (SELECT COUNT("D_LineaDoc") FROM #TEMPDOC) INTO Valor_01 FROM DUMMY;
	SELECT (SELECT COUNT("L_LineaLetra") FROM #TEMPLET) INTO Valor_02 FROM DUMMY;
	
	IF(:Valor_01 > :Valor_02) THEN
			INSERT INTO #FINAL("D_LineaDoc", "D_DocEntry", "D_TipoDoc", "D_Legal", "D_Monto", "D_Moneda", "D_Fecha", "D_MontoDoc","D_PorcCanje", "L_LineaLetra", "C_CardCode", "C_CardName", "C_FecEmi", "C_CantLet", "C_NumCanje", "C_Dato1")
			(
				SELECT T0.*, "D_LineaDoc", T1."U_CardCode", T1."U_CardName", T1."U_EmiDate", T1."U_CantLet", :NumEmi AS "NumEmi", T1."Address"
				FROM #TEMPDOC T0, #TEMPCAB T1
			);
			
			UPDATE #FINAL T0
			SET
				T0."L_Asiento" = T1."L_Asiento",
				T0."L_Dias"    = T1."L_Dias",
				T0."L_Letra"   = T1."L_Letra",
				T0."L_Moneda"  = T1."L_Moneda",
				T0."L_Monto"   = T1."L_Monto",
				T0."L_VencLet" = T1."L_VencLetra"
			FROM #FINAL T0
			INNER JOIN #TEMPLET T1 ON T0."L_LineaLetra" = T1."L_LineaLetra";
	ELSE
			INSERT INTO #FINAL("L_LineaLetra", "L_Dias", "L_Moneda", "L_Monto", "L_Asiento", "L_Letra", "L_VencLet"  ,"D_LineaDoc", "C_CardCode", "C_CardName", "C_FecEmi", "C_CantLet", "C_NumCanje", "C_Dato1")
			(
			 	SELECT T0.*, "L_LineaLetra", T1."U_CardCode", T1."U_CardName", T1."U_EmiDate", T1."U_CantLet", :NumEmi AS "NumEmi", T1."Address"
				FROM #TEMPLET T0 , #TEMPCAB T1
			);
			
			UPDATE #FINAL T0
			SET T0."D_DocEntry" = T1."D_DocEntry",
				T0."D_Legal" = T1."D_Legal",
				T0."D_Moneda" = T1."D_Moneda",
				T0."D_Monto" = T1."D_Monto",
				T0."D_TipoDoc" = T1."D_TipoDoc",
				T0."D_MontoDoc" = T1."D_MontoDoc",
				T0."D_PorcCanje" = T1."D_Porcentaje",
				T0."D_Fecha" = T1."D_Fecha" 
			FROM #FINAL T0 INNER JOIN #TEMPDOC T1 on T0."D_LineaDoc" = T1."D_LineaDoc";
	END IF;
	
	SELECT * FROM #FINAL;
	
	DROP TABLE #TEMPCAB;
	DROP TABLE #TEMPDOC;
	DROP TABLE #TEMPLET;
	DROP TABLE #FINAL;
END;