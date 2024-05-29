CREATE  PROCEDURE ValOins

--Tarjetas del equipo del cliente

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@customer		nvarchar(15)
	
	select	@customer		= t0.customer
	
	from OINS t0
	where insID = @DocEntry


	IF (@TipoTransaccion = 'D') begin
	
		select	@error = 1
		select	@error_message = N'No se pueden eliminar tarjetas. '
		return
		
	end

return

END

