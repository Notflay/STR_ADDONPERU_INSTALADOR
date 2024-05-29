CREATE PROCEDURE ValAF

--Objectos 61 CC, 59 Proj, 

--Salida de mercancías por módulo de inventario

( 
	@DocEntry			nvarchar(255),
	@object_type		int
,	@TipoTransaccion	nchar(1)

)
AS  
BEGIN 

	--Centro de Costo - act_centrocostos
	if @object_type =61 and @TipoTransaccion in  ('A', 'U')
	begin 
		insert into dbo.act_centrocostos(compania, codigocentrocostos, descripcioncentrocostos) 
					(select '001', PrcCode, PrcName
					from OPRC where DimCode='1' 
					and convert(date,GETDATE()) < isnull(convert(date,ValidTo,103),'2100-12-31')
					and Active='Y'
					 and PrcCode=@DocEntry
					 )
	end 

	-- proyectos - act_proyecto
	if @object_type =63 and @TipoTransaccion in  ('A', 'U')
	begin 
		insert into dbo.act_proyecto(compania, codigoproyecto, descripcionproyecto) 
				select '001', PrjCode, left(PrjName,80) from OPRJ 
				where PrjCode not in( select codigoproyecto from dbo.act_proyecto) 				

	end
		
	-- Proveedor - act_proveedor
	if @object_type= '2' and @TipoTransaccion in  ('A', 'U')
	begin 

	if 	(select count('A')from act_proveedor where codigoproveedor=@DocEntry)=0 
	begin
		insert into dbo.act_proveedor(codigoproveedor, descripcionproveedor)
			(select CardCode, CardName 
					from OCRD where CardType='S' and left(CardCode,1)='P'  and isnull(QryGroup24,'N')='Y' and CardCode =@DocEntry)

	end   
		update act_proveedor set descripcionproveedor =
		x.CardName  from 	
					(select CardName ,CardCode
					from OCRD where CardType='S' and left(CardCode,1)='P'  and isnull(QryGroup24,'N')='Y' 
					and CardCode =@DocEntry
					) x
		where act_proveedor.codigoproveedor=x.CardCode
						
	end 
	
	
	-- Cuenta Contable - act_cuenta
	if @object_type =1 and @TipoTransaccion in  ('A', 'U')
	begin 
	if 	(select count('A')from act_cuenta where codigoalterno=@DocEntry)=0 
	begin
	
		insert into dbo.act_cuenta(cuenta, codigoalterno, descripcioncuenta, codigoarticulo, descripcionarticulo, 
		numeropresupuesto)
			select Segment_0, AcctCode, AcctName, U_STR_CdItem, U_STR_NbItem, U_STR_NroPtda 
					from OACT where isnull(U_STR_AFSY,'')='Y' and AcctCode =@DocEntry
	END 

	update act_cuenta set 
		codigoarticulo= X.U_STR_CdItem,
		descripcionarticulo= X.U_STR_NbItem,
		numeropresupuesto= X.U_STR_NroPtda
	from 	
		(select U_STR_CdItem, U_STR_NbItem, U_STR_NroPtda ,AcctCode
		from OACT where isnull(U_STR_AFSY,'')='Y' and AcctCode =@DocEntry
		) x
	where act_cuenta.codigoalterno=x.AcctCode
	
	END

		
	-- Carga Masiva (Factura de Proveedor y Precio de Entrega)
		if @object_type =18 and @TipoTransaccion in  ('A')
		begin 
	
		declare @Cambio1 float
		set @Cambio1 = (select T1.Rate from ORTT T1 where T1.RateDate = (Select T0.TaxDate from OPCH T0 where T0.DocEntry=@DocEntry))
		
		

		insert into dbo.act_cargamasiva(--idcargamasiva, (autogenerado) 
								factura, ordencompra, codigoproveedor, monedacompra, montolocalcompra, montodolarescompra, tipocambio, 
								cantidad, fechacompra, descripcionactivo, locacion, codigocentrocostos, codigosubcentrocostos, 
								codigoproyecto, fillerstr01, fillerstr02, fillerstr03, docentry, estado, fechacapitalizacion, 
								fechainiciodepreciacion, flagactivado, creadopor, fechacreacion, actualizadopor, fechaactualizacion, 
								computerid, loginid)
		
		select t0.NumAtCard, 
		   t0.U_STR_OcFe, --Validar si existe en la base de CRP y si es usado para el registro de la orden de compra. MANDATORIO
		   t0.CardCode, 
		   case when isnull(t0.DocCur,'')='USD' then 'DOL' else 'LOC' end,
		   --t1.LineTotal, 
		   (case when T0.DocCur = 'USD' then (T1.TotalFrgn)*@Cambio1
				else (T1.LineTotal) end) as Soles,
		   --case when isnull(t0.DocCur,'')='USD' then t1.TotalFrgn else t1.LineTotal*t0.DocRate end,
		   (case when T0.DocCur = 'USD' then (T1.TotalFrgn)
				else ROUND((T1.LineTotal)/@Cambio1,2) end) as Dolares,		   
		   @cambio1,
		   --T0.DocRate,
		   T1.Quantity, 
		   T0.TaxDate, -- Confirmar si es fecha de Documento o fecha de contabilización...
		   --T1.Dscription, -- confirmar si es esta descripcion o es la glosa de asiento...
		   UPPER(T1.U_descripcion2),
		   '', --locacion
		   t1.OcrCode, --CentroCosto
		   '',  --Subcentrocosto
		   t1.Project,
		   t1.OcrCode2, --filler1 confirmar que valor va aqui
		   t1.OcrCode4, --filler2 confirmar que valor va aqui
		   '', --filler3 confirmar que valor va aqui
		   t0.DocEntry, 
		   'ACTIV', --estado de activo por default 
		   t0.DocDate,
		   DATEADD(MONTH, DATEDIFF(MONTH, 0, T0.DocDate) + 1, 0), 
		   'N',
		   '', --creador user
		   t0.CreateDate,
		   '', -- update user
		   t0.UpdateDate,
		   '',
		   ''    	    
		from opch t0 inner join pch1 t1 on t0.DocEntry=t1.DocEntry
				 inner join oitm t2 on t1.ItemCode=t2.ItemCode
				 inner join ocrd t3 on t0.CardCode=t3.CardCode
		where isnull(t2.U_STR_AFSY,'')='Y' and isnull(t3.U_BPP_BPTP,'')!='SND' and
		 T0.Canceled='N'
		 AND T0.DocEntry =@DocEntry AND isnull(t1.TaxOnly,'')<>'Y'
		 -- se agregó la validación AND isnull(t1.TaxOnly,'')<>'Y'
		END
		
		
		--Importaciones
		if @object_type =69 and @TipoTransaccion in  ('A')
		begin 		
			--declare @docentry int = 28
			declare @moneda table (moneda nvarchar(3), fecha date)
			declare @Cambio table (cambio float, fecha date)			
			
			insert into @Cambio (cambio,fecha)(select top 1 T3.Rate, T3.RateDate FROM ORTT T3 where T3.RateDate IN (SELECT DocDate from OPCH T0 inner join IPF1 T1 on T0.DocEntry = T1.BaseEntry where T1.DocEntry= @DocEntry))
			insert into @moneda (moneda,fecha)(select top 1 doccur,DocDate FROM OPCH t0 inner join IPF1 T1 ON t0.DocEntry=t1.BaseEntry where t1.DocEntry=@DocEntry)

			insert into dbo.act_cargamasiva(--idcargamasiva, (autogenerado) 
									factura, ordencompra, codigoproveedor, monedacompra, montolocalcompra, montodolarescompra, tipocambio, 
									cantidad, fechacompra, descripcionactivo, locacion, codigocentrocostos, codigosubcentrocostos, 
									codigoproyecto, fillerstr01, fillerstr02, fillerstr03, docentry, estado, fechacapitalizacion, 
									fechainiciodepreciacion, flagactivado, creadopor, fechacreacion, actualizadopor, fechaactualizacion, 
									computerid, loginid)
	
			select     t0.NumAtCard,					   
					   t0.U_STR_OcFe, --Validar si existe en la base de CRP y si es usado para el registro de la orden de compra. MANDATORIO					   
					   t0.CardCode, 
					   --case when isnull(t0.DocCur,'')='USD' then 'DOL' else 'LOC' end,
					   case when isnull((select moneda from @moneda where fecha=t0.DocDate),'')='USD' then 'DOL' else 'LOC' end,
					   --t1.LineTotal + (select cost from ipf1 where ItemCode=t1.ItemCode and BaseEntry=t0.DocEntry and BaseType=18),					   
					   (case when (select moneda from @moneda where fecha=t0.DocDate)='USD'
					    then (T0.DocTotalFC-T0.VatSumFC)*(select cambio from @Cambio where fecha=t0.DocDate) else T0.DocTotal-T0.VatSum end  + T4.TtlCostLC	) as Soles,	 		
						 	 			
					   ROUND(((case when (select moneda from @moneda where fecha=t0.DocDate)='USD'
					    then (T0.DocTotalFC-T0.VatSumFC)*(select cambio from @Cambio where fecha=t0.DocDate)
						 else T0.DocTotal-T0.VatSum end + T4.TtlCostLC)/(select cambio from @Cambio where fecha=t0.DocDate)),2) as Dolares,						
					   --T4.TtlCostLC,
					   (select cambio from @Cambio where fecha=t0.DocDate), -- Tipo de Cambio de  la factura
					   --T0.DocRate,				   
					   T1.Quantity, 
					   T0.TaxDate, -- Confirmar si es fecha de Documento o fecha de contabilización...
					   --T1.Dscription, -- confirmar si es esta descripcion o es la glosa de asiento...
					   UPPER(T1.U_descripcion2),
					   '', --locacion
					   t1.OcrCode, --CentroCosto
					   '',  --Subcentrocosto
					   t1.Project,
					   t1.OcrCode2, --filler1 confirmar que valor va aqui
					   t1.OcrCode4, --filler2 confirmar que valor va aqui
					   '', --filler3 confirmar que valor va aqui
					   t0.DocEntry, 
					   'ACTIV', --estado de activo por default 
					   t0.DocDate,
					   DATEADD(MONTH, DATEDIFF(MONTH, 0, T0.DocDate) + 1, 0), 
					   'N',
					   '', --creador user
					   t0.CreateDate,
					   '', -- update user
					   t0.UpdateDate,
					   '',
					   ''    			   
			from opch t0 inner join pch1 t1 on t0.DocEntry=t1.DocEntry
							 inner join oitm t2 on t1.ItemCode=t2.ItemCode
							 inner join ocrd t3 on t0.CardCode=t3.CardCode
							 inner join ipf1 t4 on t4.BaseEntry=t0.DocEntry
							 inner join oipf t5 on t5.DocEntry=t4.DocEntry  							  				 
			where isnull(t2.U_STR_AFSY,'')='Y' and isnull(t3.U_BPP_BPTP,'')='SND' and T0.Canceled='N' and 
				  t0.DocEntry in (select BaseEntry from ipf1 where BaseType=18 AND DocEntry =@docentry)
		 
		END
		



		UPDATE act_cargamasiva SET estado='ANULA' where flagactivado!='S' 	and docentry= 
														 (SELECT TOP 1 BaseEntry FROM PCH1 WHERE BaseType=18 AND convert(char(10),DocEntry)=@DocEntry )
		
				
END


