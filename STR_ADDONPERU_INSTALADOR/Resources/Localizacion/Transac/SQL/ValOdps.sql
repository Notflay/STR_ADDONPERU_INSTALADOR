CREATE  PROCEDURE ValOdps

--Depósitos

(
	@DeposId			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@DeposType		nvarchar(1)
		,	@DpsBank		nvarchar(30)
		,	@DpsBankNam		nvarchar(32)
		,	@DeposAcct		nvarchar(50)
		,	@DeposBrnch		nvarchar(50)
		,	@BoeNum			int
		,	@BanckAcct		nvarchar(15)
		,	@CheckNum		int
		,	@DeposDate		datetime

	select	@DeposType		= DeposType
		,	@DpsBank		= DpsBank
		,	@DeposAcct		= DeposAcct
		,	@DeposBrnch		= DeposBrnch
		,	@BanckAcct		= BanckAcct
		,	@DeposDate		= DeposDate
	from	odps
	where	DeposId = @DeposId

	--K cheques
	--B letras

	return

END

