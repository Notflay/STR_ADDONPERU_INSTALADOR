CREATE  PROCEDURE ValOmrv

--Revalorización

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@DocDate		datetime

	select	@DocDate		= f.DocDate

	from	OMRV f with(nolock)
	where	f.DocEntry = @DocEntry

return
END

