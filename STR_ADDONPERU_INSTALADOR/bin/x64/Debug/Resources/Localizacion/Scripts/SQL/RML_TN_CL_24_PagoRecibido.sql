CREATE FUNCTION RML_TN_CL_24_PagoRecibido
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    SET @error_message = '';

    RETURN @error_message;
END;
