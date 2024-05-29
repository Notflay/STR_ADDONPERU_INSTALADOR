CREATE  PROCEDURE ValOqut

--Oferta de Venta

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@SlpCode		int
		,	@DocTotal		numeric(19,6)
		,	@DocDate		datetime
		,	@DocRate		numeric(19,6)
		,	@CardCode		nvarchar(20)
		,	@GroupNum		int
		,	@DocCur			nvarchar(3)
		,	@Comments		nvarchar(254)
		,	@Count			int
		
	select	@SlpCode		= o.SlpCode
		,	@DocTotal		= o.DocTotal
		,	@DocDate		= o.DocDate
		,	@DocRate		= o.DocRate
		,	@CardCode		= o.CardCode
		,	@GroupNum		= o.GroupNum
		,	@DocCur			= o.DocCur
		,	@Comments		= o.Comments	
	
	from	OQUT o
	where	o.DocEntry = @DocEntry

	--Validar Empleado de Ventas
		--if @SlpCode = -1 and @wddstatus = '-' begin
		--	select	@error = 1
		--	select	@error_message = N'Debe seleccionar Empleado de Ventas.'
		--	return
		--end

return

end

