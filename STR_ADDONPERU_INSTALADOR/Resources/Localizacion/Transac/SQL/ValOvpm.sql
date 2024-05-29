CREATE  PROCEDURE ValOvpm

--Pagos Efectuados

(
	@DocEntry				int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 
	
	declare @DocNum			int
		,	@DocTotal		numeric(19,6)
		,	@DocType		char(1)
		,	@Status			char(1)
		,	@DocCurr		nvarchar(3)
		,	@DocRate		numeric(19,6)
		,	@TaxDate		datetime
		,	@DataSource		char(1)
		,	@Usuario		int
		,	@CardCode		nvarchar(15)
		,	@U_N_Suministro		nvarchar(50)
		,	@U_Tipo		nvarchar(15)
		,	@U_Fecha_Factura		datetime
		,	@NoDocSum		[numeric](19, 6)

	select	@DocNum			= a.DocNum
		,	@DocTotal		= a.DocTotal
		,	@DocType		= a.DocType
		,	@Status			= a.Status
		,	@DocCurr		= a.DocCurr
		,	@DocRate		= a.DocRate
		,	@TaxDate		= a.TaxDate
		,	@DataSource		= a.DataSource
		,	@Usuario		= ISNULL(a.UserSign2,a.UserSign)
		,	@CardCode		= a.CardCode
		,	@U_N_Suministro = a.U_N_Suministro
		,	@U_Tipo			=a.U_Tipo
		,	@U_Fecha_Factura = a.U_Fecha_Factura
		,	@NoDocSum		= a.NoDocSum
		
	from	OVPM a
		
	where	DocEntry = @DocEntry 

	
	IF @TipoTransaccion='A' BEGIN
	
		if  @DataSource='I' and @DocType = 'S' and @Status='N' begin
		
			if 0<(select COUNT(*) from VPM2 v2 inner join OPCH fa on v2.DocEntry=fa.DocEntry and fa.U_areconciliar='SI' 
			where v2.DocNum=@DocEntry and v2.InvType=18) begin

				select @error=1
				select @error_message=' E00020 Solo pueden pagarse documentos autorizados   '
				return

			end

			if 0<(select COUNT(*) from VPM2 v2 inner join OPCH f0 on v2.DocEntry=f0.DocEntry 
			inner join JDT1 j1 on ISNULL(f0.U_BPP_AstDetrac,'')=j1.TransId and j1.ShortName=f0.CardCode 
			where v2.DocNum=@DocEntry and v2.InvType=18 and BalDueCred>0) begin

				select @error=2
				select @error_message='Se debe pagar primero la detracción  (Pagos efectuados )'
				return

			end

		end



		---------------------------------------

			if     @DocType = 'S' and @Status='Y' begin
		
			if 0<(select COUNT(*) from VPM2 v2 inner join OPCH fa on v2.DocEntry=fa.DocEntry and fa.U_areconciliar='SI' 
			where v2.DocNum=@DocEntry and v2.InvType=18) begin

				select @error=3
				select @error_message=' E00020 Solo pueden pagarse documentos autorizados   '
				return

			end

				if 0<(select COUNT(*) from VPM2 v2 inner join OPCH f0 on v2.DocEntry=f0.DocEntry 
			inner join JDT1 j1 on ISNULL(f0.U_BPP_AstDetrac,'')=j1.TransId and j1.ShortName=f0.CardCode 
			where v2.DocNum=@DocEntry and v2.InvType=18 and BalDueCred>0) begin

		
				select @error=4
				select @error_message='Se debe pagar primero la detracción   (Pagos masivos)'
				return

			end

		end


		----------------------------------------------------------------------------------------------------
		--Se debe respetar el tipo de cambio del día
		----------------------------------------------------------------------------------------------------
		
		if @DocCurr != (select MainCurncy from OADM) begin

			if @DocRate != (select Rate from ORTT where DateDiff(dd,RateDate,@TaxDate)=0 and @DocCurr=Currency) begin
		
				select	@error = 3
				select	@error_message = N'Se debe respetar el tipo de cambio del día'
				return
		
			end

		end
		
		----------------------------------------------------------------------------------------------------

	END
	
	--if @TipoTransaccion = 'C' begin
		
	--	----------------------------------------------------------------------------------------------------
	--	--Para anular un pago necesita una Glosa de Anulacion
	--	----------------------------------------------------------------------------------------------------
		
	--	if ISNULL(@U_STR_GLAN,'')='' begin
		
	--		select @error=99
	--		select @error_message='Para anular un pago es obligatorio una Glosa de Anulacion'
	--		return
		
	--	end
		
	--	----------------------------------------------------------------------------------------------------
	
	--end

	if (@TipoTransaccion in ('A','U')) begin

		----------------------------------------------------------------------------------------------------
		--No se puede crear pagos con montos negativos en el pago a cuenta
		----------------------------------------------------------------------------------------------------
		
		if @NoDocSum<0 begin

				select	@error = 1
				select	@error_message = N'No se puede crear un PP con un pago a cuenta negavito'

		end
		
		----------------------------------------------------------------------------------------------------	
		----------------------------------------------------------------------------------------------------
		--Los campos Número de Suministro, Tipo y Mes de Consumo son olbigatorios
		----------------------------------------------------------------------------------------------------
		
		IF(@DocType='S') begin

			if (@CardCode in (select CardCode from ocrd where cardtype='S' AND QryGroup25='Y')) begin
		
				if ISNULL(@U_N_Suministro,'')='' begin
					select	@error = 1
					select	@error_message = N'El campo Número del suministro es obligatorio'
					return
				END
	
				if (ISNULL(@U_N_Suministro,'')<>'' AND @U_N_Suministro NOT IN (SELECT CAB.U_N_Suministro FROM [@CRP_GSUM_CAB] CAB WHERE CAB.U_Cod_SN=@CardCode UNION ALL SELECT CAB.U_N_Suministro FROM [@CRP_GSUM_CAB] CAB WHERE CAB.U_Cod_SN=(SELECT FatherCard FROM OCRD OC WHERE CardCode=@CardCode) AND U_SN_Consolidado='SI' UNION ALL SELECT 'GASTOS OTROS')) begin
					select	@error = 1
					select	@error_message = N'El Número de suministro no coincide con los suministros válidos para el SN '+   CAST ( @CardCode  AS  VARCHAR(15))
					return
				END

				if ISNULL(@U_Tipo,'')='' begin
					select	@error = 1
					select	@error_message = N'El campo Tipo de suministro es obligatorio'
					return
				END

				if ISNULL(@U_Fecha_Factura,'')='' begin
					select	@error = 1
					select	@error_message = N'El campo Mes de consumo es obligatorio'
					return
				END
		
			end
		
		END
		
		----------------------------------------------------------------------------------------------------

			if ( 63911 in (

		-- cuenta de transferencia
		SELECT distinct (select segment_0 from OACT where acctcode=TrsfrAcct) AS 'Cuenta'
		FROM OVPM T0
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T0.BpAct) AS 'Cuenta'
		FROM OVPM T0
		WHERE @DocEntry=T0.DocEntry
		
		UNION ALL
		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T1.CheckAct) AS 'Cuenta'
		FROM OVPM T0 INNER JOIN VPM1 T1 ON T0.DocEntry=T1.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL
		-- Cuenta cuenta
		SELECT distinct (select segment_0 from OACT where acctcode=T0.cardcode) AS 'Cuenta'
		FROM OVPM T0 INNER JOIN VPM1 T1 ON T0.DocEntry=T1.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cuenta del proveedor - pago a proveedor
		SELECT distinct (select segment_0 from OACT where acctcode=(SELECT DebPayAcct FROM OCRD OC WHERE OC.CardCode=T0.CardCode)) AS 'Cuenta'
		FROM OVPM T0 INNER JOIN VPM2 T2 ON T0.DocEntry=T2.DocNum
		WHERE @DocEntry=T0.DocEntry

		UNION ALL

		-- Cash account
		SELECT distinct (select segment_0 from OACT where acctcode=CashAcct) AS 'Cuenta'
		FROM OVPM T0 
		WHERE @DocEntry=T0.Docentry

		UNION ALL

		-- Cuenta de la transferencia - pago a cuenta
		SELECT distinct (select segment_0 from OACT OA where OA.acctcode=T4.acctcode) AS 'Cuenta'
		FROM OVPM T0 INNER JOIN VPM4 T4 ON T0.DocEntry=T4.DocNum
		WHERE @DocEntry=T0.DocEntry
		)  ) begin 
		
				if @Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Cta-PR&PP') BEGIN
		
					select	@error = 10
					select	@error_message = N'No tiene permisos para crear pago que afecte la cuenta 63911'  
					return
		
				end
				end

	END
	
return

END

