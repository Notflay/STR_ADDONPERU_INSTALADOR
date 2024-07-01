CREATE FUNCTION RML_TN_APP_PGM_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    SET @error_message = '';

    IF @transaction_type IN ('A')
    BEGIN
        DECLARE @rsl2 INT;
        SELECT @rsl2 = COUNT(*)
        FROM @BPP_PAGM_DET1
        WHERE DocEntry = @id AND ISNULL(U_BPP_CODPROV, '') = '';

        IF @rsl2 > 0
        BEGIN
            SET @error_message = 'Se tiene que agregar mínimo 1 proveedor para continuar con el proceso';
        END
    END

    RETURN @error_message;
END

