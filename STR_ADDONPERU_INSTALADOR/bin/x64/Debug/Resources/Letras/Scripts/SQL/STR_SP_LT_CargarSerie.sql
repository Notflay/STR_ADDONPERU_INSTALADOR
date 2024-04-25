CREATE PROCEDURE STR_SP_LT_CargarSerie
AS
BEGIN
    SELECT 
        "U_serie",
        "U_tipo",
        "U_idper",
        ISNULL(
            (SELECT MAX("U_cdStLet") 
             FROM "@ST_LT_MSTLET" t0 
             WHERE t0."U_serie" = t1."U_serie" AND t0."U_tipo" = t1."U_tipo"),
            ('LET' + RIGHT('0000000001', 10))
        ) AS "U_corr"
    FROM 
        "@ST_LT_SERL" t1;
END;