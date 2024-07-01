create PROCEDURE SP_BPP_GNRTXT_BBVA_CAB
(
  IN DOCENTRY INT
)
AS

BEGIN
	
SELECT 

"Tipo Registro"				||	--1
LEFT("Cuenta Cargo",20)		||	--2
"Moneda"					||	--3
RIGHT("ImportCargar",15)	||	--4
"Tipo Proceso"				||	--5
"Fecha Proceso"				||	--6
"Hora Proceso"				||	--7
LEFT("Referencia",24)		||	--8
RIGHT("Total Registros",6)	||	--9
"Valida"					||	--10
LEFT("Valor de Control",14) ||	--11
"Indicador Proceso"			||	--12
LEFT("Descrip. Cod. Retorno",30) ||	--13
LEFT("Filler",20)--					||	--14
-- "P"

AS "PMBBVA_C"
FROM ( 	
	

select 

'750' as "Tipo Registro",

CASE WHEN	LEFT(LTRIM(RTRIM(T9."UsrNumber1")),1) ='C' OR LEFT(LTRIM(RTRIM(T9."UsrNumber1")),1) = 'M' 
	 THEN 
			LEFT(LTRIM(RTRIM(REPLACE(T7."U_BPP_CUENBAN",'-',''))),8) 
			||SUBSTRING(REPLACE(T7."U_BPP_CUENBAN",'-',''),19,2)||SUBSTRING(REPLACE(T7."U_BPP_CUENBAN",'-',''),9,10)
			|| REPLICATE (' ', 19 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(T7."U_BPP_CUENBAN",'-',''))),18)))

	 ELSE 
			LEFT(LTRIM(RTRIM(REPLACE(T7."U_BPP_CUENBAN",'-',''))),20) 
			|| REPLICATE (' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(T7."U_BPP_CUENBAN",'-',''))),20)))
			
END AS "Cuenta Cargo",

CASE T7."U_BPP_MONEDA" WHEN 'SOL' THEN 'PEN' ELSE 'USD' END AS "Moneda",

CASE T7."U_BPP_MONEDA" WHEN 'SOL' THEN 
REPLICATE ('0',15 -LENGTH(  REPLACE( CAST(sum (ROUND((T8."U_BPP_MONTOPAG"),2)) AS NUMERIC (15,2)),'.','')))||''|| REPLACE( CAST(sum(ROUND((T8."U_BPP_MONTOPAG"),2)) AS NUMERIC (15,2)),'.','') 
ELSE
REPLICATE ('0',15 -LENGTH(  REPLACE( CAST(sum (ROUND((T8."U_BPP_MONTOPAG"),2)) AS NUMERIC (15,2)),'.','')))||''|| REPLACE( CAST(sum (ROUND((T8."U_BPP_MONTOPAG"),2)) AS NUMERIC (15,2)),'.','') 
END AS "ImportCargar",

'H' as "Tipo Proceso",

REPLICATE(' ',8) as "Fecha Proceso",
'B' as "Hora Proceso",

'PAGOPROVEEDORESBBVA' || LPAD(' ', 6) AS "Referencia",

REPLICATE ('0',7 -LENGTH(  REPLACE( CAST((COUNT(*)) AS INT),'.','')))
||''|| REPLACE( CAST( (COUNT(*)) AS INT),'.','')  
AS "Total Registros",

'S' as "Valida",

REPLICATE('0', 15) 	as "Valor de Control",
REPLICATE('0', 3) 	as "Indicador Proceso",
REPLICATE(' ', 29) 	as "Descrip. Cod. Retorno",
REPLICATE(' ', 20) 	as "Filler", 
'P' as "P"

FROM "@BPP_PAGM_CAB" T7
 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
 INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"

 
 WHERE T7."U_BPP_ESTADO" != 'Cancelado' and 
 T7."DocEntry" = :DOCENTRY
 
 group by  T7."U_BPP_MONEDA", T9."UsrNumber1", T7."U_BPP_CUENBAN"
 
 ) RC;

 end;