CREATE PROCEDURE STR_SP_LT_MostrarLetras
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
	IN p_Fecha TIMESTAMP,
	IN p_FechaFin TIMESTAMP,
	IN p_Moneda NVARCHAR(10),
	IN p_NomCli NVARCHAR(200),
	IN p_CodCli NVARCHAR(30)
)
-- exec SP_LT_MaestroLetra '20090911','SOL','NombreCliente','CodCliente'
AS
BEGIN
SELECT * 
FROM  
(
	SELECT 
		T1."U_LET_EST" AS "Estado",
		T0."ShortName" AS "CardCode",
		'Letras' AS "TipoDoc",
		T1."U_LET_SER" AS "Serie",
		T1."Ref2" "CodTipoDoc",
		T0."TransId" AS "NumInt",
		T1."U_LET_MON" AS "DocCur",
		(SELECT OC."CardName" FROM "OCRD" OC WHERE OC."CardCode" = T0."ShortName") AS "CardName",
		TO_VARCHAR(T1."DueDate", 'dd/mm/yyyy') AS "DueDate",
		TO_VARCHAR(T1."RefDate", 'dd/mm/yyyy') AS "DocDate",
		CASE WHEN (SELECT "MainCurncy" FROM "OADM") = T1."U_LET_MON" THEN "LocTotal" ELSE "FcTotal" END "Monto", 
		CASE WHEN (SELECT "MainCurncy" FROM "OADM") = T1."U_LET_MON" THEN T0."BalDueDeb" ELSE T0."BalFcDeb" END "Saldo",
		CASE   
			WHEN T0."BalDueDeb" = 0 THEN 'Pago Total'   
			WHEN T0."BalDueDeb" < "LocTotal" THEN 'Pago Parcial'   
			WHEN T0."BalDueDeb" = "LocTotal" THEN 'PendDiente'
		ELSE 'Pago en Exceso'
		END AS "EstSal",
		CASE   
			WHEN T1."U_LET_EST" = '002' THEN
			(
				SELECT DISTINCT 
					EL."DocEntry" 
				FROM "@ST_LT_ELLETRAS" EL 
				WHERE EL."U_codLet" = T1."Ref2"
				
				UNION 
				
				(
					SELECT DISTINCT 
	        			EL."DocEntry" 
					FROM "@ST_LT_RENEMI" EL
					WHERE EL."U_nroLet" = T1."Ref2"
				)
			)
			/*   
			WHEN T1."U_LET_EST" = '003' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_ELLETRAS] EL WHERE EL.U_codLet = T1.ref2 order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '004' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '005' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '006' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '007' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '008' THEN (SELECT TOP 1 EL.DocEntry FROM [@ST_LT_RENDET] EL   WHERE EL.U_numLet = T1.ref2 AND U_sel = 'Y' order by DocEntry Desc) 
			*/
			WHEN T1."U_LET_EST" = '003' THEN T2."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_ELLETRAS] EL WHERE EL.U_codLet = T1.ref2 order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '004' THEN T3."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '005' THEN T3."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '006' THEN T3."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '007' THEN T3."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_DEPDET] EL   WHERE EL.U_nroLet = T1.ref2 AND U_codPago IS NOT NULL AND U_nroIntDe IS NOT NULL order by DocEntry Desc) 
			WHEN T1."U_LET_EST" = '008' THEN T4."DocEntry" --(SELECT TOP 1 EL.DocEntry FROM [@ST_LT_RENDET] EL   WHERE EL.U_numLet = T1.ref2 AND U_sel = 'Y' order by DocEntry Desc) 
		ELSE '0'  
		END AS "NumOpe",
		CASE   
		WHEN T1."U_LET_EST" = '002' THEN 'Cartera'  
		WHEN T1."U_LET_EST" = '003' THEN 'Enviado Cobranza'  
		WHEN T1."U_LET_EST" = '004' THEN 'Cobranza Libre'  
		WHEN T1."U_LET_EST" = '005' THEN 'Cobranza Garantía'  
		WHEN T1."U_LET_EST" = '006' THEN 'Enviado Descuento'  
		WHEN T1."U_LET_EST" = '007' THEN 'Descuento'  
		WHEN T1."U_LET_EST" = '008' THEN 'Protesto'  
		ELSE '0'  
		END  AS "NomOpe"
	FROM "OJDT" T1 
	INNER JOIN "JDT1" T0 ON  T0."TransId" = T1."TransId" 
	LEFT  JOIN "@ST_LT_ELLETRAS" T2 ON T2."U_codLet" = T1."Ref2"
	LEFT  JOIN "@ST_LT_DEPDET" T3 ON T3."U_nroLet" = T1."Ref2" AND T3."U_codPago" IS NOT NULL AND T3."U_nroIntDe" IS NOT NULL
	LEFT  JOIN "@ST_LT_RENDET" T4 ON T4."U_numLet" = T1."Ref2" AND T4."U_sel" = 'Y'
	WHERE 
		(T0."DebCred" = 'D' AND T0."TransType" = 30  OR T0."BatchNum" > 0 )
	AND T0."ShortName" LIKE 'C%'  AND  T0."Closed" = 'N' 
	AND ((T0."SourceLine" <> -14  AND  T0."SourceLine" <> -6 ) OR T0."SourceLine" IS NULL ) 
	AND (T0."TransType" <> -2  OR  T1."DataSource" <> '-T') 
	AND T1."Ref2" LIKE 'LET%' 
	AND T1."U_LET_EST" NOT IN ('001', '000') 
	AND T1."U_LET_TIP" = '001'  
	AND (SELECT COUNT(*) FROM "OJDT" TX WHERE TX."TransType" = 24 AND TX."Ref2" = 'ANL-LT' AND TX."Memo" = T1."Ref2" AND TX."U_LET_EST" = T1."U_LET_EST" AND TX."U_LET_SER" = T1."U_LET_SER") = 0  
	AND T1."U_LET_EST" = 
	(  
		SELECT MS3."U_estAct"  
		FROM "@ST_LT_MSTLET" MS3   
		WHERE MS3."Code" =
		(
			SELECT 
				MAX(TO_INTEGER(MS2."Code")) 
			FROM "@ST_LT_MSTLET" MS2 
			WHERE  MS2."U_cdStLet" = T1."Ref2" AND MS2."U_tipo" = '001' AND MS2."U_serie" = T1."U_LET_SER"
		)  
	)
) T   
WHERE  
	"DocCur" LIKE :p_Moneda 
AND "CardCode" LIKE :p_CodCli  
AND "CardName" LIKE :p_NomCli  
AND "DocDate" BETWEEN COALESCE(:p_Fecha, "DocDate") AND COALESCE(:p_FechaFin, "DocDate")  
ORDER BY "CodTipoDoc";
END;