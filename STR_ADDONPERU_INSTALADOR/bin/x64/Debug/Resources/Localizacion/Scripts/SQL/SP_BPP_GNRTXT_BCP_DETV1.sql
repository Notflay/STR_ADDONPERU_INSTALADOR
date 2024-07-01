CREATE PROCEDURE SP_BPP_GNRTXT_BCP_DETV1
(
	 @DOCENTRY INT  = 12
)
AS
 declare @codigopago VARCHAR(10);
 declare @checksum Decimal
BEGIN


SELECT Distinct

' 2' AS 'TipRegistr',

CASE WHEN LEFT(LTRIM(RTRIM(isnull(T1.BankCtlKey,''))),1) = 'I' THEN 'B'
ELSE 
LEFT(LTRIM(RTRIM(isnull(T1.BankCtlKey,''))),1) END AS 'TipoProducto',

CASE T1.BankCtlKey WHEN 'A' THEN 
	LEFT(LTRIM(RTRIM(REPLACE(T1.DflAccount,'-',''))),20) + REPLICATE(' ', 20 - LEN(LEFT(LTRIM(RTRIM(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''))),20)))
ELSE
	LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''), 1, 3) + '0' + 
	SUBSTRING(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''), 4, LEN(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''))))),20) + 
	REPLICATE(' ', 20 - LEN(LEFT(LTRIM(RTRIM(SUBSTRING(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''), 1, 3) + '0' + 
	SUBSTRING(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''), 4, LEN(REPLACE(REPLACE(T1.DflAccount,'-',''),' ',''))) )),20)))--+SPACE(6)
END  AS 'NroCtaAbono',

LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(T1.CardName,'Ñ','N'),',',' '),'_',''),'&',''))) AS 'RazonSocBenef',


CASE T8.U_BPP_MONEDA WHEN 'SOL' THEN 'S/' ELSE 'US' END AS 'Moneda',
CASE T8.U_BPP_MONEDA WHEN 'SOL' THEN
	RIGHT('00000000000000' 
						+ SUBSTRING(CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(15)),1,CHARINDEX('.',CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(15)))-1) 
						+ SUBSTRING(CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(30)) ,(CHARINDEX('.',CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(30)))+1),2),15) 
	ELSE
		RIGHT('00000000000000' 
						+ SUBSTRING(CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(15)),1,CHARINDEX('.',CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(15)))-1) 
						+ SUBSTRING(CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(30)) ,(CHARINDEX('.',CAST((T8.U_BPP_MONTOPAG) AS VARCHAR(30)))+1),2),15)
END  AS 'ImportAbonar',

CASE 
	WHEN T1.U_BPP_BPTD = 1 OR T1.U_BPP_BPTD = 'DNI' THEN 'DNI'
	WHEN T1.U_BPP_BPTD = 6 OR T1.U_BPP_BPTD = 'RUC' THEN 'RUC'
	WHEN T1.U_BPP_BPTD = 4 OR T1.U_BPP_BPTD = 'CE' THEN  LEFT('CE',2) + ' ' ELSE REPLICATE(' ', 3)
END AS 'TipoDocIdentidad',

LTRIM(RTRIM(T1.LicTradNum)) AS 'NroDocIdentidad',

'F' AS 'TipoDocPagar',
  
CASE 
    WHEN ISNULL((SELECT CONVERT(NVARCHAR(10),
                RIGHT(OP.U_BPP_MDSD, 2) + REPLICATE('0', 14 - LEN(OP.U_BPP_MDCD)) + OP.U_BPP_MDCD)
            FROM OPCH OP WHERE OP.DocEntry = T10.DocEntry), '') = '' 
        THEN 
            (SELECT SUBSTRING(OP.Ref3, CHARINDEX(OP.Ref3, '-') - 2, 2) +
                    RIGHT(('00000000' + RIGHT(OP.Ref3, LEN(OP.Ref3) - CHARINDEX(OP.Ref3, '-'))), 8)
            FROM OJDT OP WHERE OP.TransId = T10.DocEntry)
    ELSE  
        CASE 
            WHEN LEN(U_BPP_MDCD) > 8 THEN 
                (SELECT CONVERT(NVARCHAR(10),
                        RIGHT(OP.U_BPP_MDSD, 2) + REPLICATE('0', 14 - LEN(OP.U_BPP_MDCD)) + RIGHT(OP.U_BPP_MDCD,4))
                    FROM OPCH OP WHERE OP.DocEntry = T10.DocEntry)
            ELSE 
                (SELECT CONVERT(NVARCHAR(10),
                        RIGHT(OP2.U_BPP_MDSD, 2) + REPLICATE('0', 8 - LEN(OP2.U_BPP_MDCD)) + OP2.U_BPP_MDCD)
                    FROM OPCH OP2 WHERE OP2.DocEntry = T10.DocEntry)
        END
END AS 'NroDocumento',
 
+SPACE(10)+ '1' AS 'TipoAbono',
  
'F' + (SELECT OP.U_BPP_MDTD + '-' + OP.U_BPP_MDSD  + '-' + OP.U_BPP_MDCD 
		FROM OPCH OP WHERE OP.DocEntry = T10.DocEntry) AS 'RefAdicional',
		
+SPACE(21)+'0' AS 'NotaAbono',
'0' AS 'Delivery',

'1' AS 'ValidaRuc',

LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.Address),''))),40) + REPLICATE(' ', 40 - LEN(LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.Address),''))),40))) AS 'Direccion',
LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.City),''))),20) + REPLICATE(' ', 20 - LEN(LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1."City"),''))),20))) AS 'Distrito',
LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.County),''))),20) + REPLICATE(' ', 20 - LEN(LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1."County"),''))),20))) AS 'Provincia',

LEFT(ISNULL(T2.Name,''),20) + REPLICATE(' ', 20 - LEN(LEFT(ISNULL(T2.Name,''),20))) AS 'Departamento',
LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.CntctPrsn),''))),40) + REPLICATE(' ', 40 - LEN(LEFT(LTRIM(RTRIM(ISNULL(UPPER(T1.CntctPrsn),''))),40))) AS 'Contacto'

INTO #RD

FROM "@BPP_PAGM_CAB" T7
left JOIN "@BPP_PAGM_DET1" T8 ON T7.DocEntry = T8.DocEntry
left JOIN OPCH T10 ON T10.DocEntry = T8.U_BPP_NUMSAP
left JOIN OCRD T1 ON T1.CardCode = T8.U_BPP_CODPROV
left JOIN CRD1 T3 ON T1.CardCode = T3.CardCode
left JOIN OCST T2 ON T3.State = T2.Code and T2.Country != 'CL'
WHERE T7.U_BPP_ESTADO != 'Cancelado' and  T7.DocEntry =@DOCENTRY
 --select U_BPP_ESTADO,* from "@BPP_PAGM_CAB" where DocEntry=9

 SELECT 
"TipRegistr"				+						--1
"TipoProducto"				+						--2 DESCOMENTAR CUANDO SE CORRIJA ARRIBA 
"NroCtaAbono"		+								--3
SUBSTRING("RazonSocBenef" + SPACE(40), 1, 40) +		--4
"Moneda"					+						--5
"ImportAbonar"				+						--6
"TipoDocIdentidad"			+						--7
 SUBSTRING(RIGHT("NroDocIdentidad",12) + SPACE(12), 1, 12) +	--8	
 "TipoDocPagar"+									--9
SUBSTRING("TipoAbono", 1, 21) +						--10
SUBSTRING("RefAdicional", 1,40) +					--11
"NotaAbono"					+						--12
"Delivery"			 	    +						--13
"ValidaRuc"					+						--14
SUBSTRING("Direccion",1,40)	+						--15 VACIO
SUBSTRING("Distrito"+SPACE(20),1,20)	+			--16 VACIO
"Provincia"	+										--17 VACIO
"Departamento"+										--18 VACIO
SUBSTRING("Contacto",1,40)+
Char(9)
 --EXEC [dbo].[SP_BPP_GNRTXT_BCP_DETV1] 12
AS "PMBCP_D"
FROM #RD;
 
 END;


 --EXEC [dbo].[SP_BPP_GNRTXT_BCP_DETV1] 12
