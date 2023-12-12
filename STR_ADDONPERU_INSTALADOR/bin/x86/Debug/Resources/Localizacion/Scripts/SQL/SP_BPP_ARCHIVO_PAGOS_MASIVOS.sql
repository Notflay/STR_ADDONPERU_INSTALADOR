CREATE PROCEDURE SP_BPP_ARCHIVO_PAGOS_MASIVOS

(
@DocEntry INT
)
AS BEGIN

SELECT
A."CONCAT" "Texto"
FROM
(
SELECT
'A' AS "LLAVE",
TT."POS_1"
+ TT."POS_2"
+ TT."POS_3"
+ TT."POS_4"
+ TT."POS_5" AS "CONCAT"
FROM
(
SELECT
'*' AS "POS_1",
(SELECT "TaxIdNum" FROM OADM) AS "POS_2",
(SELECT LEFT(CAST("PrintHeadr" AS VARCHAR) + SPACE(35), 35) FROM OADM) AS "POS_3",
RIGHT(YEAR(T0."U_BPP_FECCREA"),2) + RIGHT(REPLICATE('0', 4) + CAST(T0."U_BPP_NROLOTE" AS VARCHAR), 4) AS "POS_4",
RIGHT(REPLICATE('0', 13) + SUBSTRING(CAST(SUM(T0."U_BPP_IMPORTEPAGO") AS VARCHAR),1,CHARINDEX('.',CAST(SUM(T0."U_BPP_IMPORTEPAGO") AS VARCHAR))-1),13) + '00' AS "POS_5"
FROM "@BPP_DETR_CAB" T0
INNER JOIN "@BPP_DETR_DET1" T1 ON T0."DocEntry"=T1."DocEntry"
WHERE T0."DocEntry"=@DocEntry
GROUP BY T0."DocEntry",T0."U_BPP_FECCREA",T0."U_BPP_NROLOTE")TT


UNION ALL

SELECT
'B' AS "LLAVE",
TT."POS_1"
+ TT."POS_2"
+ TT."POS_3"
+ TT."POS_4"
+ TT."POS_5"
+ TT."POS_6"
+ TT."POS_7"
+ TT."POS_8"
+ TT."POS_9"
+ TT."POS_10"
+ TT."POS_11"
+ TT."POS_12" AS "CONCAT"
FROM
(
SELECT
'6' AS "POS_1",
ISNULL(LEFT(T1."LicTradNum",11),SPACE(11)) AS "POS_2",
SPACE(35) AS "POS_3", 
SPACE(9) AS "POS_4",
LEFT(CAST(T0."U_BPP_CODDET" AS VARCHAR) + SPACE(3), 3) AS "POS_5",
LEFT(CAST(T2."Account" AS VARCHAR) + SPACE(11), 11) AS "POS_6",
RIGHT(REPLICATE('0', 13) + SUBSTRING(CAST(T0."U_BPP_IMPORTEPAGO" AS VARCHAR),1,CHARINDEX('.',CAST(T0."U_BPP_IMPORTEPAGO" AS VARCHAR))-1),13) + '00' AS "POS_7",
'01' AS "POS_8",
CAST(YEAR(T0."U_BPP_FECDOC") AS VARCHAR) + RIGHT(REPLICATE('0', 2) + CAST(MONTH(T0."U_BPP_FECDOC") AS VARCHAR),2) AS "POS_9",
T4."U_BPP_MDTD" AS "POS_10",
RIGHT(REPLICATE('0', 4) + CAST(T0."U_BPP_MDSD" AS VARCHAR), 4) AS "POS_11",
RIGHT(REPLICATE('0', 8) + CAST(T0."U_BPP_MDCD" AS VARCHAR), 8) AS "POS_12"

FROM "@BPP_DETR_DET1" T0
INNER JOIN OCRD T1 ON T0."U_BPP_CODPROV"=T1."CardCode" 
LEFT JOIN OCRB T2 ON T1."CardCode"=T2."CardCode" AND T2."BankCode"='BNP'
INNER JOIN "@BPP_DETR_CAB" T3 ON T0."DocEntry"=T3."DocEntry"
LEFT JOIN OPCH T4 ON T0."U_BPP_NUMSAP"=T4."DocEntry"
WHERE T0."DocEntry"=@DocEntry
)TT
)A ORDER BY A."LLAVE" ASC;
END