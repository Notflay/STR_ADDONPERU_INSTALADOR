CREATE PROCEDURE STR_SP_PagoMasivoDetracciones_C
--Modificado 20131101
(
@NROLOTE INT,
@FECHA DATETIME
)
 
AS
 
SELECT 
T0.Docentry,
T1.TAXIDNUM,
T1.COMPNYNAME,
RIGHT(YEAR(t0.CREATEDATE),2)+''+REPLICATE('0',4-LEN(T0.Docnum))+''+CONVERT(CHAR(4),T0.Docnum) AS U_Nrolote,
(REPLICATE ('0', 15 - LEN(
SUBSTRING(CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),1,CHARINDEX('.',CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),3)-1)
+SUBSTRING(CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),(CHARINDEX('.',CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),3)+1),2)))
+SUBSTRING(CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),1,CHARINDEX('.',CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),3)-1)
+SUBSTRING(CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),(CHARINDEX('.',CAST(SUM(ROUND(T0.U_BPP_TtPg,2)) AS VARCHAR(15)),3)+1),2))
 
AS ImportCargar
FROM [@BPP_PAYDTR] T0 , OADM T1 
WHERE T0.DOCNUM=@NROLOTE 
AND T0.CreateDate=@FECHA
GROUP BY T0.Docentry,t0.CREATEDATE,T1.TAXIDNUM,T1.COMPNYNAME,T0.Docnum