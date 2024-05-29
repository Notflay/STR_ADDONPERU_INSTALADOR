CREATE  PROCEDURE ValOopr

--Oportunidad de Venta

(
	@OpprId				int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@CardCode		nvarchar(15)

	select	@CardCode		= f.CardCode

	from	[dbo].[OOPR] f with(nolock)
	where	f.OpprId = @OpprId


END

