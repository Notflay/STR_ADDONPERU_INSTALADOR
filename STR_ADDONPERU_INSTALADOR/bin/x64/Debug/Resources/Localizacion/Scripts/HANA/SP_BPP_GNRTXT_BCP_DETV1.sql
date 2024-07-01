CREATE PROCEDURE SP_BPP_GNRTXT_BCP_DETV1
(
	 IN DOCENTRY INT
)
AS
	codigopago VARCHAR(10);
	checksum Decimal;
BEGIN
SELECT
 
"TipRegistr"				||	--1
"TipoProducto"				||	--2
"NroCtaAbono"				||	--3
RPAD("RazonSocBenef",40)	||	--4
"Moneda"					||	--5
"ImportAbonar"				||	--6
"TipoDocIdentidad"			||	--7
RPAD("NroDocIdentidad",12)	||	--8	
"TipoDocPagar"				||	--9
LPAD("NroDocumento",10)		||	--10
"TipoAbono"					||	--11
RPAD("RefAdicional",40)		||	--12
"NotaAbono"					||	--13
"Delivery"			 	    ||	--14
"ValidaRuc"					||	--15
"Direccion"					||	--16
"Distrito"					||	--17
"Provincia"					||	--18
"Departamento"				||	--19
"Contacto"					||
'@'
 
 
AS "PMBCP_D"
FROM (
SELECT Distinct
 
/*' 2' AS "TipRegistr",
 
CASE WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")),1) = 'I' THEN 'B'
ELSE 
LEFT(LTRIM(RTRIM(T1."BankCtlKey")),1) 
END AS "TipoProducto",
 
CASE T1."BankCtlKey" WHEN 'A' THEN 
	LEFT(LTRIM(RTRIM(REPLACE(T1."DflAccount",'-',''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))),20)),' ')
ELSE
	LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 1, 3) || '0' || 
	SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 4, LENGTH(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))))),20) || 
	LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 1, 3) || '0' || 
	SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 4, LENGTH(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))) )),20)), ' ')
END  AS "NroCtaAbono",
 
LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(T1."CardName",'Ñ','N'),',',' '),'_',' '),'&',' '))) AS "RazonSocBenef",
 
CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN 'S/' ELSE 'US' END AS "Moneda",
CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN
	RIGHT('00000000000000' || SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
			SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15) 
	ELSE
		RIGHT('00000000000000' || SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
		SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15)
END  AS "ImportAbonar",
 
CASE 
	WHEN T1."U_BPP_BPTD" = 1 OR T1."U_BPP_BPTD" = 'DNI' THEN 'DNI'
	WHEN T1."U_BPP_BPTD" = 6 OR T1."U_BPP_BPTD" = 'RUC' THEN 'RUC'
	WHEN T1."U_BPP_BPTD" = 4 OR T1."U_BPP_BPTD" = 'CE' THEN  LEFT('CE',2) || ' ' ELSE LPAD(' ', 3, ' ')
END AS "TipoDocIdentidad",
 
LTRIM(RTRIM(T1."LicTradNum")) AS "NroDocIdentidad",
 
'F' AS "TipoDocPagar",
CASE WHEN IFNULL((SELECT TO_VARCHAR(RIGHT(OP."U_BPP_MDSD",2) || LPAD('0', 8 - LENGTH(OP."U_BPP_MDCD"), '0') || OP."U_BPP_MDCD")
FROM  OPCH OP  WHERE OP."DocEntry" = T10."DocEntry"),'')='' THEN 
(SELECT substring(OP."Ref3",LOCATE(OP."Ref3",'-')-2,2)||RIGHT(('00000000'||RIGHT(OP."Ref3",LENGTH(OP."Ref3")-LOCATE(OP."Ref3",'-'))),8)
FROM  OJDT OP  WHERE OP."TransId" = T10."DocEntry")
ELSE  
(SELECT TO_VARCHAR(RIGHT(OP."U_BPP_MDSD",2) || LPAD('0', 8 - LENGTH(OP."U_BPP_MDCD"), '0') || OP."U_BPP_MDCD")
FROM  OPCH OP  WHERE OP."DocEntry" = T10."DocEntry")
END AS "NroDocumento",
'1' AS "TipoAbono",
'F' || (SELECT OP."U_BPP_MDTD" || '-' || OP."U_BPP_MDSD"  || '-' || OP."U_BPP_MDCD" 
		FROM OPCH OP WHERE OP."DocEntry" = T10."DocEntry") AS "RefAdicional",
'0' AS "NotaAbono",
'0' AS "Delivery",
 
'1' AS "ValidaRuc",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."Address"),''))),40) || LPAD(' ', 40 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."Address"),''))),40)), ' ') AS "Direccion",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."City"),''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."City"),''))),20)), ' ') AS "Distrito",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."County"),''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."County"),''))),20)), ' ') AS "Provincia",
 
LEFT(IFNULL(T2."Name",''),20) || LPAD(' ', 20 - LENGTH(LEFT(IFNULL(T2."Name",''),20)), ' ') AS "Departamento",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."CntctPrsn"),''))),40) || LPAD(' ', 40 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."CntctPrsn"),''))),40)), ' ') AS "Contacto"
*/
 
' 2' AS "TipRegistr",
 
IFNULL(CASE WHEN LEFT(LTRIM(RTRIM(T1."BankCtlKey")),1) = 'I' THEN 'B'
ELSE 
LEFT(LTRIM(RTRIM(T1."BankCtlKey")),1) 
END, '') AS "TipoProducto",
 
IFNULL(CASE T1."BankCtlKey" WHEN 'A' THEN 
	LEFT(LTRIM(RTRIM(REPLACE(T1."DflAccount",'-',''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))),20)),' ')
ELSE
	LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 1, 3) || '0' || 
	SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 4, LENGTH(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))))),20) || 
	LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 1, 3) || '0' || 
	SUBSTRING(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''), 4, LENGTH(REPLACE(REPLACE(T1."DflAccount",'-',''),' ',''))) )),20)), ' ')
END, '')  AS "NroCtaAbono",
 
IFNULL(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(T1."CardName",'Ñ','N'),',',' '),'_',' '),'&',' '))),'') AS "RazonSocBenef",
 
IFNULL(CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN 'S/' ELSE 'US' END, '') AS "Moneda",
IFNULL(CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN
	RIGHT('00000000000000' || SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
			SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15) 
	ELSE
		RIGHT('00000000000000' || SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),1,LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(15)),'.')-1) ||
		SUBSTRING(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)) ,(LOCATE(CAST((T8."U_BPP_MONTOPAG") AS VARCHAR(30)),'.')+1),2),15)
END, '')  AS "ImportAbonar",
 
IFNULL(CASE 
	WHEN T1."U_BPP_BPTD" = 1 OR T1."U_BPP_BPTD" = 'DNI' THEN 'DNI'
	WHEN T1."U_BPP_BPTD" = 6 OR T1."U_BPP_BPTD" = 'RUC' THEN 'RUC'
	WHEN T1."U_BPP_BPTD" = 4 OR T1."U_BPP_BPTD" = 'CE' THEN  LEFT('CE',2) || ' ' ELSE LPAD(' ', 3, ' ')
END,'') AS "TipoDocIdentidad",
 
IFNULL(LTRIM(RTRIM(T1."LicTradNum")), '') AS "NroDocIdentidad",
 
'F' AS "TipoDocPagar",
CASE WHEN IFNULL((SELECT TO_VARCHAR(RIGHT(OP."U_BPP_MDSD",2) || LPAD('0', 8 - LENGTH(OP."U_BPP_MDCD"), '0') || OP."U_BPP_MDCD")
FROM  OPCH OP  WHERE OP."DocEntry" = T10."DocEntry"),'')='' THEN 
(SELECT substring(IFNULL(OP."Ref3",''),LOCATE(IFNULL(OP."Ref3",''),'-')-2,2)||RIGHT(('00000000'||RIGHT(IFNULL(OP."Ref3",''),LENGTH(IFNULL(OP."Ref3", ''))-LOCATE(IFNULL(OP."Ref3", ''),'-'))),8)
FROM  OJDT OP  WHERE OP."TransId" = T10."DocEntry")
ELSE  
(SELECT TO_VARCHAR(RIGHT(IFNULL(OP."U_BPP_MDSD",''),2) || LPAD('0', 8 - LENGTH(IFNULL(OP."U_BPP_MDCD",'')), '0') || IFNULL(OP."U_BPP_MDCD",''))
FROM  OPCH OP  WHERE OP."DocEntry" = T10."DocEntry")
END AS "NroDocumento",
'1' AS "TipoAbono",
'F' || (SELECT IFNULL(OP."U_BPP_MDTD",'') || '-' || IFNULL(OP."U_BPP_MDSD",'')  || '-' || IFNULL(OP."U_BPP_MDCD" , '')
		FROM OPCH OP WHERE OP."DocEntry" = T10."DocEntry") AS "RefAdicional",
'0' AS "NotaAbono",
'0' AS "Delivery",
 
'1' AS "ValidaRuc",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."Address"),''))),40) || LPAD(' ', 40 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."Address"),''))),40)), ' ') AS "Direccion",
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."City"),''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."City"),''))),20)), ' ') AS "Distrito",
 
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."County"),''))),20) || LPAD(' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."County"),''))),20)), ' ') AS "Provincia",
 
LEFT(IFNULL(
--T2."Name"
(SELECT  MAX(TX."Name")
from "OCST" TX 
INNER JOIN "CRD1" TY ON (TX."Code" = TY."State" AND TX."Country" = 'PE')
where TY."CardCode" = T10."CardCode")
 
,''),20) || LPAD(' ', 20 - LENGTH(LEFT(IFNULL(
--T2."Name"
(SELECT  MAX(TX."Name")
from "OCST" TX 
INNER JOIN "CRD1" TY ON (TX."Code" = TY."State" AND TX."Country" = 'PE')
where TY."CardCode" = T10."CardCode")
,''),20)), ' ') AS "Departamento",
 
LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."CntctPrsn"),''))),40) 
|| LPAD(' ', 40 - LENGTH(LEFT(LTRIM(RTRIM(IFNULL(UPPER(T1."CntctPrsn"),''))),40)), ' ') AS "Contacto"
 
FROM "@BPP_PAGM_CAB" T7
INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
--INNER JOIN "CRD1" T3 ON T1."CardCode" = T3."CardCode"
--INNER JOIN "OCST" T2 ON T3."State" = T2."Code" and T2."Country" != 'CL'
WHERE T7."U_BPP_ESTADO" != 'Cancelado' and  T7."DocEntry" = :DOCENTRY
) RD;
END;