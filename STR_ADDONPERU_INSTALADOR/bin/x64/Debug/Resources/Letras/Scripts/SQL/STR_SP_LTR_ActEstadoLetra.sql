CREATE PROCEDURE STR_SP_LTR_ActEstadoLetra
(
    --@p_codLet NVARCHAR(20), 
    @p_EstAct INT,
    @p_EstAnt INT,
    --@p_Fecha DATETIME,
    @p_Serie NVARCHAR(10),
    @p_TipoLet INT
)
AS
BEGIN
    UPDATE "@ST_LT_MSTLET" 
    SET 
        "U_estAct" = RIGHT('000' + CAST(@p_EstAct AS NVARCHAR(3)), 3),
        "U_estAnt" = RIGHT('000' + CAST(@p_EstAnt AS NVARCHAR(3)), 3)
    WHERE
        "U_serie" = @p_Serie
        AND "U_tipo" = CASE WHEN @p_TipoLet = 1 THEN '001' ELSE '002' END;
END;
