CREATE PROCEDURE STR_SP_PagoMasivoDetracciones_D
(
@NROLOTE INT = 70,
@FECHA DATETIME ='20141230'
)
AS
SELECT
		T3.DOCENTRY,
		replicate(' ',35) AS CardName,
		'6'AS TProv,
		T1.LicTradNum,
		T1.CardCode,
		T3.DOCNUM AS U_Nrolote,
		T2.U_BPP_CdBn,
		REPLACE(T4.Account,'-','') AS Account,
		RTRIM(CAST(CONVERT(INT,(ROUND(T0.U_BPP_SdAs,0))) AS CHAR(5)))+''+'00'AS ImportCargar,
		T2.U_BPP_CdOp,
		CONVERT(CHAR(4),YEAR(T2.Taxdate))+''+REPLICATE('0',2-LEN(MONTH(T2.Taxdate)))+''+CONVERT(CHAR(2),MONTH(T2.Taxdate)) AS Perido,
		T2.U_BPP_MDTD AS  Tipo,
 
		REPLICATE(0,4- LEN(T2.U_BPP_MDSD))+ T2.U_BPP_MDSD AS  Serie,
		REPLICATE(0,8- LEN(T2.U_BPP_MDCD))+ right(T2.U_BPP_MDCD,8) AS  Correlativo,
		T4.BankCode,
		T4.Branch
		--,T3.DOCNUM, t4.BankCode, T4.MandateID
			FROM [@BPP_PAYDTRDET] T0
			 INNER JOIN OCRD T1 ON T0.U_BPP_CgPv=T1.CardCode
			 INNER JOIN OPCH T2 ON T2.U_BPP_AstDetrac = T0.U_BPP_DEAS
			 INNER JOIN [@BPP_PAYDTR] T3 ON T0.DocEntry = T3.DocEntry			
			 INNER JOIN OCRB T4 ON T4.CardCode=T1.CardCode
			 
WHERE
(t4.BankCode='0018' OR T4.MandateID='018')
and 
T3.DOCNUM=@NROLOTE
AND 
T3.CreateDate = @FECHA
ORDER BY T1.CardCode
 