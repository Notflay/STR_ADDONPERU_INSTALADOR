CREATE  PROCEDURE ValOpdn

--  Entrada de Mercancia Op

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@NumAtCard		nvarchar(100)
		,	@CardCode		nvarchar(15)
		,	@DiscPrcnt		numeric(19,6)
		,	@GroupNum		smallint
		,	@RoundDif		numeric(19,6)
		   		,	@UserSign2		smallint
		,	@DocTotal		numeric(19,6)
		,	@CANCELED		char(1)
		,	@Series			smallint
		,	@U_STR_CALP		nvarchar(1)
		,	@Usuario		int
		
	--variables del detalle
		,	@VisOrder		int
		,	@cont			int
		
	
	
	select	@NumAtCard		= e.NumAtCard
		,	@CardCode		= e.CardCode
		,	@DiscPrcnt		= e.DiscPrcnt
		,	@GroupNum		= e.GroupNum
		,	@RoundDif		= e.RoundDif
		,	@Usuario		= ISNULL(e.UserSign2,e.UserSign)
		          ,	@UserSign2		= e.UserSign2
		,	@DocTotal		= e.DocTotal
		,	@CANCELED		= e.CANCELED
		,	@Series			= e.Series
	--	,	@U_STR_CALP		= e.U_STR_CALP
		
	from	[dbo].[opdn] e
	where	e.DocEntry = @DocEntry

	
IF (@TipoTransaccion in ('A','U')) Begin
	
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
	

	
		--	validación de crear partidas presupuestales del 2016 sólo para contabilidad

	if @Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Partidas-Pr')
	begin	

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and LEFT(u_str_partidaPr,3) = 'P16'
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'No puede hacer uso de las partidas del 2016 en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end
		end
	

	----------------------------------------------------------------------------------------------------
	--Calificación al proveedor
	----------------------------------------------------------------------------------------------------
	
	--if ISNULL(@U_STR_CALP,'') = '' begin
	
	--	select	@error = 3
	--	select	@error_message = N'Debe ingresar una calificación al proveedor'
	--	return
	
	--end
	
	----------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------
	--Validacion de condicion de pago
	----------------------------------------------------------------------------------------------------
		
	--if (select GroupNum from OCRD where CardCode=@CardCode)!=@GroupNum begin
				
	--	select	@error = 4
	--	select	@error_message = N'Se debe utilizar la condicion de pago del Socio de Negocio: '+
	--	(select PymntGroup from OCTG where GroupNum=(select GroupNum from OCRD where CardCode=@CardCode))
	--	return

	--end

	----------------------------------------------------------------------------------------------------

	
	
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de Centro de Costo es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


		
			set @VisOrder=-776
		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Marca es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		
			set @VisOrder=-775
		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Ciudades - Planta  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--	Validación de poner como obligatorio el campo Descripción CRP

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_descripcion2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 El campo Descripción CRP es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

			-----------valida CCcon tabla CC--------

		declare	@USUARIO_CODIGO		nvarchar(100)
		set @VisOrder=0
		set	@USUARIO_CODIGO =    (select USER_CODE from OUSR where USERID=@UserSign2) 

		select top 1 @VisOrder = VisOrder+1 from PDN1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') not in (
		select U_C_costo from  [dbo].[@STR_CC] where [U_Usuario_VAL] = @USUARIO_CODIGO)

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'No tienes permiso para la dimension en la linea  '+CAST(@VisOrder as nvarchar)
			return
		
		end 
		----








	----------------------------------------------------------------------------------------------------
	--Validacion de redondeo
	----------------------------------------------------------------------------------------------------

	declare @num numeric(10,2)
	set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
	if @RoundDif not between -1*@num and @num begin

		select	@error = 5
		select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
		return

	end

	----------------------------------------------------------------------------------------------------

	if @CANCELED='N' begin

		----------------------------------------------------------------------------------------------------
		--Validación que tengan como base una OC
		----------------------------------------------------------------------------------------------------
		
		declare @SIN_OC varchar(1)


		set  @SIN_OC  =   (  select Qrygroup62 from ocrd  where    CardCode = @CardCode )
		 

		  
		select @cont=COUNT(*)
		from PDN1
		where DocEntry=@DocEntry and ISNULL(BaseType,0)!=22  and   @SIN_OC='N' 
		
		if @cont>0 begin
				
			select	@error = 6
			select	@error_message = N'Las  Conformidades de Servicio/ Entradas deben ser creadas con una Orden de Compra como base'
			return
			
		end

		----------------------------------------------------------------------------------------------------
		--Validación que la condición de pago sea el mismo que la OC
		----------------------------------------------------------------------------------------------------
		
		  
		select @cont=COUNT(*)
		from PDN1 P1
		where DocEntry=@DocEntry and BaseType=22 and @GroupNum!=(SELECT OP.GroupNum FROM OPOR OP WHERE OP.DocEntry=P1.BaseEntry)
		
		if @cont>0 begin
				
			select	@error = 6
			select	@error_message = N'La Condición de pago de la conformidad debe ser la misma que la de la OC original'
			return
			
		end


		----------------------------------------------------------------------------------------------------

		----------------------------------------------------------------------------------------------------
		--Validación que el precio de compra sea igual al precio de compra en la OC
		----------------------------------------------------------------------------------------------------

		if (select RIGHT(SeriesName,3) from NNM1 where Series=@Series)!='SI' begin

			set @VisOrder=-1
			select top 1 @VisOrder=p1.VisOrder+1
			from PDN1 p1
				inner join POR1 r1 on r1.DocEntry=p1.BaseEntry and r1.LineNum=p1.BaseLine
			where p1.DocEntry=@DocEntry and r1.Price<p1.Price

			if @VisOrder>0 begin
		
				select	@error = 7
				select	@error_message = N'En las entradas de mercadería los precios ingresados deben ser menores o iguales a la orden de compra. Linea '+cast(@VisOrder as nvarchar)
				return

			end
	
		end

		----------------------------------------------------------------------------------------------------
	
	end

END

return
END

