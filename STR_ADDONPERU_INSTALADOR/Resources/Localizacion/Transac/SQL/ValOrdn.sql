CREATE  PROCEDURE ValOrdn

--Devoluciones de ventas

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 


	--IF (@TipoTransaccion in ('A','U'))
	--begin

	--end

return

END

