CREATE FUNCTION RML_TN_LC_4_MaestroArticulos
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);

    -- Inicialización de la variable de error
    SET @error_message = ''; 


    RETURN @error_message;
END;

