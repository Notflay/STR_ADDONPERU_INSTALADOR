CREATE PROC STR_SP_LOC_InfoTotalesPorCargaDocumentosCCH
	@DOCENTRY INT
AS
DECLARE @MNDLOC AS CHAR(3)
--Moneda local
SET @MNDLOC =  (SELECT TOP 1 MainCurncy FROM OADM)
SELECT 
	--TOTAL SIN IMPUESTO
	SUM(TSI) as TSIM
	--TOTAL IMPUESTO
	,SUM(TIM) TTIM
	--IMPORTE TOTAL
	,SUM(IMT) AS IMPT
FROM
	(
		SELECT 
			CASE U_CC_IMPD WHEN 'EXO' THEN 	
				U_CC_TTLN * ((CASE U_CC_MNDC WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = U_CC_MNDC) END)
				/(CASE T0.U_CC_MNDA WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = T0.U_CC_MNDA) END))	  		 	
			ELSE 	
				((U_CC_TTLN) - ((U_CC_TTLN *(SELECT Rate FROM OSTC WHERE Code = U_CC_IMPD))/((SELECT Rate FROM OSTC WHERE Code = U_CC_IMPD )+100))) 
				* ((CASE U_CC_MNDC WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = U_CC_MNDC) END)
				/ (CASE T0.U_CC_MNDA WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = T0.U_CC_MNDA) END))	  		 	
			END AS TSI
		   ,CASE U_CC_IMPD WHEN 'EXO' THEN 0
			ELSE 
				((U_CC_TTLN *(SELECT Rate FROM OSTC WHERE Code = U_CC_IMPD))/((SELECT Rate FROM OSTC WHERE Code = U_CC_IMPD )+100))
				* ((CASE U_CC_MNDC WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = U_CC_MNDC) END)
				/ (CASE T0.U_CC_MNDA WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = T0.U_CC_MNDA) END))	  	
			END AS TIM			 
			,U_CC_TTLN * ((CASE U_CC_MNDC WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = U_CC_MNDC) END)
				/(CASE T0.U_CC_MNDA WHEN @MNDLOC THEN 1 ELSE (SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC AND Currency = T0.U_CC_MNDA) END))
			  AS IMT		 
		FROM [@STR_CCHCRG] T0 INNER JOIN [@STR_CCHCRGDET] T1
		ON T0.DocEntry = T1.DocEntry WHERE T0.DocEntry = @DOCENTRY	AND U_CC_SLCC = 'Y' AND U_CC_ESTD IN('CRE','ERR')
	) AS TBL
