CREATE PROCEDURE SP_BPP_GNRTXT_BBVA_CAB
(
  @DOCENTRY INT =20
)
AS


BEGIN
	
select 

'750' as 'Tipo Registro',

CASE WHEN	LEFT(LTRIM(RTRIM(T9.UsrNumber1)),1) ='C' OR LEFT(LTRIM(RTRIM(T9.UsrNumber1)),1) = 'M' 
	 THEN
			LEFT(LTRIM(RTRIM(substring(REPLACE(T7.U_BPP_CUENBAN,'-',''), 1, 4)--+'00'
			+substring(REPLACE(T7.U_BPP_CUENBAN,'-',''),5,4)+'00'
			+substring(REPLACE(T7.U_BPP_CUENBAN,'-',''), 9, 22 )  )),22)
	 ELSE
			LEFT(LTRIM(RTRIM(REPLACE(T7.U_BPP_CUENBAN,'-',''))),22) + REPLICATE ('', 22 - LEN(LEFT(LTRIM(RTRIM(REPLACE(T7.U_BPP_CUENBAN,'-',''))),22))) 

END AS 'Cuenta Cargo',

CASE T7.U_BPP_MONEDA WHEN 'SOL' THEN 'PEN' ELSE 'USD' END AS 'Moneda',

CASE T7.U_BPP_MONEDA WHEN 'SOL' THEN 

		RIGHT('000000000000' + SUBSTRING(CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(15)),1,CHARINDEX('.',CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(15)))-1) +
			SUBSTRING(CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(30)) ,(CHARINDEX('.',CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(30)))+1),2),15) 
	ELSE
		RIGHT('000000000000' + SUBSTRING(CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(15)),1,CHARINDEX('.',CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(15)))-1) +
		SUBSTRING(CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(30)) ,(CHARINDEX('.',CAST(SUM(T8.U_BPP_MONTOPAG) AS VARCHAR(30)))+1),2),15)
	END AS 'ImportCargar',

'H' as 'Tipo Proceso',
CONVERT(VARCHAR(8),T7."U_BPP_FECCREA",112) as 'Fecha Proceso',
'B' as 'Hora Proceso',

'PAGOPROVEEDORESBBVA' + REPLICATE(' ', 7) AS 'Referencia',

REPLICATE ('0',7 -LEN(  REPLACE( CAST((COUNT(*)) AS INT),'.','')))
+''+ REPLACE( CAST( (COUNT(*)) AS INT),'.','')  
AS 'Total Registros',

'S' as 'Valida',

REPLICATE('0', 15) 	as 'Valor de Control',
REPLICATE('0', 3) 	as 'Indicador Proceso',
REPLICATE(' ', 30) 	as 'Descrip. Cod. Retorno',
REPLICATE(' ', 20) 	as 'Filler', 
'P' as 'P'

INTO #RC

FROM "@BPP_PAGM_CAB" T7
 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7.DocEntry = T8.DocEntry
 INNER JOIN DSC1 T9 ON T7.U_BPP_CUENBAN = T9.Account
 
 WHERE T7.U_BPP_ESTADO != 'Cancelado' and T7.DocEntry = @DOCENTRY
 
 group by  T7.U_BPP_MONEDA, T9.UsrNumber1, T7.U_BPP_CUENBAN, T7."U_BPP_FECCREA"

 SELECT  

"Tipo Registro"				+	--1
LEFT("Cuenta Cargo",20)		+	--2
"Moneda"					+	--3
RIGHT("ImportCargar",15)	+	--4
"Tipo Proceso"				+	--5
"Fecha Proceso"				+	--6
"Hora Proceso"				+	--7
LEFT("Referencia",25)		+	--8
RIGHT("Total Registros",6)	+	--9
"Valida"					+	--10
--LEFT("Valor de Control",15) +	--11
--"Indicador Proceso"			+	--12
--LEFT("Descrip. Cod. Retorno",30) +	--13
--LEFT("Filler",20)		+		--					||	--14*/
--char(9)--'@'-- "P"
'                                                                    @'--Espacios

AS "PMBBVA_C"
FROM #RC;
 
 END