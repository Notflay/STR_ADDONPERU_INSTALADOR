CREATE FUNCTION RML_TN_APP_CC_ER_24_PAGORECIBIDO
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
		SET @TPORND = (SELECT U_BPP_TIPR FROM ORCT WHERE DocEntry = @id)
		IF @TPORND = 'CCH' OR @TPORND = 'EAR'
		BEGIN
		--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CNT = (SELECT COUNT('E') FROM ORCT WHERE RTRIM(U_BPP_NUMC) = '---' AND "DocEntry" =  @id)
			IF @CNT > 0
			BEGIN
				SET @error_message = 'No se ha seleccionado el nro caja/entrega...'
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		
			--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CTARGT = (SELECT CASE "U_BPP_TIPR" WHEN 'CCH' THEN (SELECT "U_BPP_ACCT" FROM "@BPP_CAJASCHICAS" WHERE "Code" = "U_BPP_CCHI") 
								 			WHEN 'EAR' THEN (SELECT "AcctCode" FROM OACT WHERE "FormatCode" = (SELECT "U_CE_CTPT" FROM "@STR_CCHEAR_SYS" WHERE "Code" = '001')) END 
								 			FROM ORCT WHERE "DocEntry" = @id)	
															
			SET @CTAPGO = (SELECT CashAcct FROM ORCT WHERE DocEntry = @id)
			IF @CTARGT != @CTAPGO 
			BEGIN
				SET @DTOCTA = (SELECT TOP 1 FormatCode + ' - ' + AcctName FROM OACT WHERE AcctCode = @CTARGT)
				SET @error_message = 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' + @DTOCTA
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		END
	END

    RETURN @error_message;
END