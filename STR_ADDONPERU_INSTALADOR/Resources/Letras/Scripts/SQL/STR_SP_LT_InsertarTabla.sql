CREATE PROCEDURE STR_SP_LT_InsertarTabla
(
    @p_NomTabla NVARCHAR(100),
    @p_Valor1 NVARCHAR(20),
    @p_Valor2 NVARCHAR(20),
    @p_Valor3 NVARCHAR(250),
    @p_Valor4 NVARCHAR(20)
)
AS
BEGIN
    DECLARE @Code NVARCHAR(8);

    IF @p_NomTabla = '@ST_LT_SERL'
    BEGIN
        SELECT @Code = RIGHT('00000000' + CAST(ISNULL((SELECT MAX(CONVERT(INT, "Code")) FROM "@ST_LT_SERL"), 0) + 1 AS NVARCHAR(8)), 8);
        INSERT INTO "@ST_LT_SERL" VALUES (@Code, @Code, @p_Valor1, @p_Valor2, @p_Valor3, @p_Valor4);
    END
    ELSE IF @p_NomTabla = '@ST_LT_CONF'
    BEGIN
        SELECT @Code = RIGHT('00000000' + CAST(ISNULL((SELECT MAX(CONVERT(INT, "Code")) FROM "@ST_LT_CONF"), 0) + 1 AS NVARCHAR(8)), 8);
        INSERT INTO "@ST_LT_CONF" VALUES (@Code, @Code, @p_Valor1, @p_Valor2, @p_Valor3, @p_Valor4);
    END
END;
