CREATE FUNCTION RML_TN_LC_2_SociosNegocio
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @E_MAIL NVARCHAR(100);
    DECLARE @C1 INT;

    -- Inicialización de la variable de error
    SET @error_message = ''; 

    -- Obtener el correo electrónico del socio de negocio
    SELECT @E_MAIL = ISNULL(T1.E_Mail, '')
    FROM OCRD T1
    WHERE T1.CardCode = @id;

    -- Verificar si el correo electrónico está vacío
    SET @C1 = CASE WHEN @E_MAIL = '' THEN 1 ELSE 0 END;

    -- Condición para los tipos de transacción 'A' y 'U'
    IF @transaction_type IN ('A', 'U')
    BEGIN
        IF @C1 > 0
        BEGIN
            SET @error_message = 'Debe ingresar el correo electrónico de la pestaña general.';
        END 
    END

    RETURN @error_message;
END;
