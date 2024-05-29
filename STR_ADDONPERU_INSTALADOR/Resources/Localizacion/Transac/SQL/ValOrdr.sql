CREATE  PROCEDURE ValOrdr

--Orden de venta

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed

)

AS  

BEGIN 

------------------------------------------------------------------------------------------------
--Declaración y captura de variables
------------------------------------------------------------------------------------------------
	declare @DocNum			int	
		,	@CardCode		nvarchar(15)
		--,	@CardName		nvarchar(100)
		,	@DocDate		datetime
		--,	@DocDueDate		datetime
		--,	@TaxDate		datetime
		,	@draftKey		int
		,	@DocTotal		numeric(19,6)
		,	@Series			smallint
		,	@UserSign		int
		,	@DiscPrcnt		numeric(19,6)
		,	@GroupNum		smallint
		,	@RoundDif		numeric(19,6)
		,	@AtcEntry		int
		,	@PoPrss			char
		,	@U_STR_DSCTO	char(1)
		,	@U_STR_PPTO		char(1)
		,	@U_STR_ADIC		char(1)
		,	@U_STR_CNTG		char(1)
		--variables del detalle
		,	@VisOrder		int
		--variables de otras tablas
		,	@cont			int
		,	@CPaux			nvarchar(20)
		,	@ItmsGrpNam		nvarchar(20)
		,	@SeriesName		nvarchar(20)
		,	@cntg			nvarchar(8)
				,	@DocType			 char(1)
	
	select	@DocNum			= f.DocNum
		,	@CardCode		= f.CardCode
		--,	@CardName		= f.CardName
		,	@DocDate		= f.DocDate
		--,	@DocDueDate		= f.DocDueDate
		--,	@TaxDate		= f.TaxDate
		,	@draftKey		= f.draftKey
		,	@DocTotal		= f.DocTotal
		,	@Series			= f.Series
		,	@UserSign		= f.UserSign
		,	@DiscPrcnt		= f.DiscPrcnt
		,	@GroupNum		= f.GroupNum
		,	@RoundDif		= f.RoundDif
		,	@AtcEntry		= f.AtcEntry
		,	@PoPrss			= f.PoPrss
		,	@DocType		= f.DocType
	--	,	@U_STR_DSCTO	= f.U_STR_DSCTO
	--	,	@U_STR_PPTO		= f.U_STR_PPTO
	--	,	@U_STR_ADIC		= f.U_STR_ADIC
	--	,	@U_STR_CNTG		= f.U_STR_CNTG
		
	from	[dbo].[Ordr]	f with(nolock)
	where	f.DocEntry		= @DocEntry
	
------------------------------------------------------------------------------------------------------------
--Validaciones
------------------------------------------------------------------------------------------------------------
	IF (@TipoTransaccion in ('A','U')) BEGIN
	



		----------------------------
		----------------------------------------------------------------------------------------------------
		--Monto mayor a 0
		----------------------------------------------------------------------------------------------------
		
	

		----------------------------------------------------------------------------------------------------
		--Se debe ingresar un descuento positivo
		----------------------------------------------------------------------------------------------------
		
		--if @DiscPrcnt < 0 begin
		--	select	@error = 1
		--	select	@error_message = N'El descuento debe ser siempre mayor a cero'
		--	return
		--END
		 
		 ------------------------------------------------- 
		 ----solo se acepta tipo de documento Articulo----
		 -------------------------------------------------

			if @DocType <>  'I' begin
			select	@error = 1 
			select	@error_message = N'El documento debe ser de tipo Articulo  '
			return
		     
			 end
		 


		 	if @DocTotal = 0 begin
				
			select	@error = 2
			select	@error_message = N'El total del documento debe ser mayor a 0  '
			return		
		     end


		--	 		set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 3
		--	select	@error_message = N'La dimension de Cliente es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end
 
	 --- SOLICITA PROYECTO CUANDO es CC 7  ---70415   70417

 		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		and  i1.AcctCode in ( '_SYS00000005983','_SYS00000005985' )
		
	--	select* from RDR1

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E001 El campo proyecto es obligatorio para la cuentas de mayor  70415  , 70417  en linea -> '+CAST(@VisOrder as nvarchar)
			return
		
		end
	 
	 


		----------------------------------------------------------------------------------------------------
		--Validar proyectos y dimensiones (V010)
		----------------------------------------------------------------------------------------------------
		
	

		--set @CPaux=(select Top 1 Project from RDR1 where DocEntry = @DocEntry)
		
 



		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 4
		--	select	@error_message = N'La dimension de Servicio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end
		
		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
	
		--if @VisOrder > 0 begin
		
		--	select	@error = 5
		--	select	@error_message = N'La dimension cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end


		
		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
	
		--if @VisOrder > 0 begin
		
		--	select	@error = 6
		--	select	@error_message = N'La dimension Ejecutor es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end

			
		--set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
	
		--if @VisOrder > 0 begin
		
		--	select	@error = 7
		--	select	@error_message = N'La dimension Rubro es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end



		--	set @VisOrder=-1
		--select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 8
		--	select	@error_message = N'El campo Mandato es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end






		
end


		 
		
		 
		   
		--	--Para el artículo de bolsa-cch debe de tener un precio de compra
		--	--set @VisOrder=-1
		--	--select Top 1 @VisOrder=r1.VisOrder+1
		--	--from RDR1 r1
		--	--	inner join OITM ar on ar.ItemCode=r1.ItemCode
		--	--where ar.QryGroup1='Y' and ISNULL(r1.U_STR_PUPR,0)<=0 and r1.DocEntry=@DocEntry

		--	--if @VisOrder!=-1 begin

		--	--	select	@error = 15
		--	--	select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe ingresar un precio de compra valido'
		--	--	return

		--	--end

		--	--Validacion para respetar el precio de venta
		--	--sin contar los articulo de incremento de fee
		--	set @VisOrder=-1
		--	select Top 1 @VisOrder=r1.VisOrder+1
		--	from RDR1 r1
		--		inner join OITM ar on ar.ItemCode=r1.ItemCode
		--		inner join OPRJ PRY on PRY.PrjCode=r1.Project
		--		inner join [@STR_PORC_INC] PIN on PIN.Code=PRY.U_STR_PINC
		--	where ar.QryGroup2='N' and r1.DocEntry=@DocEntry and 
		--	ROUND((1+PIN.U_STR_VALOR+case when ar.QryGroup1='Y' then 
		--		(select CAST(U_STR_VALOR as numeric(19,6)) from [@STR_PARAM] where Code='CCHPORINC') else 0 end+
		--		case when (select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OCRD sn on cp.GroupNum=sn.GroupNum where sn.CardCode=r1.FreeTxt)>
		--					(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OPRJ pr on cp.GroupNum=pr.U_STR_CONP where pr.PrjCode=r1.Project) then 
		--				(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OCRD sn on cp.GroupNum=sn.GroupNum where sn.CardCode=r1.FreeTxt)-
		--				(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OPRJ pr on cp.GroupNum=pr.U_STR_CONP where pr.PrjCode=r1.Project) else 0 end*
		--		(select CAST(U_STR_VALOR as numeric(19,6)) from [@STR_PARAM] where Code='CPPORINC'))*ISNULL(r1.U_STR_PUPR,0),2)
		--	!= ROUND(r1.PriceBefDi,2)
			
			
		--	--if @VisOrder!=-1 begin

		--	--	select	@error = 16
		--	--	select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe utilizar un precio de venta automático'
		--	--	return

		--	--end

		--	--Para el artículo de incremento de fee
		--	set @VisOrder=-1
		--	select Top 1 @VisOrder=r1.VisOrder+1
		--	from RDR1 r1
		--		inner join OITM ar on ar.ItemCode=r1.ItemCode
		--	where ar.QryGroup2='Y' and ISNULL(r1.PriceBefDi,0)<=0 and r1.DocEntry=@DocEntry

		--	--if @VisOrder!=-1 begin

		--	--	select	@error = 17
		--	--	select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe ingresar un precio de venta valido'
		--	--	return

		--	--end

		--	--Validar la aprobacion del descuento
		--	if ISNULL(@U_STR_DSCTO,'N')='N' begin

		--		set @VisOrder=-1
		--		select Top 1 @VisOrder=r1.VisOrder+1
		--		from RDR1 r1
		--		where r1.DiscPrcnt>0 and r1.DocEntry=@DocEntry

		--		--if @VisOrder!=-1 begin

		--		--	select	@error = 18
		--		--	select	@error_message = N'Línea ' + CAST(@VisOrder as nvarchar) + ' Debe solicitar autorización para descuento'
		--		--	return

		--		--end

		--	end

		--	--Validar que tenga adjunto
		--	--if (select COUNT(*) from ATC1 where AbsEntry=@AtcEntry)<=0 begin

		--	--	select	@error = 19
		--	--	select	@error_message = N'Se debe adjuntar la aprobación del cliente'
		--	--	return

		--	--end
			
		--	--Todas los PV deben pasar por aprobación
		--	--if @draftKey is null begin
				
		--	--	select	@error = 20
		--	--	select	@error_message = N'Los presupuestos variables deben pasar por proceso de aprobación'
		--	--	return
			
		--	--end

			
		----Ordenes de: Consumo Operativo / Plataforma / Consumo interno / Corporativo
		--end else begin

		--	--Usar cliente interno de consumo
		--	--if (select QryGroup1 from OCRD where CardCode=@CardCode)='N' begin
				
		--	--	select	@error = 21
		--	--	select	@error_message = N'Las órdenes de consumo requieren de un cliente para orden de consumo'
		--	--	return
			
		--	--end

		--	--Uso de tipo de servicio contingencia
		--	if ISNULL(@U_STR_CNTG,'N')='N' begin
				
		--		set @VisOrder=-1
		--		select Top 1 @VisOrder=r1.VisOrder+1
		--		from RDR1 r1
		--		where r1.OcrCode2=@cntg and r1.DocEntry=@DocEntry

		--		--if @VisOrder!=-1 begin
				
		--		--	select	@error = 22
		--		--	select	@error_message = N'El uso del tipo de servicio contingencia requiere autorización. Linea '+ CAST(@VisOrder as nvarchar)
		--		--	return
			
		--		--end

		--	end

		--	--Ingresar un Tipo y numero de presupuesto
		--	--set @VisOrder=-1
		--	--select Top 1 @VisOrder=VisOrder+1 from RDR1 
		--	--where DocEntry=@DocEntry and (ISNULL(U_STR_NROP,0)=0 or ISNULL(U_STR_TIPP,'') not in ('E','P'))
			
		--	--if @VisOrder>0 begin

		--	--	set @error_message = 'Se debe ingresar el tipo y número de presupuesto en la línea '+CAST(@VisOrder as nvarchar)
		--	--	set @error = 23
		--	--	return

		--	--end

		--	--Ordenes de Venta Plataforma
		--	if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERPTF001') begin
			
		--		set @VisOrder=-1
		--		select top 1 @VisOrder = VisOrder+1 from RDR1 i1 where i1.DocEntry = @DocEntry and Project != @CPaux
		
		--		--if @VisOrder > 0 begin
		
		--		--	select	@error = 4
		--		--	select	@error_message = N'El campo CECO debe ser igual en todas las lineas: '+CAST(@VisOrder as nvarchar)
		--		--	return
		
		--		--end

		--	--	--Validacion para OV de plataforma
		--	--	select r1.U_STR_TIPP TipoPpto,r1.U_STR_NROP NroPpto,r1.Project CECO,r1.OcrCode TipoNeg,r1.OcrCode2 TipoServ,SUM(LineTotal) tot
		--	--	into #tmppla
		--	--	from RDR1 r1
		--	--		inner join OPRJ pr on pr.PrjCode=r1.Project
		--	--	where r1.DocEntry=@DocEntry
		--	--	group by r1.U_STR_TIPP,r1.U_STR_NROP,r1.Project,r1.OcrCode,r1.OcrCode2
			
		--	--	select top 1 @ItmsGrpNam=t1.TipoServ
		--	--	from #tmppla t1
		--	--	where t1.tot--Actual
		--	--			+
		--	--			--Ejecutado de OVs (Todas menos ppto Variable)
		--	--			ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
		--	--					from RDR1 r1
		--	--						inner join ORDR r0 on r0.DocEntry=r1.DocEntry
		--	--						inner join NNM1 n1 on n1.Series=r0.Series
		--	--					where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and
		--	--						RIGHT(SeriesName,3)!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001') and
		--	--						r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0)
		--	--			+
		--	--			--Ejecutado de Fact Prov (Directas)
		--	--			ISNULL((select SUM(p1.LineTotal)
		--	--					from PCH1 p1
		--	--						inner join OPCH p0 on p0.DocEntry=p1.DocEntry
		--	--						inner join NNM1 n1 on n1.Series=p0.Series
		--	--					where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and
		--	--						RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
		--	--					and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
		--	--		+
		--	--		--Ejecutado de Fact Prov (CCH/EAR)
		--	--		ISNULL((select SUM(p1.LineTotal)
		--	--				from [@BPP_CCHEARDET] ccd
		--	--					inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
		--	--					inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
		--	--					inner join OITM ar on ar.ItemCode=p1.ItemCode
		--	--				where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
		--	--					ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
		--	--			+
		--	--			--Ejecutado de Asientos (Manuales)
		--	--			ISNULL((select SUM(j1.Debit-j1.Credit) 
		--	--					from JDT1 j1
		--	--						inner join OJDT j0 on j0.TransId=j1.TransId
		--	--						inner join NNM1 n1 on n1.Series=j0.Series
		--	--					where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and
		--	--						RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
		--	--						j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
		--	--			> 
		--	--			--Presupuesto Global
		--	--			case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
		--	--													from [@STR_PPTO_DET] p1 
		--	--														inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
		--	--													where p1.U_STR_CC2=t1.TipoServ and U_STR_EST='A' and p0.DocNum=t1.NroPpto and 
		--	--														ISNULL(p1.U_STR_DIST,'')='' and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
		--	--								when 'P' then ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
		--	--													from RDR1 r1
		--	--														inner join ORDR r0 on r0.DocEntry=r1.DocEntry
		--	--														inner join NNM1 n1 on n1.Series=r0.Series
		--	--													where r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and r0.CANCELED='N'
		--	--														and r0.DocNum=t1.NroPpto and RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001')),0)
		--	--			else 0 end
			
		--	--	if ISNULL(@ItmsGrpNam,'')!='' begin

		--	--		select	@error = 24
		--	--		select	@error_message = N'No se puede exceder el presupuesto asignado para plataforma'
		--	--		return

		--	--	end
			
		--	----Ordenes de: Consumo Operativo / Consumo interno / Corporativo
		--	--end else begin

		--	--	--Solo para las series de consumo operativo
		--	--	if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERCON001') begin

		--	--		--Todas las series de consumo operativo pasar por aprobación
		--	--		if @draftKey is null begin
				
		--	--			select	@error = 25
		--	--			select	@error_message = N'Las órdenes de consumo operativo deben pasar por proceso de aprobación'
		--	--			return
			
		--	--		end

		--	--	end

		--		--Obtener el sumarizado de la OV actual
		--		--select r1.U_STR_TIPP TipoPpto,r1.U_STR_NROP NroPpto,r1.Project CECO,r1.OcrCode TipoNeg,r1.OcrCode2 TipoServ,ar.ItmsGrpCod,ga.ItmsGrpNam,
		--		--	ct.AcctCode,LEFT(ct.FormatCode,7) cta,SUM(U_STR_PUPR*Quantity) tot
		--		--into #tmp
		--		--from RDR1 r1
		--		--	inner join OITM ar on ar.ItemCode=r1.ItemCode
		--		--	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
		--		--	inner join OACT ct on ct.AcctCode=case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) else ga.ExpensesAc end
		--		--where r1.DocEntry=@DocEntry
		--		--group by r1.U_STR_TIPP,r1.U_STR_NROP,r1.Project,r1.OcrCode,r1.OcrCode2,ar.ItmsGrpCod,ga.ItmsGrpNam,ct.AcctCode,ct.FormatCode
			
		--		----Validacion del presupuesto Global: Actual + ejecutado < PPTO Acumulado
		--		--select top 1 @ItmsGrpNam=t1.ItmsGrpNam
		--		--from #tmp t1
		--		--where t1.tot--Actual
		--		--		+ 
		--		--	--Ejecutado de OVs (Todas menos ppto Variable)
		--		--	ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity) 
		--		--			from RDR1 r1 
		--		--				inner join ORDR r0 on r0.DocEntry=r1.DocEntry
		--		--				inner join OITM ar on ar.ItemCode=r1.ItemCode
		--		--			where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and 
		--		--				ar.ItmsGrpCod=case when r1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--		--				t1.AcctCode=case when r1.OcrCode2=@cntg then t1.AcctCode else 
		--		--								case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
		--		--								else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end end and
		--		--				r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
		--		--	+
		--		--	--Ejecutado de Fact Prov (Directas)
		--		--	ISNULL((select SUM(p1.LineTotal)
		--		--			from PCH1 p1
		--		--				inner join OPCH p0 on p0.DocEntry=p1.DocEntry
		--		--				inner join NNM1 n1 on n1.Series=p0.Series
		--		--				inner join OITM ar on ar.ItemCode=p1.ItemCode
		--		--			where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
		--		--				ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--		--				p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
		--		--				RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
		--		--				and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
		--		--	+
		--		--	--Ejecutado de Fact Prov (CCH/EAR)
		--		--	ISNULL((select SUM(p1.LineTotal)
		--		--			from [@BPP_CCHEARDET] ccd
		--		--				inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
		--		--				inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
		--		--				inner join OITM ar on ar.ItemCode=p1.ItemCode
		--		--			where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
		--		--				ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--		--				p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
		--		--				ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
		--		--	+
		--		--	--Ejecutado de Asientos (Manuales)
		--		--	ISNULL((select SUM(j1.Debit-j1.Credit) 
		--		--			from JDT1 j1
		--		--				inner join OJDT j0 on j0.TransId=j1.TransId
		--		--				inner join NNM1 n1 on n1.Series=j0.Series
		--		--			where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and 
		--		--				j1.Account=case when j1.OcrCode2=@cntg then j1.Account else t1.AcctCode end and
		--		--				RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
		--		--				j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
		--		--	>
		--		--	--PPTO Acumulado
		--		--	case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
		--		--										from [@STR_PPTO_DET] p1 
		--		--											inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
		--		--										where p1.U_STR_CC2=t1.TipoServ and U_STR_EST='A' and ISNULL(p1.U_STR_DIST,'')='' and
		--		--											ISNULL(p1.U_STR_GRPA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_GRPA,'') else t1.ItmsGrpCod end and
		--		--											ISNULL(p1.U_STR_CTA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_CTA,'') else t1.cta end and  
		--		--											p0.DocNum=t1.NroPpto and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
		--		--					else 0 end--No se puede utilizar un ppto variable
										
		--		--if ISNULL(@ItmsGrpNam,'')!='' begin

		--		--	select	@error = 26
		--		--	select	@error_message = N'Se esta excediendo el presupuesto global en el grupo '+@ItmsGrpNam
		--		--	return

		--		--end

		--		--Debe tener autorización para excederse del presupuesto del periodo
		--		if @U_STR_PPTO='N' begin

		--			----comparar el actual + ejecutado < ppto acumulado
		--			-- select top 1 @ItmsGrpNam=t1.ItmsGrpNam
		--			--from #tmp t1
		--			--where t1.tot --Actual
		--			--	+
		--			----Ejecutado de OVs (Todas menos ppto Variable)
		--			--ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity) 
		--			--		from RDR1 r1 
		--			--			inner join ORDR r0 on r0.DocEntry=r1.DocEntry
		--			--			inner join OITM ar on ar.ItemCode=r1.ItemCode
		--			--		where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and 
		--			--			ar.ItmsGrpCod=case when r1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--			--			t1.AcctCode=case when r1.OcrCode2=@cntg then t1.AcctCode else 
		--			--							case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
		--			--							else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end end and
		--			--			r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
		--			--+
		--			----Ejecutado de Fact Prov (Directas)
		--			--ISNULL((select SUM(p1.LineTotal)
		--			--		from PCH1 p1
		--			--			inner join OPCH p0 on p0.DocEntry=p1.DocEntry
		--			--			inner join NNM1 n1 on n1.Series=p0.Series
		--			--			inner join OITM ar on ar.ItemCode=p1.ItemCode
		--			--		where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
		--			--			ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--			--			p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
		--			--			RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
		--			--			and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
		--			--+
		--			----Ejecutado de Fact Prov (CCH/EAR)
		--			--ISNULL((select SUM(p1.LineTotal)
		--			--		from [@BPP_CCHEARDET] ccd
		--			--			inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
		--			--			inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
		--			--			inner join OITM ar on ar.ItemCode=p1.ItemCode
		--			--		where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
		--			--			ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
		--			--			p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
		--			--			ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
		--			--+
		--			----Ejecutado de Asientos (Manuales)
		--			--ISNULL((select SUM(j1.Debit-j1.Credit) 
		--			--		from JDT1 j1
		--			--			inner join OJDT j0 on j0.TransId=j1.TransId
		--			--			inner join NNM1 n1 on n1.Series=j0.Series
		--			--		where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and 
		--			--			j1.Account=case when j1.OcrCode2=@cntg then j1.Account else t1.AcctCode end and
		--			--			RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
		--			--			j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
		--			-->
		--			----PPTO Acumulado
		--			--case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
		--			--									from [@STR_PPTO_DET] p1 
		--			--										inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
		--			--									where CONVERT(date,U_STR_PER+'-01')<=@DocDate and p1.U_STR_CC2=t1.TipoServ and 
		--			--										ISNULL(p1.U_STR_DIST,'')='' and U_STR_EST='A' and 
		--			--										ISNULL(p1.U_STR_GRPA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_GRPA,'') else t1.ItmsGrpCod end and
		--			--										ISNULL(p1.U_STR_CTA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_CTA,'') else t1.cta end and 
		--			--										p0.DocNum=t1.NroPpto and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
		--			--				else 0 end--No se puede utilizar un ppto variable
				
		--			if ISNULL(@ItmsGrpNam,'')!='' begin

		--				select	@error = 27
		--				select	@error_message = N'Se esta excediendo el presupuesto del periodo en el grupo '+@ItmsGrpNam
		--				return

		--			end

		--		end

		--	end

		--end

		------------------------------------------------------------------------------------------------------
	
			------------------------------------
		----solo se acepta tipo de documento Articulo

		----------------------
	

------------------------------------------------------------------------------------------------------------

END

 