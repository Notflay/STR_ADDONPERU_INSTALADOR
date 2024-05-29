CREATE  PROCEDURE ValOpch

--Facturas, facturas de reserva y notas de débito de compras

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@NumAtCard		nvarchar(100)
		,	@DocNum			int
		,	@CardCode		nvarchar(15)
		,	@DiscPrcnt		numeric(19,6)
		,	@DocTotal		numeric(19,6)
		,	@DocCur			nvarchar(3)
		,	@DocRate		numeric(19,6)
		,	@Series			smallint
		,	@GroupNum		smallint
		,	@RoundDif		numeric(19,6)
		,	@DocDate		datetime
		,	@DocDueDate		datetime
		,	@TaxDate		datetime
		,	@PayBlock		char(1)
		,	@UserSign2		smallint
		,	@DocSubType		nvarchar(2)
		,	@DataSource		char(1)
		,	@CANCELED		char(1)
		,	@U_BPP_MDTD		nvarchar(2)
		,	@U_BPP_MDSD		nvarchar(4)
		,	@U_BPP_MDCD		nvarchar(50)
		,	@U_BPP_CdBn		nvarchar(30)
		,	@U_BPP_CdOp		nvarchar(30)
		,	@pepp			int
		,	@U_N_Suministro		nvarchar(50)
		,	@U_Tipo		nvarchar(15)
		,	@U_Fecha_Factura		datetime
		,	@U_Tipo_Dec_Embargo nvarchar(2)
		,	@U_Fech_P_Prog		datetime
		,	@U_Obs_FP	nvarchar(100)
		
	--Variables de detalle
		,	@VisOrder		int
		,	@cont			int
		,	@ItemCode		nvarchar(30)
		,	@ItmsGrpNam		nvarchar(20)
	
	select	@NumAtCard		= f.NumAtCard
		,	@DocNum			= f.DocNum
		,	@CardCode		= f.CardCode
		,	@DiscPrcnt		= f.DiscPrcnt
		,	@DocTotal		= f.DocTotal
		,	@DocCur			= f.DocCur
		,	@DocRate		= f.DocRate
		,	@Series			= f.Series
		,	@GroupNum		= f.GroupNum
		,	@RoundDif		= f.RoundDif
		,	@DocDate		= f.DocDate
		,	@DocDueDate		= f.DocDueDate
		,	@TaxDate		= f.TaxDate
		,	@PayBlock		= f.PayBlock
		,	@UserSign2		= f.UserSign2
		,	@DocSubType		= f.DocSubType
		,	@DataSource		= f.DataSource
		,	@CANCELED		= f.CANCELED
		,	@U_BPP_MDTD		= f.U_BPP_MDTD
		,	@U_BPP_MDSD		= f.U_BPP_MDSD
		,	@U_BPP_MDCD		= f.U_BPP_MDCD
		,	@U_BPP_CdBn		= f.U_BPP_CdBn
		,	@U_BPP_CdOp		= f.U_BPP_CdOp
		,	@U_N_Suministro = f.U_N_Suministro
		,	@U_Tipo			= f.U_Tipo
		,	@U_Fecha_Factura = f.U_Fecha_Factura
		,	@U_Tipo_Dec_Embargo	= f.U_Tipo_Dec_Embargo
		,	@U_Fech_P_Prog = f.U_Fech_P_Prog
		,	@U_Obs_FP=f.U_Obs_FP

	
	from	OPCH f with(nolock)
	where	f.DocEntry = @DocEntry
	
	
	if (@TipoTransaccion in ('A','U')) begin


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
		--No se puede registrar más de una factura para la combinación SN + Número de Suministro + Mes de Consumo
		----------------------------------------------------------------------------------------------------
		
		if (@CardCode in (select CardCode from ocrd where cardtype='S' AND QryGroup25='Y') AND (ISNULL(@U_N_Suministro,'')<>'') AND @DocSubType='--' AND @CANCELED='N') begin
		
		SET @VisOrder=-777
		SET @VisOrder=(select count(T0.DocEntry) as 'contar'
		from [OPCH] T0
		where T0.CardCode=@CardCode AND T0.U_N_Suministro=@U_N_Suministro AND YEAR(T0.U_Fecha_Factura)=YEAR(@U_Fecha_Factura) AND MONTH(T0.U_Fecha_Factura)=MONTH(@U_Fecha_Factura) AND DocSubType='--' AND CANCELED='N'
		)
		
		if ISNULL(@VisOrder,0) > 1 begin
		
			select	@error = 10
			select	@error_message = N'Ya se creó una factura para el SN '+ CAST(@CardCode as nvarchar(15))+' con suministro '+ CAST(@U_N_Suministro as nvarchar(50))+' en el péríodo '+(CASE WHEN MONTH(@U_Fecha_Factura)<10 THEN '0' ELSE '' END)+cast(MONTH(@U_Fecha_Factura) AS nvarchar(2))+'-'+cast(YEAR(@U_Fecha_Factura) AS nvarchar(4))
			return
		
		end
		
		end
		
		----------------------------------------------------------------------------------------------------	
		----------------------------------------------------------------------------------------------------
		--No se puede registrar más de una ND para la combinación SN + Número de Suministro + Mes de Consumo
		----------------------------------------------------------------------------------------------------

		--if (@CardCode in (select CardCode from ocrd where cardtype='S' AND QryGroup25='Y') AND (ISNULL(@U_N_Suministro,'')<>'') AND @DocSubType='DM' AND @CANCELED='N') begin
		
		--SET @VisOrder=-777
		--SET @VisOrder=(select count(T0.DocEntry) as 'contar'
		--from [OPCH] T0
		--where T0.CardCode=@CardCode AND T0.U_N_Suministro=@U_N_Suministro AND YEAR(T0.U_Fecha_Factura)=YEAR(@U_Fecha_Factura) AND MONTH(T0.U_Fecha_Factura)=MONTH(@U_Fecha_Factura) AND DocSubType='DM'
		--)
		
		--if ISNULL(@VisOrder,0) > 1 begin
		
		--	select	@error = 10
		--	select	@error_message = N'Ya se creó una Nota de Débito para el SN '+ CAST(@CardCode as nvarchar(15))+' con suministro '+ CAST(@U_N_Suministro as nvarchar(50))+' en el péríodo '+(CASE WHEN MONTH(@U_Fecha_Factura)<10 THEN '0' ELSE '' END)+cast(MONTH(@U_Fecha_Factura) AS nvarchar(2))+'-'+cast(YEAR(@U_Fecha_Factura) AS nvarchar(4))
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
		  declare @anticipo int 
		 set @anticipo =   (  select COUNT(*)
							from 	OPCH T0  INNER JOIN PCH1 T1 ON T0.[DocEntry] = T1.[DocEntry]
								where T0.DocEntry=@DocEntry and   T0.U_anticipo100  ='NO'   )




		declare @OC_prop varchar(1)
		declare @EN_prop varchar(1)


		set  @OC_prop  =   (  select Qrygroup63  from ocrd  where    CardCode = @CardCode )
		set  @EN_prop  =   (  select Qrygroup64  from ocrd  where    CardCode = @CardCode )


		
  if  ( @anticipo  >0  ) 
  begin

				select @cont=COUNT(*)
							from 	OPCH T0  INNER JOIN PCH1 T1 ON T0.[DocEntry] = T1.[DocEntry]
								where T0.DocEntry=@DocEntry and (   ISNULL(T1.BaseType,0)!=20   )     and T0.DataSource = 'I' and @EN_prop ='N'
			and T0.U_BPP_MDTD <> 'AN'
								if @cont>0 
								begin
				
									select	@error = 10
									select	@error_message = N'Las facturas de proveedor deben ser creadas en base a una conformidad/entrada  -- '    +   CAST ( @anticipo  AS  VARCHAR(9))
									return
			
								  end 
     end
     else  if   @anticipo  =0   
	   begin
  
                             select @cont=COUNT(*)
							from 	OPCH T0  INNER JOIN PCH1 T1 ON T0.[DocEntry] = T1.[DocEntry]
								where T0.DocEntry=@DocEntry and (   ISNULL(T1.BaseType,0)!=22    and   T0.DataSource = 'I'  and  @OC_prop ='N' )     
			and T0.U_BPP_MDTD <> 'AN'
								if @cont>0 begin
				
									select	@error = 10
									select	@error_message = N'Las facturas de proveedor si son anticpos deben venir de una Orden de compra  -- '    +   CAST ( @anticipo  AS  VARCHAR(9)); 
									return

        end


  end




		----------------------------------------------------------------------------------
	 


		declare @SeriesName nvarchar(20)
		set @SeriesName=(select RIGHT(SeriesName,3) from NNM1 where Series=@Series)


		----------------------------------------------------------------------------------------------------
		--Se debe respetar el tipo de cambio del día
		----------------------------------------------------------------------------------------------------
		
		if @SeriesName!='SI' begin

			if @DocCur != (select MainCurncy from OADM) begin

				if @DocRate != (select Rate from ORTT where DateDiff(dd,RateDate,@TaxDate)=0 and @DocCur=Currency) begin
		
					select	@error = 2
					select	@error_message = N'Se debe respetar el tipo de cambio del día'
					return
		
				end

			end
		
		end

		----------------------------------------------------------------------------------------------------
		---- Funcionalidad de Retenciones para documentos que no tienen el codigo de retencion
		--	 set @pepp = (SELECT count(*) FROM OPCH   
		--	 WHERE ISNULL(U_STR_RET,'-') in  ('Y','N') and DOCENTRY =@docentry and docentry >(select top 1 isnull(U_STR_EntryRet,0) from [@BPP_CONFIG]))
                               
		--							   if @pepp > 0 
		--							   begin 
		--				set @error_message ='El campo afecto a retencion solo es para documentos anteriores a la funcionalidad de retencion' 
		--				set @error = 1
		--							   end
		--	---------------------------------------------------------------------------------------------------------------------------------------------

		----------------------------------------------------------------------------------------------------
		--Monto mayor a 0
		----------------------------------------------------------------------------------------------------
		
		if @DocTotal < 0 begin
		
			select	@error = 3
			select	@error_message = N'El total del documento debe ser mayor a 0'
			return
		
		end
		
		----------------------------------------------------------------------------------------------------
	
		if @DocSubType='--' begin --si es factura


		----------------------------------------------------------------------------------------------------
		--Validación que la condición de pago sea el mismo que la OC
		----------------------------------------------------------------------------------------------------
		
		  
		select @cont=COUNT(*)
		from PCH1 P1
		where DocEntry=@DocEntry and BaseType=20 and @GroupNum!=(SELECT OP.GroupNum FROM OPDN OP WHERE OP.DocEntry=P1.BaseEntry)
		
		if @cont>0 begin
				
			select	@error = 6
			select	@error_message = N'La Condición de pago de la factura debe ser la misma que la de la Conformidad original'
			return
			
		end

			----------------------------------------------------------------------------------------------------
			--Validacion de condicion de pago
			----------------------------------------------------------------------------------------------------
		
			--if (select GroupNum from OCRD where CardCode=@CardCode)!=@GroupNum begin
				
			--	select	@error = 6
			--	select	@error_message = N'('+CAST(@DocNum as nvarchar(10))+') Se debe utilizar la condicion de pago: '+
			--	(select PymntGroup from OCTG where GroupNum=(select GroupNum from OCRD where CardCode=@CardCode))
			--	return

			--end
		
	    -------------------------------------------------------------------
        -------------------------------------------------------------------
		----------VALIDA QUE SE AGREGUE CENTRO DE COSTO A NIVEL DE LINEA -----------------
		-------------------------------------------------------------------
		--	select VisOrder , * from PCH1
		
	 
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de Centro de Costo es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


		
			set @VisOrder=-776
		select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Marca es obligatorio en la linea ==='+CAST(@VisOrder as nvarchar)
			return
		
		end

		
			set @VisOrder=-775
		select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Ciudades - Planta  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--	Validación de poner como obligatorio el campo Descripción CRP

		--	set @VisOrder=-774
		--select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_descripcion2,'') = ''
		
		--if @VisOrder > 0 begin
		
		--	select	@error = 7
		--	select	@error_message = N'E004 El campo Descripción CRP es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		--	return
		
		--end

			-----------valida CCcon tabla CC--------

		declare	@USUARIO_CODIGO		nvarchar(100)
		set @VisOrder=0
		set	@USUARIO_CODIGO =    (select USER_CODE from OUSR where USERID=@UserSign2) 

		select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') not in (
		select U_C_costo from  [dbo].[@STR_CC] where [U_Usuario_VAL] = @USUARIO_CODIGO)

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E005 No tienes permiso para la dimension en la linea  '+CAST(@VisOrder as nvarchar)
			return
		
		end
		----


		----

		--------------------------------------------------------
		------------------------------------------------------
		---------------------------------------------------
		
--				 
		--------------------------------------------
		-------------------------------------------
		-------------------------------------------------------




			--Validacion Codigo de bien y Tipo de Operacion
			--if (select COUNT(*) from PCH5 where LEFT(WTCode,2)='DT' and AbsEntry=@DocEntry)>0 begin

			--	if ISNULL(@U_BPP_CdBn,'')='' begin

			--		select	@error = 30
			--		select	@error_message = N'El código de bien es obligatorio'
			--		return

			--	end
				
			--	if ISNULL(@U_BPP_CdOp,'')='' begin
				
			--		select	@error = 31
			--		select	@error_message = N'El código de operación es obligatorio'
			--		return

			--	end

			--end

			
			if @DataSource='I' begin
				
				declare @num numeric(10,2)
				set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
				--if @RoundDif not between -1*@num and @num begin

				--	select	@error = 8
				--	select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
				--	return

				--end

				if @CANCELED='N' begin
	
					if @SeriesName!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERCCH001') begin

						--if @TipoTransaccion = 'A' and @PayBlock='N' begin
	
						--	select	@error = 4
						--	select	@error_message = N'Las facturas deben crearse siempre bloqueadas para pago'
						--	return

						--end

						if @TipoTransaccion = 'U' and @PayBlock='N' and
							(select USER_CODE from OUSR where USERID=@UserSign2) != (select U_STR_VALOR from [@STR_PARAM] where Code='USRAUTPAG') begin

							select	@error = 5
							select	@error_message = N'Solo el usuario '+(select U_STR_VALOR from [@STR_PARAM] where Code='USRAUTPAG')+' esta autorizado'
							return

						end

						----------------------------------------------------------------------------------------------------
						--Validacion de Fecha de Vencimiento
						----------------------------------------------------------------------------------------------------
						if @SeriesName!='SI' begin
							
							if DATEADD(dd,(select ExtraMonth*30+ExtraDays from OCTG where GroupNum=@GroupNum),@DocDate)>@DocDueDate begin
				
								select	@error = 7
								select	@error_message = N'La fecha de Vencimiento debe ser mayor a '+CONVERT(nvarchar,DATEADD(dd,(select ExtraMonth*30+ExtraDays from OCTG where GroupNum=@GroupNum),@DocDate),103)
								return

							end
						
						end
						----------------------------------------------------------------------------------------------------
						
					--	if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') begin
						
							----------------------------------------------------------------------------------------------------
							--Validar proyectos y dimensiones (V010)
							----------------------------------------------------------------------------------------------------
							
							--set @VisOrder=-1
							--select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		
							--if @VisOrder > 0 begin
		
							--	select	@error = 9
							--	select	@error_message = N'El campo CECO es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
							--	return
		
							--end

							--set @VisOrder=-1
							--select top 1 @VisOrder = VisOrder+1 
							--from PCH1 i1 inner join OPRJ pr on pr.PrjCode=i1.Project and ISNULL(OcrCode,'') != ISNULL(pr.U_STR_CC2,OcrCode)
							--where i1.DocEntry = @DocEntry
		
							--if @VisOrder > 0 begin
		
							--	select	@error = 11
							--	select	@error_message = N'El campo Tipo de Negocio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
							--	return
		
							--end

							--set @VisOrder=-1
							--select top 1 @VisOrder = VisOrder+1 from PCH1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
							--if @VisOrder > 0 begin
		
							--	select	@error = 12
							--	select	@error_message = N'El campo Tipo de Servicio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
							--	return
		
							--end
		
							--set @VisOrder=-1
							--select top 1 @VisOrder = VisOrder+1 
							--from PCH1 i1 inner join OPRC cc on cc.PrcCode=i1.OcrCode2 and cc.U_STR_CLA9!=i1.OcrCode3
							--where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
							--if @VisOrder > 0 begin
		
							--	select	@error = 13
							--	select	@error_message = N'El campo Clase 9 es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
							--	return
		
							--end

							----------------------------------------------------------------------------------------------------

							--Ingresar un Tipo y numero de presupuesto
							--set @VisOrder=-1
							--select Top 1 @VisOrder=VisOrder+1 from PCH1 P1 inner join OITM ar on ar.ItemCode=P1.ItemCode and ar.QryGroup3='N'
							--where P1.DocEntry=@DocEntry and (ISNULL(U_STR_NROP,0)=0 or ISNULL(U_STR_TIPP,'') not in ('E','P'))
			
							--if @VisOrder>0 begin

							--	set @error_message = 'Se debe ingresar el tipo y número de presupuesto en la línea '+CAST(@VisOrder as nvarchar)
							--	set @error = 14
							--	return

							--end

							--Obtener el sumarizado de la FP actual
							--select p1.U_STR_TIPP TipoPpto,p1.U_STR_NROP NroPpto,p1.Project CECO,p1.OcrCode TipoNeg,p1.OcrCode2 TipoServ,ar.ItmsGrpCod,ga.ItmsGrpNam,
							--	ct.AcctCode,LEFT(ct.FormatCode,7) cta,SUM(LineTotal) tot
							--into #tmp
							--from PCH1 p1
							--	inner join OITM ar on ar.ItemCode=p1.ItemCode
							--	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
							--	inner join OACT ct on ct.AcctCode=p1.AcctCode
							--where p1.DocEntry=@DocEntry and ar.QryGroup3='N'
							--group by p1.U_STR_TIPP,p1.U_STR_NROP,p1.Project,p1.OcrCode,p1.OcrCode2,ar.ItmsGrpCod,ga.ItmsGrpNam,ct.AcctCode,ct.FormatCode
							

							declare @taux nvarchar(max)
							--Validacion del presupuesto Global: Actual + ejecutado < PPTO Acumulado
							select top 1 @ItmsGrpNam=t1.ItmsGrpNam,@taux='TOT: '+CAST(t1.tot as nvarchar)
							from #tmp t1
							where t1.tot--Actual
									+
									--Ejecutado de OVs (Todas menos ppto Variable)
									ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity) 
											from RDR1 r1 
												inner join ORDR r0 on r0.DocEntry=r1.DocEntry
												inner join NNM1 n1 on n1.Series=r0.Series
												inner join OITM ar on ar.ItemCode=r1.ItemCode
											where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and ar.ItmsGrpCod=t1.ItmsGrpCod and 
												t1.AcctCode=case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
															else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end and
												RIGHT(SeriesName,3)!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001') and
												r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
									+
									--Ejecutado de Fact Prov (Caja chica y Directas)
									ISNULL((select SUM(p1.LineTotal)
											from PCH1 p1
												inner join OPCH p0 on p0.DocEntry=p1.DocEntry
												inner join NNM1 n1 on n1.Series=p0.Series
												inner join OITM ar on ar.ItemCode=p1.ItemCode
											where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and ar.ItmsGrpCod=t1.ItmsGrpCod and t1.AcctCode=p1.AcctCode and
												RIGHT(SeriesName,3) in ((select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001'),(select U_STR_VALOR from [@STR_PARAM] where Code='SERCCH001'))
												and p1.DocEntry!=@DocEntry and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
									+
									--Ejecutado de Asientos (Manuales)
									ISNULL((select SUM(j1.Debit-j1.Credit) 
											from JDT1 j1
												inner join OJDT j0 on j0.TransId=j1.TransId
												inner join NNM1 n1 on n1.Series=j0.Series
											where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and j1.Account=t1.AcctCode and
												RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
												j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
									>
									--PPTO Acumulado
									case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
																	from [@STR_PPTO_DET] p1 
																		inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
																	where p1.U_STR_CC2=t1.TipoServ and p1.U_STR_GRPA=t1.ItmsGrpCod and U_STR_EST='A' and
																		p1.U_STR_CTA=t1.cta and p0.DocNum=t1.NroPpto and ISNULL(p1.U_STR_DIST,'')='' and
																		p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
												else 0 end--No se puede utilizar un ppto variable
										
							if ISNULL(@ItmsGrpNam,'')!='' begin

								select	@error = 15
								select	@error_message = N'Se esta excediendo el presupuesto global en el grupo '+@ItmsGrpNam
								return

							end

						--end else begin

						--	if @SeriesName!='SI' and @U_BPP_MDTD!='41' begin
				
								----------------------------------------------------------------------------------------------------
								--Validación que tengan como base una EM
								----------------------------------------------------------------------------------------------------
		
								

								----------------------------------------------------------------------------------------------------
		
								----------------------------------------------------------------------------------------------------
								--Validación que el precio de compra sea igual al precio de compra en la EM
								----------------------------------------------------------------------------------------------------

								declare @aux nvarchar(50)

								set @VisOrder=-1
								select top 1 @VisOrder=p1.VisOrder+1,@aux=CAST(case when p1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end as nvarchar)+' - '+
									CAST(case when r1.Currency=(select MainCurncy from OADM) then ROUND(r1.LineTotal,0) else ROUND(r1.TotalFrgn,0) end as nvarchar)
								from PCH1 p1
									inner join PDN1 r1 on r1.DocEntry=p1.BaseEntry and r1.LineNum=p1.BaseLine
								where p1.DocEntry=@DocEntry and case when p1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end
								 > case when r1.Currency=(select MainCurncy from OADM) then ROUND(r1.LineTotal,0) else ROUND(r1.TotalFrgn,0) end

								if @VisOrder>0 begin
		
									select	@error = 17
									select	@error_message = N'Se deben mantener los precios ingresados en la orden de compra. Linea '+cast(@VisOrder as nvarchar)
									return

								end
		
								----------------------------------------------------------------------------------------------------

							--end

				--		end

					end

				end

			end

		end

		--asignar el tipo-serie-correlativo
		if ISNULL(@U_BPP_MDSD,'')!='' and ISNULL(@U_BPP_MDCD,'')!='' begin
			
			set @U_BPP_MDSD=RIGHT('000'+@U_BPP_MDSD,4)
			set @U_BPP_MDCD=RIGHT('000000000'+@U_BPP_MDCD,10)
			set @NumAtCard = @U_BPP_MDTD +'-'+@U_BPP_MDSD+ '-'+@U_BPP_MDCD
			update OPCH set NumAtCard = @NumAtCard,U_BPP_MDSD=@U_BPP_MDSD,U_BPP_MDCD=@U_BPP_MDCD where DocEntry = @DocEntry
			UPDATE JDT1 set  ref2=@NumAtCard where transid =(select top 1 transid from OPCH where DocEntry = @DocEntry )
--		UPDATE OJDT set  ref2=@NumAtCard where transid =(select top 1 transid from OPCH where DocEntry = @DocEntry )
		end
		
	end

--	Procedimiento modificado por proyecto de integración con SEMT-TR

	if (@TipoTransaccion in ('A')) begin

		if ISNULL(@U_Tipo_Dec_Embargo,'')='' begin
		
			update OPCH set U_Tipo_Dec_Embargo = (CASE WHEN @CardCode like 'PEX%' THEN 'NO'  ELSE 'SI' END) where DocEntry = @DocEntry
		
		end

		if ISNULL(@U_Fech_P_Prog,'')<>'' begin
		
			update OPCH set U_Fech_P_Prog=NULL, U_Obs_FP=NULL where DocEntry = @DocEntry
			
		
		end
	end

	
END

