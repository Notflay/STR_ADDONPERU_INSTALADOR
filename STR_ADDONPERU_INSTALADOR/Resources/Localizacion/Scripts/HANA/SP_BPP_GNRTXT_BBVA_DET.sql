CREATE PROCEDURE SP_BPP_GNRTXT_BBVA_DET

(
 IN DOCENTRY INT
)

AS

BEGIN

SELECT 

"Tipo Registro"				||		--1
"DOI TIPO"		            ||		--2
"DOI NUMERO"			    ||		--3
"Tipo Abono"				||		--4
"Cuenta a Abonar"			||		--5
"Nombre Beneficiario"		||		--6
"ImportAbonar"				||		--7
"Tipo Recibo"			    ||		--8
"NroDocumento"				||		--9	
"Abono Grupal"              ||
"Referencia"		        ||		--10
"Vacio"
--"Referencia"				||		--11
--"Indicador de Aviso"		||		--12
--"Medio Aviso"				||		--13
--"Persona Contacto"			--||		--14
--"Indicador Proceso"			||		--15
--"Desc. Cod. Retorno"		||		--16
--"Filler"					||		--17
--"D"
 
AS "PMBBVA_D"
FROM (

SELECT
 
'002' AS "Tipo Registro",

case when T1."U_BPP_BPTD" = '1' THEN 'L'
	 when T1."U_BPP_BPTD" = '6' THEN 'R'
	 when T1."U_BPP_BPTD" = '4' THEN 'E'
	 when T1."U_BPP_BPTD" = '7' THEN 'P'
	 when T1."U_BPP_BPTD" = '0' THEN 'M'
end as "DOI TIPO",

RPAD(T1."LicTradNum", 12, ' ') AS "DOI NUMERO",

T1."BankCtlKey" as "Tipo Abono",

 --"DflAccount" || REPLICATE(' ',20-LENGTH("DflAccount")) as "Cuenta a Abonar",

CASE
WHEN  T1."BankCtlKey" = 'P' THEN (LEFT(T1."DflAccount", 8) || '00' || RIGHT(T1."DflAccount", 10))
WHEN T1."BankCtlKey" IN ('B','I') THEN LEFT(T1."DflAccount", 20)
END as "Cuenta a Abonar",

LEFT(T1."CardName",40) || LPAD(' ',40-LENGTH(LEFT(T1."CardName",40))) as "Nombre Beneficiario",

/*CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN
      (REPLICATE ('0', 15 - LENGTH(
                                    SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),1,LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)-1)
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),(LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),3)+1),2)))
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),1,LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)-1)
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),(LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)+1),2))
ELSE
      (REPLICATE ('0', 15 - LENGTH(
                                    SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),1,LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)-1)
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),(LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),3)+1),2)))
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),1,LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)-1)
                                 || SUBSTRING(CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),(LOCATE('.',CAST((ROUND(T8."U_BPP_MONTOPAG",2)) AS VARCHAR(15)),2)+1),2))
 
END  AS "ImportAbonar",*/

CASE T8."U_BPP_MONEDA"
                WHEN 'SOL' THEN 
                    REPLICATE('0', 15 - LENGTH(REPLACE(CAST(ROUND(T8."U_BPP_MONTOPAG", 2) AS NUMERIC(15, 2)), '.', ''))) || '' || REPLACE(CAST(ROUND(T8."U_BPP_MONTOPAG", 2) AS NUMERIC(15, 2)), '.', '')
                ELSE
                    REPLICATE('0', 15 - LENGTH(REPLACE(CAST(ROUND(T8."U_BPP_MONTOPAG", 2) AS NUMERIC(15, 2)), '.', ''))) || '' || REPLACE(CAST(ROUND(T8."U_BPP_MONTOPAG", 2) AS NUMERIC(15, 2)), '.', '')
            END AS "ImportAbonar",


CASE 
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'F' THEN 'F'
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'B' THEN 'B'
            WHEN LEFT(T8."U_BPP_TIPODOC", 1) = 'N' THEN 'N'
END as "Tipo Recibo",



 (SELECT
    CAST(OP."U_BPP_MDSD" || OP."U_BPP_MDCD" || LPAD (' ',9-LENGTH(OP."U_BPP_MDCD")) AS NVARCHAR(12))
   FROM  OPCH OP WHERE OP."DocEntry" = T10."DocEntry") AS "NroDocumento",
   
 'N' as "Abono Grupal",
 
 --'PAGOPROVEEDORESBBVA' || LPAD(' ', 91) AS "Referencia",
   ' ' ||LPAD(' ', 91) AS "Referencia",
   CHAR(10) || LPAD('0', 32, '0') AS "Vacio"


 --LPAD('0',30) as "Vacio"

--'PAGOPROVEEDORESBBVA' || LPAD(' ', 21)AS "Referencia",

--REPLICATE('0', 1) 		as "Indicador de Aviso",
--REPLICATE('0', 50) 		as "Medio Aviso",
--REPLICATE('0', 30) 		as "Persona Contacto"
/*REPLICATE('0', 2) 		as "Indicador Proceso",
REPLICATE('0', 30) 		as "Desc. Cod. Retorno",
REPLICATE(' ', 18) 		as "Filler",
'D' as "D"*/

 FROM "@BPP_PAGM_CAB" T7
 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
 INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
 INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
 
 WHERE T7."U_BPP_ESTADO" != 'Cancelado' and T8."DocEntry" = :DOCENTRY
 
 ) RD;
 
 END;