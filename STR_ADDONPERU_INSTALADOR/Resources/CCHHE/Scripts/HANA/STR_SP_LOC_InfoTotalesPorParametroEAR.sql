CREATE PROCEDURE STR_SP_LOC_InfoTotalesPorParametroEAR
(
	IN Impuesto VARCHAR(10),
	IN TotalLinea DECIMAL(19,6),
	IN MonedaDetalle VARCHAR(10),
	IN FechaDocumento VARCHAR(10),
	IN MonedaCabecera VARCHAR(10)
)
AS
mndloc char(3);
BEGIN
	SELECT TOP 1 "MainCurncy" INTO mndloc  FROM OADM;
	SELECT
		--TOTAL SIN IMPUESTO
		"TSI" AS "TSIM",
		--TOTAL IMPUESTO
		"TIM" AS "TTIM",
		--IMPORTE TOTAL
		"IMT" AS "IMPT"
	FROM
	(
		SELECT 
			CASE :Impuesto WHEN 'EXO' THEN 	
				:TotalLinea * ((CASE :MonedaDetalle WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaDetalle) END)
				/(CASE :MonedaCabecera WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaCabecera) END))	  		 	
			ELSE 	
				((:TotalLinea) - ((:TotalLinea *(SELECT "Rate" FROM OSTC WHERE "Code" = :Impuesto))/((SELECT "Rate" FROM OSTC WHERE "Code" = :Impuesto )+100))) 
				* ((CASE :MonedaDetalle WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaDetalle) END)
				/ (CASE :MonedaCabecera WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaCabecera) END))	  		 	
			END AS TSI
		   ,CASE :Impuesto WHEN 'EXO' THEN 0
			ELSE 
				((:TotalLinea *(SELECT "Rate" FROM OSTC WHERE "Code" = :Impuesto))/((SELECT "Rate" FROM OSTC WHERE "Code" = :Impuesto )+100))
				* ((CASE :MonedaDetalle WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaDetalle) END)
				/ (CASE :MonedaCabecera WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaCabecera) END))	  	
			END AS TIM			 
			,:TotalLinea * ((CASE :MonedaDetalle WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaDetalle) END)
				/(CASE :MonedaCabecera WHEN :mndloc THEN 1 ELSE (SELECT "Rate" FROM ORTT WHERE "RateDate" = :FechaDocumento AND "Currency" = :MonedaCabecera) END))
			  AS IMT		 
		FROM DUMMY
	)AS "TBL";			
END