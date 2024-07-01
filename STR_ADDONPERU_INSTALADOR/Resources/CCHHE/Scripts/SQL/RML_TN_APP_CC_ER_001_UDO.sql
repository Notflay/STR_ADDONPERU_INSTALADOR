CREATE FUNCTION RML_TN_APP_CC_ER_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);

    SET @error_message = '';

    IF @transaction_type IN ('A', 'U')
    BEGIN
		  DECLARE @ttcch DECIMAL(18, 2);
		DECLARE @sldcch DECIMAL(18, 2);
		DECLARE @flgsld NVARCHAR(1);

		SELECT @ttcch = SUM(IMT)
		FROM (
			SELECT 
				CASE T0.U_CC_MNDA 
					WHEN 'SOL' THEN
						CASE T1.U_CC_MNDC 
							WHEN 'SOL' THEN T1.U_CC_TTLN
							ELSE T1.U_CC_TTLN * (SELECT Rate FROM ORTT WHERE RateDate = T1.U_CC_FCDC)
						END
					ELSE
						CASE T1.U_CC_MNDC 
							WHEN 'SOL' THEN T1.U_CC_TTLN / (SELECT Rate FROM ORTT WHERE RateDate = T1.U_CC_FCDC)
							ELSE T1.U_CC_TTLN 
						END
				END AS IMT
			FROM "@STR_CCHCRG" T0 
			INNER JOIN "@STR_CCHCRGDET" T1 ON T0.DocEntry = T1.DocEntry 
			WHERE T0.DocEntry = @id 
			  AND T1.U_CC_SLCC = 'Y' 
			  AND T1.U_CC_ESTD IN ('CRE', 'ERR')
		) AS TX0;

		SELECT @sldcch = U_CC_SLDI - @ttcch
		FROM "@STR_CCHCRG" 
		WHERE DocEntry = @id;

		SELECT TOP 1 @flgsld = T0.U_STR_SLNG
		FROM "@BPP_CAJASCHICAS" T0 
		INNER JOIN "@STR_CCHCRG" T1 ON T0.Code = T1.U_CC_NMBR 
		WHERE T1.DocEntry = @id;

		IF @sldcch < 0 AND ISNULL(@flgsld, 'N') <> 'Y'
		BEGIN
			SET @error_message = 'El monto total de los documentos registrados (' + CAST(@ttcch AS NVARCHAR) + '), es mayor al saldo de esta caja chica';
		END
    END

    RETURN @error_message;
END

