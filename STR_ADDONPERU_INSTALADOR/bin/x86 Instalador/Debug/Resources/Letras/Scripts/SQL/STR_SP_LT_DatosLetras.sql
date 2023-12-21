CREATE PROCEDURE STR_SP_LT_DatosLetras
(
    @p_Serie NVARCHAR(20),
    @P_CodLetra NVARCHAR(20)
)
AS
BEGIN
    SELECT 
        EL."DocEntry", 
        EL."U_codLet", 
        MS."U_estAct" AS "Estado", 
        EL."U_NumAsi", 
        EL."U_ImpML", 
        EL."U_ImpME"  
    FROM 
        "@ST_LT_ELLETRAS" EL 
    LEFT JOIN 
        "@ST_LT_MSTLET" MS ON CONVERT(DECIMAL(19,0), MS."Code") = (
            SELECT MAX(CONVERT(DECIMAL(19,0), MS2."Code")) 
            FROM "@ST_LT_MSTLET" MS2 
            WHERE MS2."U_cdStLet" = EL."U_codLet"
        ) 
    WHERE 
        MS."U_serie" = @p_Serie 
        AND MS."U_tipo" = '001' 
        AND EL."DocEntry" = (
            SELECT MAX(DL."DocEntry") 
            FROM "@ST_LT_ELLETRAS" DL, "@ST_LT_EMILET" EL2 
            WHERE 
                DL."U_codLet" = @P_CodLetra 
                AND EL2."U_SerLetra" = @p_Serie 
                AND DL."DocEntry" = EL2."DocEntry"
        );
END;
