CREATE PROCEDURE SP_BPP_GNRTXT_BBVA_DET

(
 IN DOCENTRY INT
)

AS

BEGIN

SELECT 

"Tipo Registro"				||		--1
"Tipo Doc. Identidad"		||		--2
"NroDocIdentidad"			||		--3
"Tipo Abono"				||		--4
"Cuenta a Abonar"			||		--5
"Nombre Beneficiario"		||		--6
"ImportAbonar"				||		--7
"Tipo Documento"			||		--8
"NroDocumento"				||		--9	
"Abono Grupal"				||		--10
"Referencia"				||		--11
"Indicador de Aviso"		||		--12
"Medio Aviso"				||		--13
"Persona Contacto"			||		--14
"Indicador Proceso"			||		--15
"Desc. Cod. Retorno"		||		--16
"Filler"					||		--17
"D"
 
AS "PMBBVA_D"
FROM (

SELECT 
'002' AS "Tipo Registro",

case when T1."U_BPP_BPTD" = '1' THEN 'L'
	 when T1."U_BPP_BPTD" = '6' THEN 'R'
	 when T1."U_BPP_BPTD" = '4' THEN 'E'
	 when T1."U_BPP_BPTD" = '7' THEN 'P'
	 when T1."U_BPP_BPTD" = '0' THEN 'M'
end as "Tipo Doc. Identidad",

T1."LicTradNum" || LPAD(' ',12-LENGTH(T1."LicTradNum")) AS "NroDocIdentidad",

case when T1."BankCtlKey" = 'C' then 'P' 
	 when T1."BankCtlKey" = 'B' then 'I' 
else 'O'
end as "Tipo Abono",

 --"DflAccount" || REPLICATE(' ',20-LENGTH("DflAccount")) as "Cuenta a Abonar",

LEFT(LTRIM(RTRIM(REPLACE(T1."DflAccount",'-',''))),20) 
|| REPLICATE (' ', 20 - LENGTH(LEFT(LTRIM(RTRIM(REPLACE(T1."DflAccount",'-',''))),20))) 
as "Cuenta a Abonar",

LEFT(T1."CardName",40) || LPAD(' ',40-LENGTH(LEFT(T1."CardName",40))) as "Nombre Beneficiario",

CASE T8."U_BPP_MONEDA" WHEN 'SOL' THEN
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
 
END  AS "ImportAbonar",

'F' as "Tipo Documento",

 (SELECT
    CAST(OP."U_BPP_MDSD" || OP."U_BPP_MDCD" || LPAD (' ',9-LENGTH(OP."U_BPP_MDCD")) AS NVARCHAR(12))
   FROM  OPCH OP WHERE OP."DocEntry" = T10."DocEntry") AS "NroDocumento",

 'N' as "Abono Grupal",

'PAGOPROVEEDORESBBVA' || LPAD(' ', 21)AS "Referencia",

REPLICATE(' ', 1) 		as "Indicador de Aviso",
REPLICATE(' ', 50) 		as "Medio Aviso",
REPLICATE(' ', 30) 		as "Persona Contacto",
REPLICATE('0', 2) 		as "Indicador Proceso",
REPLICATE('0', 30) 		as "Desc. Cod. Retorno",
REPLICATE(' ', 18) 		as "Filler",
'D' as "D"

 FROM "@BPP_PAGM_CAB" T7
 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7."DocEntry" = T8."DocEntry"
 INNER JOIN "OPCH" T10 ON T10."DocEntry" = T8."U_BPP_NUMSAP"
 INNER JOIN "OCRD" T1 ON T1."CardCode" = T8."U_BPP_CODPROV"
 
 WHERE T7."U_BPP_ESTADO" != 'Cancelado' and T8."DocEntry" = :DOCENTRY
 
 ) RD;
 
 END;