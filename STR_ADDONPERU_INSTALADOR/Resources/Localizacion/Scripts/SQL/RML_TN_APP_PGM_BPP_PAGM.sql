CREATE FUNCTION RML_TN_APP_PGM_BPP_PAGM
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    -- Variable de retorno de mensaje de error
    DECLARE @error_message NVARCHAR(200) = '';
    DECLARE @rsl2 INT;

    IF @transaction_type = 'A'
    BEGIN
        SELECT @rsl2 = COUNT(*) 
        FROM "@BPP_PAGM_DET1" 
        WHERE DocEntry = @id 
          AND ISNULL(U_BPP_CODPROV, '') = '';

        IF @rsl2 > 0
        BEGIN
            SET @error_message = 'Se tiene que agregar minimo 1 proveedor para continuar con el proceso';
        END
    END

    RETURN @error_message;
END
