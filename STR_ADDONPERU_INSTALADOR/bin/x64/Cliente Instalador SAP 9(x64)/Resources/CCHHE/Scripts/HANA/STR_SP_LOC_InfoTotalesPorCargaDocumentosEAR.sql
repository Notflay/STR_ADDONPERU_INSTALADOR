CREATE PROCEDURE STR_SP_LOC_InfoTotalesPorCargaDocumentosEAR
(
	pi_DOCENTRY INTEGER
)
AS
mndloc char(3);
BEGIN
	SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;
	SELECT
		--TOTAL SIN IMPUESTO
		SUM("TSI") AS "TSIM",
		--TOTAL IMPUESTO
		SUM("TIM") AS "TTIM",
		--IMPORTE TOTAL
		SUM("IMT") AS "IMPT"
	FROM
	(
		SELECT 
			CASE "U_ER_IMPD" WHEN 'EXO' THEN 	
				"U_ER_TTLN" * ((CASE "U_ER_MNDC" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = "U_ER_MNDC") END)
				/(CASE T0."U_ER_MNDA" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = T0."U_ER_MNDA") END))	  		 	
			ELSE 	
				(("U_ER_TTLN") - (("U_ER_TTLN" *(SELECT "Rate" FROM OSTC WHERE "Code" = "U_ER_IMPD"))/((SELECT "Rate" FROM OSTC WHERE "Code" = "U_ER_IMPD" )+100))) 
				* ((CASE "U_ER_MNDC" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = "U_ER_MNDC") END)
				/ (CASE T0."U_ER_MNDA" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = T0."U_ER_MNDA") END))	  		 	
			END AS TSI
		   ,CASE "U_ER_IMPD" WHEN 'EXO' THEN 0
			ELSE 
				(("U_ER_TTLN" *(SELECT "Rate" FROM OSTC WHERE "Code" = "U_ER_IMPD"))/((SELECT "Rate" FROM OSTC WHERE "Code" = "U_ER_IMPD" )+100))
				* ((CASE "U_ER_MNDC" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = "U_ER_MNDC") END)
				/ (CASE T0."U_ER_MNDA" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = T0."U_ER_MNDA") END))	  	
			END AS TIM			 
			,"U_ER_TTLN" * ((CASE "U_ER_MNDC" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = "U_ER_MNDC") END)
				/(CASE T0."U_ER_MNDA" WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_ER_FCDC" AND "Currency" = T0."U_ER_MNDA") END))
			  AS IMT		 
		FROM "@STR_EARCRG" T0 INNER JOIN "@STR_EARCRGDET" T1
		ON T0."DocEntry" = T1."DocEntry" WHERE T0."DocEntry" = :pi_DOCENTRY AND "U_ER_SLCC" = 'Y' AND "U_ER_ESTD" IN('CRE','ERR')
	)AS "TBL";			
END 





		   		 
		   


	


		   		 
		   


	
