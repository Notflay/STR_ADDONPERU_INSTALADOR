CREATE FUNCTION RML_TN_CL_203_AnticipoVentas
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R1 INT;

    SET @error_message = '';

    RETURN @error_message;
END

