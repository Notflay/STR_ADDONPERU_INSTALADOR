CREATE FUNCTION RML_TN_LC_17_PedidoCliente
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R2 INT;
    DECLARE @DOCTYPE NCHAR(1);

    SET @error_message = '';

    RETURN @error_message;
END

