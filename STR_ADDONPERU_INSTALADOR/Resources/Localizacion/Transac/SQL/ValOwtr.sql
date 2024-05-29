CREATE  PROCEDURE ValOwtr

--Transferencia de stocks por módulo de inventario

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@Filler			nvarchar(8)
		,	@draftKey		int
	
	--variables detalle
		,	@WhsCode		nvarchar(8)
		,	@cont			int
	
	-- Datos generales
	select	@Filler			= a.Filler
		,	@draftKey		= a.draftKey
	
	from	OWTR a
	where	docentry		= @DocEntry


	--IF (@TipoTransaccion in ('A','U')) BEGIN
		
	--END
	
return

END

