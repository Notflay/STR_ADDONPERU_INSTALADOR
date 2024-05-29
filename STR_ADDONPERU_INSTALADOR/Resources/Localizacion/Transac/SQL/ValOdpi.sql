CREATE  PROCEDURE ValOdpi

--Facturas y Solicitudes de anticipo Ventas

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	--variables
	declare	@DocNum			int
		,	@DocDate		datetime
		,	@DiscPrcnt		numeric(19,6)
		,	@DocTotal		numeric(19,6)
		,	@U_STR_RFOV		int

	select	@DocNum			= f.DocNum
		,	@DocDate		= f.DocDate
		,	@DiscPrcnt		= f.DiscPrcnt
		,	@DocTotal		= f.DocTotal
	--	,	@U_STR_RFOV		= f.U_STR_RFOV
		
	from	[dbo].[odpi]	f with(nolock)
	where	f.DocEntry		= @DocEntry


	IF (@TipoTransaccion in ('A','U')) BEGIN

		----------------------------------------------------------------------------------------------------
		--Se debe ingresar un descuento positivo
		----------------------------------------------------------------------------------------------------
		
		if @DiscPrcnt < 0 begin
		
			select	@error = 1
			select	@error_message = N'El descuento debe ser siempre mayor a cero'
			return
		
		end
		
		----------------------------------------------------------------------------------------------------

		----------------------------------------------------------------------------------------------------
		--Monto mayor a 0
		----------------------------------------------------------------------------------------------------
		
		if @DocTotal < 0 begin
		
			select	@error = 2
			select	@error_message = N'El total del documento debe ser mayor a 0'
			return
		
		end
		
		----------------------------------------------------------------------------------------------------

		----------------------------------------------------------------------------------------------------
		--Referencia a la OV
		----------------------------------------------------------------------------------------------------
		
		if ISNULL(@U_STR_RFOV,0) not in 
			(select DocNum from ORDR where DocStatus='O' or DocEntry in (select BaseEntry from DLN1 D1 inner join ODLN D0 on D1.DocEntry=D0.DocEntry and D0.DocStatus='O')) begin
		
			select	@error = 3
			select	@error_message = N'Se debe ingresar la referencia a la OV'
			return
		
		end
		
		----------------------------------------------------------------------------------------------------


	END

END

