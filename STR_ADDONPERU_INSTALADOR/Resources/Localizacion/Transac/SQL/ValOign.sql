CREATE  PROCEDURE ValOign

--Entrada de mercancías por módulo de inventario

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@NumAtCard		nvarchar(100)
		,	@U_STR_TIPO_ENT	nvarchar(30)
	
	select	@NumAtCard		= e.U_BPP_MDTS
		--,	@U_STR_TIPO_ENT	= e.U_STR_TIPO_ENT
	
	from	[dbo].[oign] e
	where	e.DocEntry = @DocEntry

	IF @TipoTransaccion in ('A','U') BEGIN

		if ISNULL(@U_STR_TIPO_ENT,'') = '' begin

			select	@error = 1
			select	@error_message = N'El tipo de entrada de inventario es obligatorio'
			return

		end

	END

	return
	
END

