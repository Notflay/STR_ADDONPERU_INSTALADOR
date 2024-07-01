CREATE PROCEDURE SP_BPP_ARCHIVO_PAGOS_MASIVOS

(
DocEntry INT
)
AS BEGIN

SELECT
A."CONCAT" "Texto"
FROM
(
SELECT
'A' "LLAVE",
TT."POS_1"
||TT."POS_2"
||TT."POS_3"
||TT."POS_4"
||TT."POS_5" "CONCAT"
FROM
(
SELECT
'*' "POS_1",
(SELECT "TaxIdNum" FROM OADM) "POS_2",
(SELECT RPAD("PrintHeadr",35,' ') FROM OADM)  "POS_3",
RIGHT(YEAR(T0."U_BPP_FECCREA"),2)||LPAD(T0."U_BPP_NROLOTE",4,0) "POS_4",
LPAD(SUBSTRING(SUM(T1."U_BPP_IMPORTEPAGO"),1,LOCATE(SUM(T1."U_BPP_IMPORTEPAGO"),'.')-1),13,'0')||'00' "POS_5"

FROM "@BPP_DETR_CAB" T0
INNER JOIN "@BPP_DETR_DET1" T1 ON T0."DocEntry"=T1."DocEntry"
WHERE T0."DocEntry"=:DocEntry
GROUP BY T0."DocEntry",T0."U_BPP_FECCREA",T0."U_BPP_NROLOTE")TT


UNION ALL

SELECT
'B' "LLAVE",
TT."POS_1"
||TT."POS_2"
||TT."POS_3"
||TT."POS_4"
||TT."POS_5"
||TT."POS_6"
||TT."POS_7"
||TT."POS_8"
||TT."POS_9"
||TT."POS_10"
||TT."POS_11"
||TT."POS_12" "CONCAT"
FROM
(
SELECT
'6' "POS_1",
RPAD(LEFT(T1."LicTradNum",11),11,' ') "POS_2",
LPAD(' ',35) "POS_3",
LPAD(' ',9) "POS_4",
RPAD(T0."U_BPP_CODDET",3,' ') "POS_5",
RPAD(T2."Account",11,' ') "POS_6",
LPAD(SUBSTRING(T0."U_BPP_IMPORTEPAGO",1,LOCATE(T0."U_BPP_IMPORTEPAGO",'.')-1),13,'0')||'00' "POS_7",
'01' "POS_8",
YEAR(T0."U_BPP_FECDOC")||LPAD(MONTH(T0."U_BPP_FECDOC"),2,'0') "POS_9",
T4."U_BPP_MDTD" "POS_10",
LPAD("U_BPP_MDSD",4,'0') "POS_11",
LPAD("U_BPP_MDCD",8,'0') "POS_12"


FROM "@BPP_DETR_DET1" T0
INNER JOIN OCRD T1 ON T0."U_BPP_CODPROV"=T1."CardCode" 
LEFT JOIN OCRB T2 ON T1."CardCode"=T2."CardCode" AND T2."BankCode"='BNP'
INNER JOIN "@BPP_DETR_CAB" T3 ON T0."DocEntry"=T3."DocEntry"
LEFT JOIN OPCH T4 ON T0."U_BPP_NUMSAP"=T4."DocEntry"
WHERE T0."DocEntry"=:DocEntry
)TT
)A ORDER BY A."LLAVE" ASC;
END;
