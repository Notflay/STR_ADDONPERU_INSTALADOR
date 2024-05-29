CREATE  PROCEDURE ValOrpc

--Notas de crédito de compras

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@NumAtCard		nvarchar(100)
		,	@DiscPrcnt		numeric(19,6)
		,	@CardCode		nvarchar(15)
		,	@DocTotal		numeric(19,6)
		,	@CANCELED		char(1)
		,	@U_BPP_MDTD		nvarchar(2)
		,	@U_BPP_MDSD		nvarchar(4)
		,	@U_BPP_MDCD		nvarchar(50)
		,	@U_N_Suministro		nvarchar(50)
		,	@U_Tipo		nvarchar(15)
		,	@U_Fecha_Factura		datetime
	
	--Variables de detalle
		,	@VisOrder		int
		,	@cont			int
		
	select	@NumAtCard		= n.NumAtCard	
		,	@DiscPrcnt		= n.DiscPrcnt
		,	@DocTotal		= n.DocTotal
		,	@CANCELED		=n.CANCELED
		,	@U_BPP_MDTD		= n.U_BPP_MDTD
		,	@U_BPP_MDSD		= n.U_BPP_MDSD
		,	@U_BPP_MDCD		= n.U_BPP_MDCD
		,	@CardCode		= n.CardCode
		,	@U_N_Suministro = n.U_N_Suministro
		,	@U_Tipo			=n.U_Tipo
		,	@U_Fecha_Factura = n.U_Fecha_Factura
		
	from	[dbo].[orpc] n with(nolock)
	where	n.DocEntry = @DocEntry

	
	IF (@TipoTransaccion in ('A','U')) BEGIN

		----------------------------------------------------------------------------------------------------
		--Los campos Número de Suministro, Tipo y Mes de Consumo son olbigatorios
		----------------------------------------------------------------------------------------------------
		
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
		
		----------------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------------
		--No se puede registrar más de una NC para la combinación SN + Número de Suministro + Mes de Consumo
		----------------------------------------------------------------------------------------------------
		
		--if (@CardCode in (select CardCode from ocrd where cardtype='S' AND QryGroup25='Y') AND (ISNULL(@U_N_Suministro,'')<>'') AND @CANCELED='N') begin
		
		--SET @VisOrder=-777
		--SET @VisOrder=(select count(T0.DocEntry) as 'contar'
		--from [ORPC] T0
		--where T0.CardCode=@CardCode AND T0.U_N_Suministro=@U_N_Suministro AND YEAR(T0.U_Fecha_Factura)=YEAR(@U_Fecha_Factura) AND MONTH(T0.U_Fecha_Factura)=MONTH(@U_Fecha_Factura)
		--)
		
		--if ISNULL(@VisOrder,0) > 1 begin
		
		--	select	@error = 10
		--	select	@error_message = N'Ya se creó una Nota de Crédito para el SN '+ CAST(@CardCode as nvarchar(15))+' con suministro '+ CAST(@U_N_Suministro as nvarchar(50))+' en el péríodo '+(CASE WHEN MONTH(@U_Fecha_Factura)<10 THEN '0' ELSE '' END)+cast(MONTH(@U_Fecha_Factura) AS nvarchar(2))+'-'+cast(YEAR(@U_Fecha_Factura) AS nvarchar(4))
		--	return
		
		--end
		
		--end
		
		----------------------------------------------------------------------------------------------------			
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
		--Validar proyectos y dimensiones (V010)
		----------------------------------------------------------------------------------------------------
		
		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RPC1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 3
		--	select	@error_message = N'El campo CECO es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end

		set @VisOrder=-1
		select top 1 @VisOrder = VisOrder+1 from RPC1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''

		if @VisOrder > 0 begin
		
			select	@error = 4
			select	@error_message = N'El campo Tipo de Negocio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-1
		select top 1 @VisOrder = VisOrder+1 from RPC1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 5
			select	@error_message = N'El campo Tipo de Servicio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


		--	Validación de poner como obligatorio el campo Descripción CRP

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from RPC1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_descripcion2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 El campo Descripción CRP es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end
		
		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 
		--from RPC1 i1 inner join OPRC cc on cc.PrcCode=i1.OcrCode2 and cc.U_STR_CLA9!=i1.OcrCode3
		--where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 6
		--	select	@error_message = N'El campo Clase 9 es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end

		----------------------------------------------------------------------------------------------------
		
		--asignar el tipo-serie-correlativo
		if ISNULL(@U_BPP_MDSD,'')!='' and ISNULL(@U_BPP_MDCD,'')!='' begin
			
			set @U_BPP_MDSD=RIGHT('000'+@U_BPP_MDSD,4)
			set @U_BPP_MDCD=RIGHT('000000000'+@U_BPP_MDCD,10)
			set @NumAtCard = @U_BPP_MDTD +'-'+@U_BPP_MDSD+ '-'+@U_BPP_MDCD
			update ORPC set NumAtCard = @NumAtCard,U_BPP_MDSD=@U_BPP_MDSD,U_BPP_MDCD=@U_BPP_MDCD where DocEntry = @DocEntry
			UPDATE JDT1 set  ref2=@NumAtCard where transid =(select top 1 transid from ORPC where DocEntry = @DocEntry )
		end

	END		
	
return

END

