CREATE FUNCTION RML_TN_APP_CC_ER_1470000113_SOLICITUDIN
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    SET @error_message = '';

	--Pagos efectuados
	DECLARE @TPORND VARCHAR(4)
	DECLARE @CNT INT
	DECLARE @CTARGT VARCHAR(30)
	DECLARE @CTAPGO VARCHAR(30)
	DECLARE @DTOCTA VARCHAR(100)
	DECLARE @NMRCCHEAR VARCHAR(50)

	IF  @transaction_type = 'A'
	BEGIN
		DECLARE @MND VARCHAR(5)
		DECLARE @SLC CHAR(1)
		DECLARE @MNT NUMERIC(19,6)
		SELECT @MND = U_CE_MNDA, @SLC = U_CE_EAR, @MNT = T1.U_CE_IMSL FROM OPRQ T0 INNER JOIN PRQ1 T1 
		ON T0.DocEntry =  T1.DocEntry WHERE T0.DocEntry = @id
		IF ISNULL(@MND,'') = '' AND @SLC = 'Y'
		BEGIN
			SET @error_message = 'No se ha definido la moneda de la solicitud de dinero EAR...'
		END
		IF @MNT<=0 AND @SLC = 'Y'
		BEGIN
			SET @error_message = 'Ingrese un monto valido en el detalle de la solicitud de dinero EAR...'
		END
	END
    RETURN @error_message;
END