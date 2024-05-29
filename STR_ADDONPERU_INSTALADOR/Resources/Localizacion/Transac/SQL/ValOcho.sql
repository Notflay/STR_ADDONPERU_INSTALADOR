CREATE  PROCEDURE ValOcho

--Cheques para el pago

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

--SELECT [DBO].[ObtMontoTextoSinMoneda] ('SOL', '1000.00')

return

END

