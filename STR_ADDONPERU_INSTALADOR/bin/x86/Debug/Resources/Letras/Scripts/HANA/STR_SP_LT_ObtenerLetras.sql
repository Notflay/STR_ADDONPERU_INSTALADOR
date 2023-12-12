CREATE PROCEDURE STR_SP_LT_ObtenerLetras
(
 pv_Moneda VARCHAR(3),
 pv_Cartera VARCHAR(3),
 pv_ShortName VARCHAR(20),
 pv_IndiceColumna VARCHAR(1),
 pv_Ordenamiento VARCHAR(5)
)
AS
vv_sql VARCHAR(5000);
vv_condicion VARCHAR(100);

BEGIN

vv_condicion := '';

SELECT (CASE WHEN :pv_Moneda <> '' THEN ' AND T1."U_LET_MON" = ''' || :pv_Moneda || '''' ELSE '' END) 
	|| (CASE WHEN :pv_ShortName <> '' THEN ' AND T0."ShortName" = ''' || :pv_ShortName || '''' ELSE '' END)
INTO vv_condicion FROM DUMMY;

vv_sql := '
		SELECT "uCheck", "NumInt",  "NumLetra", "CodigoSN", "NombreSN", "Moneda", "Importe", "FecEmi", "FecVen",
		  		"LineaID", "Percepcion",  "FecAce", "FcTotal", "LocTotal", "BalDueDeb", "BalDueCred", "NumUnico","Glosa"
		  	FROM 
		 		(    
					 SELECT 
					 		''N''		 AS "uCheck"
					 		,T0."TransId" AS "NumInt"
					  		,T1."Ref2" AS "NumLetra"
					  		,T0."ShortName" AS "CodigoSN"
					  		,T2."CardName" AS "NombreSN" 
					  		,T1."U_LET_MON" AS "Moneda"
					 		,CASE WHEN (SELECT "MainCurncy" FROM OADM) = T1."U_LET_MON" THEN "BalDueDeb" ELSE "BalFcDeb" END "Importe"
					 		,T1."TaxDate" AS "FecEmi"
					 		,T0."DueDate" AS "FecVen"
					 		,T0."Line_ID" AS "LineaID"
					 		,IFNULL(T3."U_MntPrc",T4."U_MntPrc") AS "Percepcion"
					 		,T1."RefDate" AS "FecAce"
					 		,"FcTotal"
					 		,"LocTotal"
					 		,"BalDueDeb"
					 		,"BalDueCred"
					 		,LPAD('' '', 10) AS "NumUnico"
					 		,T1."U_LET_GLS" AS "Glosa"
					 		FROM  JDT1 T0 INNER JOIN OJDT T1 ON T0."TransId" = T1."TransId" 
					 					  INNER JOIN OCRD T2 ON T0."ShortName" = T2."CardCode"
					 					  LEFT JOIN "@ST_LT_ELLETRAS" T3 ON T3."U_codLet" = T1."Ref2"
					 					  LEFT JOIN "@ST_LT_RENEMI" T4 ON T4."U_nroLet" = T1."Ref2"
					 WHERE (T0."DebCred" = ''D'' AND T0."TransType" = 30  OR T0."BatchNum" > 0 ) 
					 		AND T0."Closed" = ''N''  
					 		AND (T0."BalDueCred" <> 0 OR T0."BalDueDeb" <> 0 )
					 		AND ((T0."SourceLine" <> -14 AND T0."SourceLine" <> -6 ) OR T0."SourceLine" IS NULL )
					 		AND (T0."TransType" <> -2 OR T1."DataSource" <> ''-T'')
					 		AND LEFT(T1."Ref2",3) = ''LET'' AND T1."U_LET_EST" = ''' || :pv_Cartera || '''' 
					 		|| :vv_condicion || '
				 ) T  ORDER BY ' || :pv_IndiceColumna ||' '|| :pv_Ordenamiento;

EXECUTE IMMEDIATE (:vv_sql);
END;

