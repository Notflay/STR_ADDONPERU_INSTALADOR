CREATE  PROCEDURE ValOscl

--Llamadas de servicio

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)

AS  
BEGIN 

	declare	@status			smallint
		,	@callType		smallint
		,	@problemTyp		smallint	
		,   @itemCode		nvarchar(20)	
		,   @customer		nvarchar(15)		
		,   @internalSN		nvarchar(32)	

	select	@status			= t0.status 
		,	@callType		= t0.callType
		,	@problemTyp		= t0.problemTyp
		,	@itemCode		= t0.itemCode
		,	@customer		= t0.customer
		,	@internalSN		= t0.internalSN
	
	from	OSCL t0
	where	t0.CallId = @DocEntry


return

END

