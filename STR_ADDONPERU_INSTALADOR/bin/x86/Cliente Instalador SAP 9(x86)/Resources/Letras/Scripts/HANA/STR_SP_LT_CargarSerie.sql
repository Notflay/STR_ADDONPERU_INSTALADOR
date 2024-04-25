CREATE PROCEDURE STR_SP_LT_CargarSerie()
AS
BEGIN
	select "U_serie", "U_tipo", "U_idper", 
		IFNULL((select max("U_cdStLet") from "@ST_LT_MSTLET" t0 where t0."U_serie" = t1."U_serie" 
		and t0."U_tipo" = t1."U_tipo"),('LET' || (SELECT '0000000001' FROM DUMMY))) AS "U_corr"  
	from "@ST_LT_SERL" t1;
END;
