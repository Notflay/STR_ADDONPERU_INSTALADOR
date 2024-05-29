CREATE  PROCEDURE ValOrct

--Pagos recibidos

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare @CardName		varchar(100)
		,	@DocNum			int
		,	@DocType		varchar(1)
		,	@canceled			char(1)
		,	@Series			int
		,	@DocCurr		nvarchar(3)
		,	@DocRate		numeric(19,6)
		,	@TaxDate		datetime
		,	@Comments		varchar(254)
		,	@JrnlMemo		varchar(100)
		,	@SeriesName		varchar(20)
		,	@Usuario		int
		,	@NoDocSum		[numeric](19, 6)
		
	select	@CardName		= p.CardName
		,	@DocNum			= p.DocNum
		,	@DocType		= p.DocType
		,	@canceled		= p.Canceled
		,	@Series			= p.Series
		,	@DocCurr		= p.DocCurr
		,	@DocRate		= p.DocRate
		,	@TaxDate		= p.TaxDate
		,	@Comments		= p.Comments
		,	@JrnlMemo		= p.JrnlMemo
		,	@Usuario		= ISNULL(p.UserSign2,p.UserSign)
		,	@NoDocSum		= p.NoDocSum
		
	from ORCT p with(nolock)
	where docentry = @Docentry


	if (@TipoTransaccion in ('A','U')) begin

		----------------------------------------------------------------------------------------------------
		--No se puede crear pagos con montos negativos en el pago a cuenta
		----------------------------------------------------------------------------------------------------
		
		if @NoDocSum<0 begin

				select	@error = 1
				select	@error_message = N'No se puede crear un PR con un pago a cuenta negavito'

		end
		
		----------------------------------------------------------------------------------------------------		
		----------------------------------------------------------------------------------------------------
		--Se debe respetar el tipo de cambio del día
		----------------------------------------------------------------------------------------------------
		
		--if @DocCurr != (select MainCurncy from OADM) begin

		--	if @DocRate != (select Rate from ORTT where DateDiff(dd,RateDate,@TaxDate)=0 and @DocCurr=Currency) begin
		
		--		select	@error = 1
		--		select	@error_message = N'Se debe respetar el tipo de cambio del día'
		--		return
		
		--	end

		--end
		

		----------------------------------------------------------------------------------------------------
	
		----------------------------------------------------------------------------------------------------
		--Se debe respetar el tipo de cambio del día
		----------------------------------------------------------------------------------------------------
	
		if ( 63911 in (

-- cuenta de transferencia
		SELECT distinct (select segment_0 from OACT where acctcode=TrsfrAcct) AS 'Cuenta'
		FROM ORCT T0
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T0.BpAct) AS 'Cuenta'
		FROM ORCT T0
		WHERE @DocEntry=T0.DocEntry
		
		UNION ALL
		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T1.CheckAct) AS 'Cuenta'
		FROM ORCT T0 INNER JOIN RCT1 T1 ON T0.DocEntry=T1.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL
		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T0.cardcode) AS 'Cuenta'
		FROM ORCT T0 INNER JOIN RCT1 T1 ON T0.DocEntry=T1.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cuenta del proveedor - pago a proveedor
		SELECT distinct (select segment_0 from OACT where acctcode=(SELECT DebPayAcct FROM OCRD OC WHERE OC.CardCode=T0.CardCode)) AS 'Cuenta'
		FROM ORCT T0 INNER JOIN RCT2 T2 ON T0.DocEntry=T2.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cash account
		SELECT distinct (select segment_0 from OACT where acctcode=CashAcct) AS 'Cuenta'
		FROM ORCT T0 
		WHERE @DocEntry=T0.Docentry

		UNION ALL

		-- Cuenta de la transferencia - pago a cuenta
		SELECT distinct (select segment_0 from OACT OA where OA.acctcode=T4.acctcode) AS 'Cuenta'
		FROM ORCT T0 INNER JOIN RCT4 T4 ON T0.DocEntry=T4.DocNum
		WHERE @DocEntry=T0.DocEntry
		)  ) begin 
		
				if @Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Cta-PR&PP') BEGIN
		
					select	@error = 10
					select	@error_message = N'No tiene permisos para crear pago que afecte la cuenta 63911'  
					return
		
				end
				end
				----------------------------------------------------------------------------------------------------
	
			end

	if (@TipoTransaccion in ('C')) begin

		----------------------------------------------------------------------------------------------------
		--Sin permiso para cancelar pagos recibidos
		----------------------------------------------------------------------------------------------------
		
		if @canceled='Y' begin
			
			if (@Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='PERANULPR')) begin

				select	@error = 1
				select	@error_message = N'No tiene permiso para cancelar pagos recibidos'
			end


		end

	end

			return

END

