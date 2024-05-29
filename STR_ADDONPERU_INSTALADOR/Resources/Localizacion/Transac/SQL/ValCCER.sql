CREATE  PROCEDURE ValCCER

--Cargar Documento Caja Chica - ER

(
	@DocEntry			nvarchar(30)
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)

AS  
BEGIN 


	declare	@U_BPP_TpRd		nvarchar(3)
		,	@U_BPP_NbCE		nvarchar(100)
		,	@U_BPP_NmCE		nvarchar(100)
		
	--variables del detalle
		,	@U_BPP_MDTD		nvarchar(2)
		,	@U_BPP_MDSD		nvarchar(4)
		,	@U_BPP_MDCD		nvarchar(20)
		
	--otras variables
		,	@cont			int
		,	@VisOrder		int
		,	@numac			nvarchar(255)
		,	@ItmsGrpNam		nvarchar(20)
		,	@cntg			nvarchar(8)
		--,	@U_BPP_CgPv		nvarchar(15)
	
	select	@U_BPP_TpRd		= f.U_BPP_TpRd
		,	@U_BPP_NbCE		= f.U_BPP_NbCE
		,	@U_BPP_NmCE		= f.U_BPP_NmCE
	
	from [@BPP_CCHEAR] f
	where DocEntry=@DocEntry

	--select	@U_BPP_CgPv		= fd.U_BPP_CgPv
	
	--from [@BPP_CCHEARDET] fd
	--where DocEntry=@DocEntry

	IF (@TipoTransaccion in ('A','U')) BEGIN

		----------------------------------------------------------------------------------------------------
		--Usar proveedor autorizado
		----------------------------------------------------------------------------------------------------
		
		--declare @aux nvarchar(100)
		--set @VisOrder=-1
		--select top 1 @VisOrder=dd.VisOrder+1,@aux=cast(sn.CardCode as nvarchar)
		--from [@BPP_CCHEARDET] dd
		--	inner join OCRD sn on sn.CardCode=dd.U_BPP_CgPv
		--where sn.GroupCode!=(select U_STR_VALOR from [@STR_PARAM] where Code='CODGRPRTEM') and QryGroup2='N'
		--	and dd.DocEntry=@DocEntry --and U_BPP_ID='Y'
		
		--if @VisOrder>0 begin
				
		--	select	@error = 1
		--	select	@error_message = N'___Los documentos de caja chica solo pueden ingresarse con un proveedor temporal'
		--	return
			
		--end
		

		-----------------------------------------
		----------------------------------------

		---- MONTO MAXIMO 700 Soles ---------
		---------------------------------------- 

		--set @VisOrder=-1
		--select top 1 @VisOrder=dd.VisOrder+1 
		--from [@BPP_CCHEARDET] dd
		 
		--where  dd.DocEntry=@DocEntry  and U_BPP_MtBs >= 700   --and U_BPP_ID='Y' and 
		
		-- if @VisOrder>0 begin
				 
		--	select	@error = 2
		--	select	@error_message = N'Los documentos de caja chica solo pueden tener un monto maximo de 700 Soles '
		--	return
		--end

		----------------------------------------------
		-----------------------------------------------
		-----------------------------------------------

		----------------------------------------------------------------------------------------------------
		
		----------------------------------------------------------------------------------------------------
		--Validación de numeración duplicada SUNAT
		----------------------------------------------------------------------------------------------------
		--set @cont=-1
		--select top 1 @numac=dd.U_BPP_CgPv+' '+RIGHT('0'+dd.U_BPP_MDTD,2)+'-'+RIGHT('000'+dd.U_BPP_MDSD,4)+'-'+RIGHT('000000000'+dd.U_BPP_MDCD,10),
		--	@cont=COUNT(*)+ISNULL(fa.DocEntry,0)
		----select *--,RIGHT('0'+dd.U_BPP_MDTD,2)+'-'+RIGHT('000'+dd.U_BPP_MDSD,4)+'-'+RIGHT('000000000'+dd.U_BPP_MDCD,10),COUNT(*)
		--from [@BPP_CCHEARDET] dd --where dd.DocEntry=4
		--	left join OPCH fa on dd.U_BPP_CgPv=fa.CardCode and
		--			RIGHT('0'+fa.U_BPP_MDTD,2)=RIGHT('0'+dd.U_BPP_MDTD,2) and 
		--			RIGHT('000'+fa.U_BPP_MDSD,4)=RIGHT('000'+dd.U_BPP_MDSD,4) and 
		--			RIGHT('000000000'+fa.U_BPP_MDCD,10)=RIGHT('000000000'+dd.U_BPP_MDCD,10)
		--where dd.DocEntry=@DocEntry and U_BPP_ID='Y' and ISNULL(dd.U_BPP_DEDc,'')=''
		--group by dd.U_BPP_CgPv,RIGHT('0'+dd.U_BPP_MDTD,2),RIGHT('000'+dd.U_BPP_MDSD,4),RIGHT('000000000'+dd.U_BPP_MDCD,10),fa.DocEntry
		--having COUNT(*)+ISNULL(fa.DocEntry,0)>1

		--if @cont>1 begin
		
		--	set @error_message = 'El número SUNAT '+@numac+' ya está registrado'
		--	set @error = 2
		--	return

		--end

		----------------------------------------------------------------------------------------------------


		----------------------------------------------------------------------------------------------------
		--Validación de presupuesto
		----------------------------------------------------------------------------------------------------

		--set @VisOrder=-1
		--select Top 1 @VisOrder=VisOrder+1 from [@BPP_CCHEARDET] 
		--where  DocEntry=@DocEntry --and U_BPP_ID='Y' 
		--	and (ISNULL(U_BPP_Cmp1,'') not in ('E','P') or ISNULL(U_BPP_Cmp2,'')='') 
		
		--if @VisOrder>0 begin

		--	set @error_message = 'Se debe ingresar el tipo y número de presupuesto en la línea '+CAST(@VisOrder as nvarchar)
		--	set @error = 3
		--	return

		--end
		
		--set @cntg=(select U_STR_VALOR from [@STR_PARAM] where Code='TSCONTING')

		----obtener el sumarizado de la carga de documentos
		--select r1.U_BPP_Cmp1 TipoPpto,r1.U_BPP_Cmp2 NroPpto,r1.U_BPP_PjDc CECO,r1.U_BPP_DIM1 TipoNeg,r1.U_BPP_DIM2 TipoServ,ar.ItmsGrpCod,ga.ItmsGrpNam,
		--	ct.AcctCode,U_BPP_FcCt DocDate,LEFT(ct.FormatCode,7) cta,SUM(U_BPP_MtBs/(1+Rate/100.0)) tot
		--into #tmp--select *
		--from [@BPP_CCHEARDET] r1
		--	inner join OITM ar on ar.ItemCode=r1.U_BPP_CgAr
		--	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
		--	inner join OACT ct on ct.AcctCode=case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) else ga.ExpensesAc end
		--	inner join OSTC im on im.Code=U_BPP_IpDc
		--where r1.DocEntry=@DocEntry --and U_BPP_ID='Y'
		--group by r1.U_BPP_Cmp1,r1.U_BPP_Cmp2,r1.U_BPP_PjDc,r1.U_BPP_DIM1,r1.U_BPP_DIM2,ar.ItmsGrpCod,ga.ItmsGrpNam,ct.AcctCode,U_BPP_FcCt,ct.FormatCode
		
		--comparar el actual + ejecutado < ppto global
		--declare @taux nvarchar(max)
------------------------------------------------------------
-----------------------------------------------------------

			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and ISNULL(U_BPP_DIM1,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de Centro de Costo es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end
		------------------------------------------------------
		--------------------------------------------------------
		-------------------------------------------------------
				set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and ISNULL(U_BPP_DIM2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de Marcas... es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--------------------------------------------------------
		--------------------------------------------------------
				set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and ISNULL(U_BPP_DIM3,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de la Cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--------------------------------------------------------
		--------------------------------------------------------
				set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and ISNULL(U_BPP_DIM4,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de la Ciudad  es  obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--------------------------------------------------------
		-- Validación de Socio de Negocio Inactivo
		--------------------------------------------------------
				set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and i1.U_BPP_CgPv in (select CardCode from OCRD where (frozenFor='Y'))
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E005 El Socio de Negocio de la línea '+CAST(@VisOrder as nvarchar)+' se encuentra inactivo'
			return
		
		end

		--------------------------------------------------------
		-- Validación de Partida presupuestal en base al CC
		--------------------------------------------------------
				set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from [@BPP_CCHEARDET] i1 where i1.DocEntry = @DocEntry and SUBSTRING(i1.U_BPP_Cmp1,7,3)!=i1.U_BPP_DIM1
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E005 La partida ingresada no corresponde al CC seleccionado en la línea '+CAST((@VisOrder-1) as nvarchar)+' '
			return
		
		end

-----------------------------------------------------------
------------------------------------------------------------


/*
		select top 1 @ItmsGrpNam=t1.ItmsGrpNam
		from #tmp t1
		where t1.tot--Actual
			+
			--Ejecutado de OVs (Todas menos ppto Variable)
			ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
					from RDR1 r1
						inner join ORDR r0 on r0.DocEntry=r1.DocEntry
						inner join NNM1 n1 on n1.Series=r0.Series
						inner join OITM ar on ar.ItemCode=r1.ItemCode
					where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and 
						ar.ItmsGrpCod=case when r1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
						t1.AcctCode=case when r1.OcrCode2=@cntg then t1.AcctCode else 
										case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
										else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end end and
						RIGHT(SeriesName,3)!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001') and
						r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
			+
			--Ejecutado de Fact Prov (Directas)
			ISNULL((select SUM(p1.LineTotal)
					from PCH1 p1
						inner join OPCH p0 on p0.DocEntry=p1.DocEntry
						inner join NNM1 n1 on n1.Series=p0.Series
						inner join OITM ar on ar.ItemCode=p1.ItemCode
					where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
						ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
						p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
						RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
						and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
			+
			--Ejecutado de Fact Prov (CCH/EAR)
			ISNULL((select SUM(p1.LineTotal)
					from [@BPP_CCHEARDET] ccd
						inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
						inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
						inner join OITM ar on ar.ItemCode=p1.ItemCode
					where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
						ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
						p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
						ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
			+
			--Ejecutado de Asientos (Manuales)
			ISNULL((select SUM(j1.Debit-j1.Credit) 
					from JDT1 j1
						inner join OJDT j0 on j0.TransId=j1.TransId
						inner join NNM1 n1 on n1.Series=j0.Series
					where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and 
						j1.Account=case when j1.OcrCode2=@cntg then j1.Account else t1.AcctCode end and
						RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
						j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
			>
			case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
													from [@STR_PPTO_DET] p1 
														inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
													where CONVERT(date,U_STR_PER+'-01')<=t1.DocDate and p1.U_STR_CC2=t1.TipoServ and U_STR_EST='A' and
														ISNULL(p1.U_STR_GRPA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_GRPA,'') else t1.ItmsGrpCod end and
														ISNULL(p1.U_STR_CTA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_CTA,'') else t1.cta end and  
														p0.DocNum=t1.NroPpto and ISNULL(p1.U_STR_DIST,'')='' and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
								when 'P' then ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
																from RDR1 r1
																	inner join ORDR r0 on r0.DocEntry=r1.DocEntry
																	inner join NNM1 n1 on n1.Series=r0.Series
																	inner join OITM ar on ar.ItemCode=r1.ItemCode
																	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
																where r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and r0.CANCELED='N' and ar.QryGroup1='Y'
																	and r0.DocNum=t1.NroPpto and RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001')),0) 
								else 0 end
				*/						
		--if ISNULL(@ItmsGrpNam,'')!='' begin

		--	select	@error = 4
		--	select	@error_message = N'Se '+ISNULL(@taux,'')+' esta excediendo el presupuesto en el grupo '+@ItmsGrpNam
		--	return

		--end

		--set @error_message = 'A: '+CAST(@cont as nvarchar)+' B: '+ISNULL(@numac,'')
		--set @error = 99
		--return

		----------------------------------------------------------------------------------------------------
	
	END

	--IF (@TipoTransaccion in ('D')) BEGIN
		
	--	set @error_message = 'No se puede eliminar una carga'
	--	set @error = 99
	--	return
	
	--end
return

END

