CREATE PROCEDURE SP_BPP_GNRTXT_BCP_CAB
(
 IN DOCENTRY INT
)
AS
	checksum DECIMAL;
	
BEGIN

	
SELECT sum(P."CtaProv") + P."CtaAbono" INTO checksum FROM
	(
		SELECT 
			CASE WHEN T10."BankCode"='001' THEN 
				SUM(TO_DECIMAL(SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''),4,
				LENGTH(REPLACE(REPLACE(T1."DflAccount",'-',''),' ','')))))
			ELSE 
			 	SUM(TO_DECIMAL(RIGHT(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''),10)))
			END AS "CtaProv",
			SUM(DISTINCT (TO_DECIMAL( SUBSTRING(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''),4,
			LENGTH(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ','')))))) AS "CtaAbono"
		
		 FROM "@BPP_PAGM_CAB" T7
		 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
		 INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"	
		 INNER JOIN "OCRB" T10 ON T1."CardCode" = T8."U_BPP_CODPROV" and T10."Account" = T8."U_BPP_CUENBAN"
		 where T7."DocEntry" = :DOCENTRY
		
		GROUP BY T10."BankCode"
	) P GROUP BY P."CtaAbono";
	
	
SELECT 

"PlanNueva"					||	--1
"TipRegistro"				||	--2
"TipPagMasiv"				||	--3
"TipProduct"				||	--4
"NroCtaCorrient"			||	--5
"Moneda"					||	--6
"ImportCargar"				||	--7
"FechProces"				||	--8
"Referencia"				||	--9
"TControlChekS"				||	--10
"TotRegAbon"				||	--11
"SubTPagoMas"				||	--12
"IdentiDivicen"			    ||	--13
"IndNotaCargo"				--||	--14


AS "PMBCP_C"

FROM ( 		
	
	
	 SELECT distinct
	'#' AS "PlanNueva",
	'1' AS "TipRegistro",
	'P' AS "TipPagMasiv",
	 
	LEFT(LTRIM(RTRIM(T9."UsrNumber1")),1) AS "TipProduct",

	CASE WHEN LEFT(LTRIM(RTRIM(T9."UsrNumber1")),1) ='C' OR LEFT(LTRIM(RTRIM(T9."UsrNumber1")),1) = 'M' THEN
		LEFT(LTRIM(RTRIM(substring(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''), 1, 3) || '0' || substring(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''), 4, LENGTH(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''))))),14) || LPAD (' ',6,' ')
	ELSE
		LEFT(LTRIM(RTRIM(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(REPLACE(T7."U_BPP_CUENBAN",'-',''),' ',''))),20))) 
	END AS "NroCtaCorrient",
	
	CASE T7."U_BPP_MONEDA" WHEN 'SOL' THEN 'S/' ELSE 'US' END AS "Moneda",

	CASE T7."U_BPP_MONEDA" WHEN 'SOL' THEN 
	--(LPAD ('0', 15 - LENGTH(
	-- SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)),1, LOCATE(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)), '.')-1)
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)),(LOCATE(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)), '.')+1),2)),'0')
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)),1, LOCATE(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)), '.')-1)
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)),(LOCATE(CAST(SUM(ROUND(T5."BfDcntSum",2)) AS VARCHAR(15)),'.')+1),2))
	--ELSE 
	--(LPAD ('0', 15 - LENGTH(
	-- SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),1,LOCATE(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),'.')-1)
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),(LOCATE(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),'.')+1),2)),'0')
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),1,LOCATE(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),'.')-1)
	--|| SUBSTRING(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),(LOCATE(CAST(SUM(ROUND(T5."BfDcntSumF",2)) AS VARCHAR(15)),'.')+1),2))
		RIGHT('000000000000' || SUBSTRING(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
			SUBSTRING(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15) 
	ELSE
		RIGHT('000000000000' || SUBSTRING(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
		SUBSTRING(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST(SUM(T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15)
	END AS "ImportCargar",
    
	TO_VARCHAR(TO_DATE(T7."U_BPP_FECCREA"),'ddMMyyyy') AS "FechProces",
	
	'PAGOPROVEEDORESBCP  ' AS "Referencia",
    LPAD ('0', 15 - LENGTH(LEFT(LTRIM(RTRIM(:checksum)),15)), '0') || LEFT(LTRIM(RTRIM(:checksum)),15) AS "TControlChekS",
	REPLICATE ('0',5 -LENGTH(  REPLACE( CAST((COUNT(T8."DocEntry")) AS INT),'.','')))
	||''|| REPLACE( CAST( (COUNT(T8."DocEntry")) AS INT),'.','')   AS "TotRegAbon",
	--CAST(COUNT()AS VARCHAR(6)) 
	'0' AS "SubTPagoMas",
	LPAD (' ', 15, ' ' ) AS "IdentiDivicen",
	'0' AS "IndNotaCargo" 
	FROM 
	"@BPP_PAGM_CAB" T7
	INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
	INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
	INNER JOIN "DSC1" T9 ON T7."U_BPP_CUENBAN" = T9."Account"

	WHERE T7."U_BPP_ESTADO" != 'Cancelado' and  T7."DocEntry" = :DOCENTRY

	GROUP BY T7."U_BPP_MONEDA", T9."UsrNumber1",T7."U_BPP_CUENBAN",	T7."U_BPP_FECCREA"
	 
)RC ;
	
END;