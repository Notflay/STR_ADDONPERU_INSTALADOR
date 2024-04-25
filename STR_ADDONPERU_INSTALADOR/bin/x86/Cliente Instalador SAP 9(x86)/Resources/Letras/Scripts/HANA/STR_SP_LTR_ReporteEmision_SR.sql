CREATE PROCEDURE STR_SP_LTR_ReporteEmision_SR
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
	IN p_DocEntry INTEGER
)
As
BEGIN
	SELECT 
		T0."U_codLet",
		T0."U_SerLet",
		T0."U_CorrLet",
		T0."U_diaLet",
		T0."U_VencDate",
		T0."U_DocCurr",
		T0."U_ImpML",
		T0."U_ImpME",
		(T0."U_ImpME" * (CASE T0."U_DocCurr" WHEN 'SOL' THEN 1 ELSE (SELECT DISTINCT R1."Rate" FROM "ORTT" R1 WHERE R1."Currency" = T0."U_DocCurr" AND R1."RateDate" = T1."RefDate") END)) AS "ImpMEML",
		T0."U_NumAsi",
		CASE T1."U_LET_EST" --(SELECT DISTINCT A1."U_LET_EST" FROM "JDT1" A0 INNER JOIN "OJDT" A1 ON A0."TransId" = A1."TransId" WHERE A0."Ref2" = T0."U_codLet" AND (A0."BalDueDeb" + A0."BalDueCred") > 0)
			WHEN '000' THEN 'Anulada'
			WHEN '001' THEN 'Emitida'
			WHEN '002' THEN 'Cartera'
			WHEN '003' THEN 'Enviado a Cobranza'
			WHEN '004' THEN 'Cobranza Libre'
			WHEN '005' THEN 'Cobranza Garantia'
			WHEN '006' THEN 'Enviado a Descuento'
			WHEN '007' THEN 'Descuento'
			WHEN '008' THEN 'Protesto' 
			ELSE 'Pagado'
		END AS "U_LtEstLet",
		T0."U_glosa"
	FROM "@ST_LT_ELLETRAS" T0
	LEFT JOIN "OJDT" T1 ON T1."TransId" = T0."U_NumAsi"
	LEFT JOIN "JDT1" T2 ON T2."Ref2" = T0."U_codLet" AND (T2."BalDueDeb" + T2."BalDueCred") > 0
	WHERE T0."DocEntry" = :p_DocEntry;

END;
