CREATE  PROCEDURE ValOdrf

--Borrador

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare @ObjType		nvarchar(20)
		,	@DocTotal		numeric(19,6)
		,	@DocCur			nvarchar(3)
		,	@CurSource		char(1)
		,	@DocRate		numeric(19,6)
		,	@DocDate		datetime
		,	@DocDueDate		datetime
		,	@TaxDate		datetime
		,	@Series			smallint
		,	@GroupNum		smallint
		,	@RoundDif		numeric(19,6)
		,	@CardCode		nvarchar(20)
		,	@CtlAccount		nvarchar(30)
		,	@DiscPrcnt		numeric(19,6)
		,	@NumAtCard		nvarchar(100)
		,	@PayBlock		char(1)
		,	@UserSign2		smallint
		,	@CANCELED		char(1)
		,	@AtcEntry		int
		,	@PoPrss			char
		,	@U_STR_DSCTO	char(1)
		,	@U_STR_PPTO		char(1)
		,	@U_STR_ADIC		char(1)
		,	@U_STR_CNTG		char(1)
		,	@U_BPP_MDTD		nvarchar(2)
		,	@U_BPP_MDSD		nvarchar(4)
		,	@U_BPP_MDCD		nvarchar(20)
				,	@U_COSTO	nvarchar(8)
			
		,	@U_Anticipo		nvarchar(8)
		,	@U_Recon		nvarchar(8)
		,	@U_Canje		nvarchar(8)
		,	@BaseEntry		int

	--variables del detalle
		,	@VisOrder		int
	--otras variables
		,	@cont			int
		,	@SeriesName		nvarchar(20)
		,	@ItmsGrpNam		nvarchar(20)
		,	@cntg			nvarchar(8)
		,	@CPaux			nvarchar(20)
		,	@num			numeric(10,2)
		,	@dias			int
		,	@Usuario		int
		,	@U_Area_Crp		nvarchar(10)
		
	select	@ObjType		= f.ObjType
		,	@DocTotal		= f.DocTotal
		,	@DocCur			= f.DocCur
		,	@CurSource		= f.CurSource
		,	@DocRate		= f.DocRate
		,	@DocDate		= f.DocDate
		,	@DocDueDate		= f.DocDueDate
		,	@TaxDate		= f.TaxDate
		,	@Series			= f.Series
		,	@GroupNum		= f.GroupNum
		,	@RoundDif		= f.RoundDif
		,	@CardCode		= f.CardCode
		,	@CtlAccount		= f.CtlAccount
		,	@DiscPrcnt		= f.DiscPrcnt 
		,	@NumAtCard		= f.NumAtCard
		,	@PayBlock		= f.PayBlock
		,	@UserSign2		= f.UserSign2
		,	@CANCELED		= f.CANCELED
		,	@AtcEntry		= f.AtcEntry
		,	@PoPrss			= f.PoPrss
		,  @U_COSTO   = f.U_cCosto
		,  @U_Anticipo = f.U_anticipo100
		,	@U_Recon = f.U_areconciliar
		,	@U_Canje = f.U_canje
		,	@U_Area_Crp = f.U_Area_Crp
	--	,	@U_STR_DSCTO	= f.U_STR_DSCTO
	--	,	@U_STR_PPTO		= f.U_STR_PPTO
	--	,	@U_STR_ADIC		= f.U_STR_ADIC
	--	,	@U_STR_CNTG		= f.U_STR_CNTG
	--	,	@U_BPP_MDTD		= f.U_BPP_MDTD
	--	,	@U_BPP_MDSD		= f.U_BPP_MDSD
	--	,	@U_BPP_MDCD		= f.U_BPP_MDCD
		,	@Usuario		= ISNULL(f.UserSign2,f.UserSign)
	from	[dbo].[odrf]	f with(nolock)
	where	f.DocEntry		= @DocEntry

	select	@BaseEntry		= p1.BaseEntry
		
	from	[dbo].[drf1]	p1 with(nolock)
	where	p1.DocEntry		= @DocEntry	

	
	IF (@TipoTransaccion in ('A','U')) BEGIN
	


		if @ObjType=22 begin
	 
			----------------------------------------------------------------------------------------------------
			--Se debe ingresar un descuento positivo
			----------------------------------------------------------------------------------------------------
		
			if @DiscPrcnt < 0 begin
				select	@error = 1
				select	@error_message = N'El descuento debe ser siempre mayor a cero por ODRF '
				return
			END
		
			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--Se debe ingresar un descuento positivo
			----------------------------------------------------------------------------------------------------
		
			if @Cardcode IN (SELECT OC.Cardcode FROM OCRD OC WHERE OC.frozenFor='Y') begin
				select	@error = 1
				select	@error_message = N'El Socio de Negocio está inactivo'
				return
			END
		
			----------------------------------------------------------------------------------------------------
			----------------------------------------------------------------------------------------------------
			--Monto mayor a 0
			----------------------------------------------------------------------------------------------------
		
			if @DocTotal < 0 begin
				
				select	@error = 2
				select	@error_message = N'El total del documento debe ser mayor a 0  por ODRF  '
				return
		
			end


		if (  ISNULL(@U_COSTO,'')= '' ) 
        begin            
                if @VisOrder > 0 begin          
                        select  @error = 3
                        select  @error_message = N' Ingrese CECO'  
                        return          
                end
                                             
        end

if (  ISNULL(@U_Anticipo,'')= '' ) 
        begin            
                if @VisOrder > 0 begin          
                        select  @error = 3
                        select  @error_message = N' Ingrese Tipo de Anticipo'  
                        return          
                end
                                             
        end

if (  ISNULL(@U_Recon,'')= '' ) 
        begin            
                if @VisOrder > 0 begin          
                        select  @error = 3
                        select  @error_message = N'¿Se va a reonciliar?'  
                        return          
                end
                                             
        end

if (  ISNULL(@U_Canje,'')= '' ) 
        begin            
                if @VisOrder > 0 begin          
                        select  @error = 3
                        select  @error_message = N'¿Aplicara Canje?'  
                        return          
                end
                                             
        end


		--Requerimiento: Para artículo "construcciones en curso", siempre pedir campo proyecto
		
                          
        set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and ISNULL(T1.Project,'') ='' and T1.ItemCode='AFJ000020'

	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 Para el artículo "Construcciones en Curso" es necesario el ingreso del dato proyecto en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777

		--

		--Validar artículos compra local / importaciones vs. tipo de SN (local / extranjero)
		
                          
        set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and @CardCode like 'PEX%' and T1.ItemCode like 'AFJ%' and (select ItemName from OITM OI where OI.ItemCode=T1.ItemCode) like '%Compra Local'
	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 No se puede ingresar un artículo de AF local para un SN extranjero en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and (@CardCode like 'P1%' or @CardCode like 'P2%') and T1.ItemCode like 'AFJ%' and T1.ItemCode <> 'AFJ000019' and (select OI.ItemName from OITM OI where OI.ItemCode=T1.ItemCode) like '%Importación'
	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 No se puede ingresar un artículo de AF de importaciones para un SN Local en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777
		--

		--¿Es factible incluir una validación entre la propiedad del SN = AF y la posibilidad de crear un documento SAP con un artículo de AF?
		
                          
        set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and (select OC.QryGroup24 from ocrd OC where OC.cardcode=@CardCode) ='N' and T1.ItemCode like 'AFJ%'

	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 El proveedor no cuenta con la propiedad para la creación de artículos de activo fijo en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777

		--

			----  Centro de costo en campo de usuario no esta vacio 
		--------------------------------------------------------
		-------------------------------------------------------------

	
			----  Centro de costo en campo de usuario no esta vacio 
		--------------------------------------------------------
		-------------------------------------------------------------

		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and ISNULL(T0.U_cCosto,'') !=  T1.OcrCode


		if (  @U_COSTO!= 'multiple' AND @U_COSTO!= 'Sin CC' ) begin 
		
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E002 CC especifico a nivel de Campo de usuario (OPOR) debe ser igual a nivel de detalle  '  
			return
		
		end
		                             end

			----------------------------------------------------------------------------------------------------
			--Validar proyectos y dimensiones (V010)
			----------------------------------------------------------------------------------------------------
		
			--set @VisOrder=-1
			--select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		
			--if @VisOrder > 0 begin
		
			--	select	@error = 3
			--	select	@error_message = N'El campo CECO es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			--	return
		
			--end
			--------------------------------------------------------------------
					
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		and OcrCode in ( '252','253' )
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E001 El proyecto es obligatorio para los centros de costo (252,253)  '+CAST(@VisOrder as nvarchar)
			return
		
		end
			
					
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		and OcrCode in ( '255' ) and U_STR_Part_Des='Costos Operativos Conciertos'
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E001 El proyecto es obligatorio para el centro de costo 255 cuando use la partida Costos Operativos Conciertos  '+CAST(@VisOrder as nvarchar)
			return
		
		end
					
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''
	--	select * from DRF1


	 if @VisOrder > 0 begin
	    

		
			select	@error = 6
			select	@error_message = N'E004 La dimension de Centro de Costo (  Borrador )  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end



		---------------------------------------------------------
		-----------------------------------



		
			set @VisOrder=-776
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 6
			select	@error_message = N'E004 La dimension Marca  (  Borrador ) es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		
			set @VisOrder=-775
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 La dimension Cuenta destino  (  Borrador )  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 La dimension Ciudades - Planta  (  Borrador )  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--	Validación de poner como obligatorio el campo Descripción CRP

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_descripcion2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 El campo Descripción CRP es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--	Validación de crear partidas presupuestales del 2016 sólo para contabilidad

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

		--	validación de Area CRP como campo obligatorio para egarofalo

	if @Usuario in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Area-CRP')
	begin	
		
		if ISNULL(@U_Area_Crp,'') = '' begin
		
			select	@error = 7
			select	@error_message = N'Debe de ingresar un valor en el campo Área CRP'
			return
		
		end
		end	

		--	Validación para que sólo algunos usuarios puedan crear OC de activo fijo

	if @Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Area-CRP')
	begin	
		
			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%'
	
			if @VisOrder > 0 begin
		
				select	@error = 10
				select	@error_message = N'No tiene permiso para crear una OC con un artículo de Activo Fijo en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		end		

		--	Validación para que al seleccionar AF - Activo Fijo sea obligatrio que se seleccione un artículo de Activo Fijo

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T0.U_Area_Crp='AF'
	
			if @VisOrder = -777 AND @U_Area_Crp='AF' begin
		
				select	@error = 11
				select	@error_message = N'La opción del campo Área CRP AF - Activo Fijo es sólo para la compra de Activos'
				return
		
			end

		--	Validación para que por la compra de un activo se elija de forma obligatoria el área CRP AF - Activo Fijo

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T0.U_Area_Crp<>'AF'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe seleccionar el Área CRP AF - Activo Fijo'
				return
		
			end

		--	Validación para que sólo se cree con el campo Área CRP AF - Activo Fijo para los centros de costo 011(Sin CC) y multilple

			if((select T0.U_Area_Crp A from ODRF T0 where T0.DocEntry = @DocEntry AND T0.U_Area_Crp='AF' AND (T0.U_cCosto not in ('011','Sin CC','Multiple')))='AF') begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de AF los CECO pueden ser sólo el 011 y Multiple'
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el CC 011

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode<>'011'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar el CC 011 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el Marca 10

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode2<>'10'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar la Marca 10 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el Ciudad/Planta LIM1

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode4<>'LIM1'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar la Ciudad/Planta LIM1 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	validación de fecha de presupuesto

			set @VisOrder=-778
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ((abs(datediff(day,i1.U_STR_Mes,@DocDate))>365))
		--set @VisOrder2 = (select datediff(day,i1.U_STR_Mes,@DocDate) from POR1 i1 where i1.DocEntry = @DocEntry)
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E005 La fecha de presupuesto debe diferir a lo más en un año de la fecha del documento en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end
		
		set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and i1.ItemCode=(select ItemCode from OITM where (frozenFor='Y' and ItemCode=i1.ItemCode))
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E005 El Artículo de la línea '+CAST(@VisOrder as nvarchar)+' se encuentra inactivo'
			return
		
		end		

		
			-----------valida CCcon tabla CC--------

		declare	@USUARIO_CODIGO		nvarchar(100)
		set @VisOrder=0
		set	@USUARIO_CODIGO =    (select USER_CODE from OUSR where USERID=@UserSign2) 

		select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') not in (
		select U_C_costo from  [dbo].[@STR_CC] where [U_Usuario_VAL] = @USUARIO_CODIGO)

		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'No tienes permiso para la dimension en la linea  '+CAST(@VisOrder as nvarchar)
			return
		
		end
		----


		
			-------------------------------------------------------------------
			 
			
			set @CPaux=(select Top 1 Project from DRF1 where DocEntry = @DocEntry)
			
			--set @VisOrder=-1
			--select top 1 @VisOrder = VisOrder+1 
			--from DRF1 i1 inner join OPRJ pr on pr.PrjCode=i1.Project and ISNULL(OcrCode,'') != ISNULL(pr.U_STR_CC2,OcrCode)
			--where i1.DocEntry = @DocEntry
		
			--if @VisOrder > 0 begin
		
			--	select	@error = 5
			--	select	@error_message = N'El campo Tipo de Negocio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			--	return
		
			--end

		 








		
			set @VisOrder=-1
			--select top 1 @VisOrder = VisOrder+1 
			--from DRF1 i1 inner join OPRC cc on cc.PrcCode=i1.OcrCode2 and cc.U_STR_CLA9!=i1.OcrCode3
			--where i1.DocEntry = @DocEntry
		
			--if @VisOrder > 0 begin
		
			--	select	@error = 7
			--	select	@error_message = N'El campo Clase 9 es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			--	return
		
			--end

			----------------------------------------------------------------------------------------------------

			------------------------------------------------------------------------------------------------
			--Se debe indicar que es de aprovisionamiento
			------------------------------------------------------------------------------------------------
				
			--if @PoPrss='N' begin
					
			--	select	@error = 8
			--	select	@error_message = N'Se debe marcar el requerimiento como Documento de Aprovisionamiento'
			--	return
				
			--end
				
			------------------------------------------------------------------------------------------------

			--set @SeriesName=(select RIGHT(SeriesName,3) from NNM1 where Series=@Series)
			--set @cntg=(select U_STR_VALOR from [@STR_PARAM] where Code='TSCONTING')
			
			----Validación de OV Corporativa
			--if @CPaux=(select U_STR_VALOR from [@STR_PARAM] where Code='CODPROYCORP') begin

			--	if @SeriesName!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERCOR001') begin
				
			--		select	@error = 9
			--		select	@error_message = N'El CECO Corporativo solo se puede usar con la serie SAP corporativa'
			--		return
			
			--	end

			--end


			--Serie Normal - Presupuesto Variable
			if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001') begin
		
				set @VisOrder=-1
				select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and Project != @CPaux
		
				if @VisOrder > 0 begin
		
					select	@error = 4
					select	@error_message = N'El campo CECO debe ser igual en todas las lineas: '+CAST(@VisOrder as nvarchar)
					return
		
				end

				--solo puede tener 0 las OV de consumo
				if @DocTotal=0 begin
				
					select	@error = 10
					select	@error_message = N'El total del documento debe ser mayor a 0'
					return

				end

				--Validacion de la condicion de pago
				--if (select U_STR_CONP from OPRJ where PrjCode=@CPaux)!=@GroupNum begin
				
				--	select	@error = 11
				--	select	@error_message = N'Se debe utilizar la condicion de pago: '+
				--	(select PymntGroup from OCTG where GroupNum=(select U_STR_CONP from OPRJ where PrjCode=@CPaux))
				--	return

				--end

				--Validacion de redondeo maximo
				
				set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
				if @RoundDif not between -1*@num and @num begin

					select	@error = 12
					select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
					return

				end

			
				--Para el artículo de incremento de fee se debe solicitar autorización
				set @VisOrder=-1
				select Top 1 @VisOrder=r1.VisOrder+1
				from DRF1 r1
					inner join OITM ar on ar.ItemCode=r1.ItemCode
				where @U_STR_ADIC='N' and ar.QryGroup2='Y' and r1.DocEntry=@DocEntry

				if @VisOrder!=-1 begin

					select	@error = 13
					select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe ingresar un precio de venta valido'
					return

				end

				--Validacion para respetar el precio del proveedor de la lista de precio 
				--sin contar los articulos de bolsa-cch ni los articulo de incremento de fee
				--set @VisOrder=-1
				--select Top 1 @VisOrder=r1.VisOrder+1
				--from DRF1 r1
				--	inner join OITM ar on ar.ItemCode=r1.ItemCode
				--	left join OSPP pr on pr.ItemCode=r1.ItemCode and pr.CardCode=r1.FreeTxt
				--where ar.QryGroup1='N' and ar.QryGroup2='N' and r1.DocEntry=@DocEntry and ISNULL(pr.Price,-1)!=ISNULL(r1.U_STR_PUPR,0)

				--if @VisOrder!=-1 begin

				--	select	@error = 14
				--	select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe utilizar un precio de un proveedor autorizado'
				--	return

				--end

				--Para el artículo de bolsa-cch debe de tener un precio de compra
				--set @VisOrder=-1
				--select Top 1 @VisOrder=r1.VisOrder+1
				--from DRF1 r1
				--	inner join OITM ar on ar.ItemCode=r1.ItemCode
				--where ar.QryGroup1='Y' and ISNULL(r1.U_STR_PUPR,0)<=0 and r1.DocEntry=@DocEntry

				--if @VisOrder!=-1 begin

				--	select	@error = 15
				--	select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe ingresar un precio de compra valido'
				--	return

				--end

				--Validacion para respetar el precio de venta
				--sin contar los articulo de incremento de fee
				set @VisOrder=-1
				select Top 1 @VisOrder=r1.VisOrder+1
				from DRF1 r1
					inner join OITM ar on ar.ItemCode=r1.ItemCode
					inner join OPRJ PRY on PRY.PrjCode=r1.Project
					inner join [@STR_PORC_INC] PIN on PIN.Code=PRY.U_STR_PINC
				where ar.QryGroup2='N' and r1.DocEntry=@DocEntry and 
				ROUND((1+PIN.U_STR_VALOR+case when ar.QryGroup1='Y' then 
					(select CAST(U_STR_VALOR as numeric(19,6)) from [@STR_PARAM] where Code='CCHPORINC') else 0 end+
					case when (select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OCRD sn on cp.GroupNum=sn.GroupNum where sn.CardCode=r1.FreeTxt)>
								(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OPRJ pr on cp.GroupNum=pr.U_STR_CONP where pr.PrjCode=r1.Project) then 
							(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OCRD sn on cp.GroupNum=sn.GroupNum where sn.CardCode=r1.FreeTxt)-
							(select CEILING((ExtraMonth*30+ExtraDays)/30.0) from OCTG cp inner join OPRJ pr on cp.GroupNum=pr.U_STR_CONP where pr.PrjCode=r1.Project) else 0 end*
					(select CAST(U_STR_VALOR as numeric(19,6)) from [@STR_PARAM] where Code='CPPORINC'))*ISNULL(r1.U_STR_PUPR,0),2)
				!= ROUND(r1.PriceBefDi,2)
			
			
				if @VisOrder!=-1 begin

					select	@error = 16
					select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe utilizar un precio de venta automático'
					return

				end

				--Para el artículo de incremento de fee
				set @VisOrder=-1
				select Top 1 @VisOrder=r1.VisOrder+1
				from DRF1 r1
					inner join OITM ar on ar.ItemCode=r1.ItemCode
				where ar.QryGroup2='Y' and ISNULL(r1.PriceBefDi,0)<=0 and r1.DocEntry=@DocEntry

				if @VisOrder!=-1 begin

					select	@error = 17
					select	@error_message = N'En la línea ' + CAST(@VisOrder as nvarchar) + ' se debe ingresar un precio de venta valido'
					return

				end

				--Validar la aprobacion del descuento
				if ISNULL(@U_STR_DSCTO,'N')='N' begin

					set @VisOrder=-1
					select Top 1 @VisOrder=r1.VisOrder+1
					from DRF1 r1
					where r1.DiscPrcnt>0 and r1.DocEntry=@DocEntry

					if @VisOrder!=-1 begin

						select	@error = 18
						select	@error_message = N'Línea ' + CAST(@VisOrder as nvarchar) + ' Debe solicitar autorización para descuento'
						return

					end

				end

				--Validar que tenga adjunto
				--if (select COUNT(*) from ATC1 where AbsEntry=@AtcEntry)<=0 begin

				--	select	@error = 19
				--	select	@error_message = N'Se debe adjuntar la aprobación del cliente'
				--	return

				--end
				
			
			--Ordenes de: Consumo Operativo / Plataforma / Consumo interno / Corporativo
			end else begin

				--Usar cliente interno de consumo
				--if (select QryGroup1 from OCRD where CardCode=@CardCode)='N' begin
				
				--	select	@error = 21
				--	select	@error_message = N'Las órdenes de consumo requieren de un cliente para orden de consumo'
				--	return
			
				--end

				--Uso de tipo de servicio contingencia
				if ISNULL(@U_STR_CNTG,'N')='N' begin
				
					set @VisOrder=-1
					select Top 1 @VisOrder=r1.VisOrder+1
					from DRF1 r1
					where r1.OcrCode2=@cntg and r1.DocEntry=@DocEntry

					if @VisOrder!=-1 begin
				
						select	@error = 22
						select	@error_message = N'El uso del tipo de servicio contingencia requiere autorización. Linea '+ CAST(@VisOrder as nvarchar)
						return
			
					end

				end

				--Ingresar un Tipo y numero de presupuesto
				set @VisOrder=-1
				--select Top 1 @VisOrder=VisOrder+1 from DRF1 
				--where DocEntry=@DocEntry and (ISNULL(U_STR_NROP,0)=0 or ISNULL(U_STR_TIPP,'') not in ('E','P'))
			
				--if @VisOrder>0 begin

				--	set @error_message = 'Se debe ingresar el tipo y número de presupuesto en la línea '+CAST(@VisOrder as nvarchar)
				--	set @error = 23
				--	return

				--end

				--Ordenes de Venta Plataforma
				if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERPTF001') begin
			
					set @VisOrder=-1
					select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and Project != @CPaux
		
					if @VisOrder > 0 begin
		
						select	@error = 4
						select	@error_message = N'El campo CECO debe ser igual en todas las lineas: '+CAST(@VisOrder as nvarchar)
						return
		
					end
					
					--Validacion para OV de plataforma
					--select r1.U_STR_TIPP TipoPpto,r1.U_STR_NROP NroPpto,r1.Project CECO,r1.OcrCode TipoNeg,r1.OcrCode2 TipoServ,SUM(LineTotal) tot
					--into #tmppla
					--from DRF1 r1
					--	inner join OPRJ pr on pr.PrjCode=r1.Project
					--where r1.DocEntry=@DocEntry
					--group by r1.U_STR_TIPP,r1.U_STR_NROP,r1.Project,r1.OcrCode,r1.OcrCode2
			
					--select top 1 @ItmsGrpNam=t1.TipoServ
					--from #tmppla t1
					--where t1.tot--Actual
				----			+
				--			--Ejecutado de OVs (Todas menos ppto Variable)
				--			ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
				--					from RDR1 r1
				--						inner join ORDR r0 on r0.DocEntry=r1.DocEntry
				--						inner join NNM1 n1 on n1.Series=r0.Series
				--					where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and
				--						RIGHT(SeriesName,3)!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001') and
				--						r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0)
				--			+
				--			--Ejecutado de Fact Prov (Caja chica y Directas)
				--			ISNULL((select SUM(p1.LineTotal)
				--					from PCH1 p1
				--						inner join OPCH p0 on p0.DocEntry=p1.DocEntry
				--						inner join NNM1 n1 on n1.Series=p0.Series
				--					where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and
				--						RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
				--				and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
				--			+
				--			--Ejecutado de Fact Prov (CCH/EAR)
				--			ISNULL((select SUM(p1.LineTotal)
				--					from [@BPP_CCHEARDET] ccd
				--						inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
				--						inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
				--						inner join OITM ar on ar.ItemCode=p1.ItemCode
				--					where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
				--						ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
				--			+
				--			--Ejecutado de Asientos (Manuales)
				--			ISNULL((select SUM(j1.Debit-j1.Credit) 
				--					from JDT1 j1
				--						inner join OJDT j0 on j0.TransId=j1.TransId
				--						inner join NNM1 n1 on n1.Series=j0.Series
				--					where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and
				--						RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
				--						j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
				--			> 
				--			--Presupuesto Global
				--			case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
				--													from [@STR_PPTO_DET] p1 
				--														inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
				--													where p1.U_STR_CC2=t1.TipoServ and U_STR_EST='A' and p0.DocNum=t1.NroPpto and 
				--														ISNULL(p1.U_STR_DIST,'')='' and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
				--								when 'P' then ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity)
				--													from RDR1 r1
				--														inner join ORDR r0 on r0.DocEntry=r1.DocEntry
				--														inner join NNM1 n1 on n1.Series=r0.Series
				--													where r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and r0.CANCELED='N'
				--														and r0.DocNum=t1.NroPpto and RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERENT001')),0)
				--			else 0 end
			
				--	if ISNULL(@ItmsGrpNam,'')!='' begin

				--		select	@error = 24
				--		select	@error_message = N'No se puede exceder el presupuesto asignado para plataforma'
				--		return

				--	end
			
				--Ordenes de: Consumo Operativo / Consumo interno / Corporativo
				end else begin

					--Obtener el sumarizado de la OV actual
					--select r1.U_STR_TIPP TipoPpto,r1.U_STR_NROP NroPpto,r1.Project CECO,r1.OcrCode TipoNeg,r1.OcrCode2 TipoServ,ar.ItmsGrpCod,ga.ItmsGrpNam,
					--	ct.AcctCode,LEFT(ct.FormatCode,7) cta,SUM(U_STR_PUPR*Quantity) tot
					--into #tmp
					--from DRF1 r1
					--	inner join OITM ar on ar.ItemCode=r1.ItemCode
					--	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
					--	inner join OACT ct on ct.AcctCode=case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) else ga.ExpensesAc end
					--where r1.DocEntry=@DocEntry
					--group by r1.U_STR_TIPP,r1.U_STR_NROP,r1.Project,r1.OcrCode,r1.OcrCode2,ar.ItmsGrpCod,ga.ItmsGrpNam,ct.AcctCode,ct.FormatCode
			
					----Validacion del presupuesto Global: Actual + ejecutado < PPTO Acumulado
					--select top 1 @ItmsGrpNam=t1.ItmsGrpNam
					--from #tmp t1
					--where t1.tot--Actual
					--		+ 
					--	--Ejecutado de OVs (Todas menos ppto Variable)
					--	ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity) 
					--			from RDR1 r1 
					--				inner join ORDR r0 on r0.DocEntry=r1.DocEntry
					--				inner join OITM ar on ar.ItemCode=r1.ItemCode
					--			where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and 
					--				ar.ItmsGrpCod=case when r1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
					--				t1.AcctCode=case when r1.OcrCode2=@cntg then t1.AcctCode else 
					--								case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
					--								else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end end and
					--				r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
					--	+
					--	--Ejecutado de Fact Prov (Directas)
					--	ISNULL((select SUM(p1.LineTotal)
					--			from PCH1 p1
					--				inner join OPCH p0 on p0.DocEntry=p1.DocEntry
					--				inner join NNM1 n1 on n1.Series=p0.Series
					--				inner join OITM ar on ar.ItemCode=p1.ItemCode
					--			where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
					--				ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
					--				p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
					--				RIGHT(SeriesName,3) in (select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001')
					--				and p1.U_STR_TIPP=t1.TipoPpto and p1.U_STR_NROP=t1.NroPpto),0)
					--	+
					--	--Ejecutado de Fact Prov (CCH/EAR)
					--	ISNULL((select SUM(p1.LineTotal)
					--			from [@BPP_CCHEARDET] ccd
					--				inner join OPCH p0 on ccd.U_BPP_DEDc=p0.DocEntry
					--				inner join PCH1 p1 on p0.DocEntry=p1.DocEntry
					--				inner join OITM ar on ar.ItemCode=p1.ItemCode
					--			where p0.CANCELED='N' and p1.Project=t1.CECO and p1.OcrCode=t1.TipoNeg and p1.OcrCode2=t1.TipoServ and 
					--				ar.ItmsGrpCod=case when p1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
					--				p1.AcctCode=case when p1.OcrCode2=@cntg then p1.AcctCode else t1.AcctCode end and
					--				ccd.U_BPP_Cmp1=t1.TipoPpto and ccd.U_BPP_Cmp2=t1.NroPpto),0)
					--	+
					--	--Ejecutado de Asientos (Manuales)
					--	ISNULL((select SUM(j1.Debit-j1.Credit) 
					--			from JDT1 j1
					--				inner join OJDT j0 on j0.TransId=j1.TransId
					--				inner join NNM1 n1 on n1.Series=j0.Series
					--			where j1.Project=t1.CECO and j1.ProfitCode=t1.TipoNeg and j1.OcrCode2=t1.TipoServ and 
					--				j1.Account=case when j1.OcrCode2=@cntg then j1.Account else t1.AcctCode end and
					--				RIGHT(SeriesName,3)=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') and
					--				j1.U_STR_TIPP=t1.TipoPpto and j1.U_STR_NROP=t1.NroPpto),0)
					--	>
					--	--PPTO Acumulado
					--	case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
					--										from [@STR_PPTO_DET] p1 
					--											inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
					--										where p1.U_STR_CC2=t1.TipoServ and U_STR_EST='A' and ISNULL(p1.U_STR_DIST,'')='' and
					--											ISNULL(p1.U_STR_GRPA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_GRPA,'') else t1.ItmsGrpCod end and
					--											ISNULL(p1.U_STR_CTA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_CTA,'') else t1.cta end and 
					--											p0.DocNum=t1.NroPpto and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
					--					else 0 end--No se puede utilizar un ppto variable
										
					--if ISNULL(@ItmsGrpNam,'')!='' begin

					--	select	@error = 26
					--	select	@error_message = N'Se esta excediendo el presupuesto global en el grupo '+@ItmsGrpNam
					--	return

					--end

					--Debe tener autorización para excederse del presupuesto del periodo
					if @U_STR_PPTO='N' begin

						--comparar el actual + ejecutado < ppto acumulado
						select top 1 @ItmsGrpNam=t1.ItmsGrpNam
						from #tmp t1
						where t1.tot --Actual
							+
						--Ejecutado de OVs (Todas menos ppto Variable)
						ISNULL((select SUM(r1.U_STR_PUPR*r1.Quantity) 
								from RDR1 r1 
									inner join ORDR r0 on r0.DocEntry=r1.DocEntry
									inner join OITM ar on ar.ItemCode=r1.ItemCode
								where r0.CANCELED='N' and r1.Project=t1.CECO and r1.OcrCode=t1.TipoNeg and r1.OcrCode2=t1.TipoServ and 
									ar.ItmsGrpCod=case when r1.OcrCode2=@cntg then ar.ItmsGrpCod else t1.ItmsGrpCod end and 
									t1.AcctCode=case when r1.OcrCode2=@cntg then t1.AcctCode else 
													case when GLMethod='L' then (select top 1 al.ExpensesAc from OITW al where ItemCode=ar.ItemCode) 
													else (select ga.ExpensesAc from OITB ga where ga.ItmsGrpCod=ar.ItmsGrpCod) end end and
									r1.DocEntry!=@DocEntry and r1.U_STR_TIPP=t1.TipoPpto and r1.U_STR_NROP=t1.NroPpto),0) 
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
						--PPTO Acumulado
						case t1.TipoPpto when 'E' then ISNULL((select SUM(U_STR_MONT) 
															from [@STR_PPTO_DET] p1 
																inner join [@STR_PPTO_CAB] p0 on p1.DocEntry=p0.DocEntry
															where CONVERT(date,U_STR_PER+'-01')<=@DocDate and p1.U_STR_CC2=t1.TipoServ and 
																ISNULL(p1.U_STR_DIST,'')='' and U_STR_EST='A' and 
																ISNULL(p1.U_STR_GRPA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_GRPA,'') else t1.ItmsGrpCod end and
																ISNULL(p1.U_STR_CTA,'')=case when p1.U_STR_CC2=@cntg then ISNULL(p1.U_STR_CTA,'') else t1.cta end and 
																p0.DocNum=t1.NroPpto and p0.U_STR_PROY=t1.CECO and p0.U_STR_CC1=t1.TipoNeg),0)
										else 0 end--No se puede utilizar un ppto variable
				
						if ISNULL(@ItmsGrpNam,'')!='' begin

							select	@error = 27
							select	@error_message = N'Se esta excediendo el presupuesto del periodo en el grupo '+@ItmsGrpNam
							return

						end

					end

				end

			end

		end

		if @ObjType=18 begin

			if ISNULL(@U_BPP_MDTD,'')='' begin

				set @error_message = 'El tipo de documento SUNAT es obligatorio'
				set @error = 1
				return
			
			end

			if ISNULL(@U_BPP_MDSD,'')='' begin

				set @error_message = 'El serie SUNAT es obligatoria'
				set @error = 2
				return
			
			end

			if ISNULL(@U_BPP_MDCD,'')='' begin

				set @error_message = 'El número de documento SUNAT es obligatorio'
				set @error = 3
				return
			
			end


			----------------------------------------------------------------------------------------------------
			--Validación que la fecha de contabilización
			----------------------------------------------------------------------------------------------------
			
			if DATEDIFF(dd,GETDATE(),ISNULL(@DocDate,'19990101'))>7 begin

				set @error_message = 'La fecha de contabilización debe ser '+convert(nvarchar,GETDATE(),103)
				set @error = 4
				return
			
			end

			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--Validación que la fecha del documento
			----------------------------------------------------------------------------------------------------
			
			set @dias=CAST((select U_STR_VALOR from [@STR_PARAM] where Code='DIASFDOC') as int)
			if DATEDIFF(dd,ISNULL(@TaxDate,'19990101'),@DocDate)>@dias begin

				set @error_message = 'La fecha del documento no debe diferir en '+CAST(@dias as nvarchar)+' días de la fecha de contabilización '+CAST(DATEDIFF(dd,ISNULL(@TaxDate,'19990101'),@DocDate) as nvarchar)
				set @error = 5
				return
			
			end

			----------------------------------------------------------------------------------------------------

			
			if (select COUNT(*) from ODRF where ObjType=18 and CardCode=@CardCode and RIGHT('0'+U_BPP_MDTD,2)=RIGHT('0'+@U_BPP_MDTD,2) and RIGHT('000'+U_BPP_MDSD,4)=RIGHT('000'+@U_BPP_MDSD,4) and RIGHT('000000000'+U_BPP_MDCD,10)=RIGHT('000000000'+@U_BPP_MDCD,10))+
				(select COUNT(*) from OPCH where CardCode=@CardCode and RIGHT('0'+U_BPP_MDTD,2)=RIGHT('0'+@U_BPP_MDTD,2) and RIGHT('000'+U_BPP_MDSD,4)=RIGHT('000'+@U_BPP_MDSD,4) and RIGHT('000000000'+U_BPP_MDCD,10)=RIGHT('000000000'+@U_BPP_MDCD,10)) >1 begin
				
				set @error_message = 'El número SUNAT ya está registrado'
				set @error = 6
				return

			end

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
			--Se debe respetar el tipo de cambio del día
			----------------------------------------------------------------------------------------------------
		
			if @DocCur != (select MainCurncy from OADM) begin

				if @DocRate != (select Rate from ORTT where DateDiff(dd,RateDate,@TaxDate)=0 and @DocCur=Currency) begin
		
					select	@error = 2
					select	@error_message = N'Se debe respetar el tipo de cambio del día'
					return
		
				end

			end
		
			----------------------------------------------------------------------------------------------------
		

			----------------------------------------------------------------------------------------------------
			--Monto mayor a 0
			----------------------------------------------------------------------------------------------------
		
			if @DocTotal < 0 begin
		
				select	@error = 3
				select	@error_message = N'El total del documento debe ser mayor a 0'
				return
		
			end
		
			----------------------------------------------------------------------------------------------------
		
			if @TipoTransaccion = 'A' and @PayBlock='N' begin
	
				select	@error = 4
				select	@error_message = N'Las facturas deben crearse siempre bloqueadas para pago'
				return

			end

			if @TipoTransaccion = 'U' and @PayBlock='N' and
				(select USER_CODE from OUSR where USERID=@UserSign2) != (select U_STR_VALOR from [@STR_PARAM] where Code='USRAUTPAG') begin

				select	@error = 5
				select	@error_message = N'Solo el usuario '+(select U_STR_VALOR from [@STR_PARAM] where Code='USRAUTPAG')+' esta autorizado'
				return

			end

			----------------------------------------------------------------------------------------------------
			--Validacion de condicion de pago
			----------------------------------------------------------------------------------------------------
		
			--if (select GroupNum from OCRD where CardCode=@CardCode)!=@GroupNum begin
				
			--	select	@error = 6
			--	select	@error_message = N'Se debe utilizar la condicion de pago del Socio de Negocio: '+
			--	(select PymntGroup from OCTG where GroupNum=(select GroupNum from OCRD where CardCode=@CardCode))
			--	return

			--end

			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--Validacion de Fecha de Vencimiento
			----------------------------------------------------------------------------------------------------
		
			if DATEADD(dd,(select ExtraMonth*30+ExtraDays from OCTG where GroupNum=@GroupNum),@DocDate)>@DocDueDate begin
				
				select	@error = 7
				select	@error_message = N'La fecha de Vencimiento debe ser mayor a '+CONVERT(nvarchar,DATEADD(dd,(select ExtraMonth*30+ExtraDays from OCTG where GroupNum=@GroupNum),@DocDate),103)
				return

			end

			----------------------------------------------------------------------------------------------------

			set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
			if @RoundDif not between -1*@num and @num begin

				select	@error = 8
				select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
				return

			end


			if @CANCELED='N' begin

				set @SeriesName=(select RIGHT(SeriesName,3) from NNM1 where Series=@Series)

				if @SeriesName=(select U_STR_VALOR from [@STR_PARAM] where Code='SERMAN001') begin

					----------------------------------------------------------------------------------------------------
					--Validar proyectos y dimensiones (V010)
					----------------------------------------------------------------------------------------------------
		
					set @VisOrder=-1
					select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		
					if @VisOrder > 0 begin
		
						select	@error = 9
						select	@error_message = N'El campo CECO es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
						return
		
					end

					set @VisOrder=-1
					--select top 1 @VisOrder = VisOrder+1 
					--from DRF1 i1 inner join OPRJ pr on pr.PrjCode=i1.Project and ISNULL(OcrCode,'') != ISNULL(pr.U_STR_CC2,OcrCode)
					--where i1.DocEntry = @DocEntry
		
					--if @VisOrder > 0 begin
		
					--	select	@error = 10
					--	select	@error_message = N'El campo Tipo de Negocio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
					--	return
		
					--end

					set @VisOrder=-1
					select top 1 @VisOrder = VisOrder+1 from DRF1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
					if @VisOrder > 0 begin
		
						select	@error = 11
						select	@error_message = N'El campo Tipo de Servicio es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
						return
		
					end
		
					--set @VisOrder=-1
					--select top 1 @VisOrder = VisOrder+1 
					--from DRF1 i1 inner join OPRC cc on cc.PrcCode=i1.OcrCode2 and cc.U_STR_CLA9!=i1.OcrCode3
					--where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
					if @VisOrder > 0 begin
		
						select	@error = 12
						select	@error_message = N'El campo Clase 9 es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
						return
		
					end

					----------------------------------------------------------------------------------------------------

					--Ingresar un Tipo y numero de presupuesto
					--set @VisOrder=-1
					--select Top 1 @VisOrder=VisOrder+1 from PCH1 
					--where DocEntry=@DocEntry and (ISNULL(U_STR_NROP,0)=0 or ISNULL(U_STR_TIPP,'') not in ('E','P'))
			
					if @VisOrder>0 begin

						set @error_message = 'Se debe ingresar el tipo y número de presupuesto en la línea '+CAST(@VisOrder as nvarchar)
						set @error = 13
						return

					end

					--Obtener el sumarizado de la FP actual
					--select p1.U_STR_TIPP TipoPpto,p1.U_STR_NROP NroPpto,p1.Project CECO,p1.OcrCode TipoNeg,p1.OcrCode2 TipoServ,ar.ItmsGrpCod,ga.ItmsGrpNam,
					--	ct.AcctCode,LEFT(ct.FormatCode,7) cta,SUM(LineTotal) tot
					--into #tmpFP
					--from DRF1 p1
					--	inner join OITM ar on ar.ItemCode=p1.ItemCode
					--	inner join OITB ga on ga.ItmsGrpCod=ar.ItmsGrpCod
					--	inner join OACT ct on ct.AcctCode=p1.AcctCode
					--where p1.DocEntry=@DocEntry
					--group by p1.U_STR_TIPP,p1.U_STR_NROP,p1.Project,p1.OcrCode,p1.OcrCode2,ar.ItmsGrpCod,ga.ItmsGrpNam,ct.AcctCode,ct.FormatCode
			
					--Validacion del presupuesto Global: Actual + ejecutado < PPTO Acumulado
					select top 1 @ItmsGrpNam=t1.ItmsGrpNam
					from #tmpFP t1
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
									from DRF1 p1
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

				end else begin

					if @SeriesName!=(select U_STR_VALOR from [@STR_PARAM] where Code='SERCCH001') begin
				
						----------------------------------------------------------------------------------------------------
						--Validación que tengan como base una EM
						----------------------------------------------------------------------------------------------------
		
						select @cont=COUNT(*)
						from DRF1
						where DocEntry=@DocEntry and ISNULL(BaseType,0)!=20
		
						if @cont>0 begin
				
							select	@error = 16
							select	@error_message = N'Las facturas de proveedor deben ser creadas con una entrada de mercadería como base'
							return
			
						end

						----------------------------------------------------------------------------------------------------
		
						----------------------------------------------------------------------------------------------------
						--Validación que el precio de compra sea igual al precio de compra en la EM
						----------------------------------------------------------------------------------------------------
						declare @aux nvarchar(254)
						set @VisOrder=-1
						select top 1 @VisOrder=p1.VisOrder+1,@aux=CAST(ISNULL(r1.Currency,2) as nvarchar)+' '+CAST(case when p1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end as nvarchar)+' > '+
							CAST(case when r1.Currency=(select MainCurncy from OADM) then ROUND(r1.LineTotal,0) else ROUND(r1.TotalFrgn,0) end as nvarchar)
						from DRF1 p1
							inner join PDN1 r1 on r1.DocEntry=p1.BaseEntry and r1.LineNum=p1.BaseLine
						where p1.DocEntry=@DocEntry and case when p1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end
						 > case when r1.Currency=(select MainCurncy from OADM) then ROUND(r1.LineTotal,0) else ROUND(r1.TotalFrgn,0) end

						if @VisOrder>0 begin
		
							select	@error = 17
							select	@error_message = N'Se '+@aux+' deben mantener los precios ingresados en la orden de compra. Linea '+cast(@VisOrder as nvarchar)
							return

						end
		
						----------------------------------------------------------------------------------------------------

					end

				end

			end
			
		end
		
		if @ObjType=22 begin

			----------------------------------------------------------------------------------------------------
			--Se debe ingresar un descuento positivo
			----------------------------------------------------------------------------------------------------
		
			if @DiscPrcnt < 0 begin
				select	@error = 1
				select	@error_message = N'El descuento debe ser siempre mayor a cero'
				return
			END
		

			----------------------------------------------------------------------------------------------------
			--Validacion de condicion de pago
			----------------------------------------------------------------------------------------------------
		
			--if (select GroupNum from OCRD where CardCode=@CardCode)!=@GroupNum begin
				
			--	select	@error = 6
			--	select	@error_message = N'Se debe utilizar la condicion de pago del Socio de Negocio: '+
			--	(select PymntGroup from OCTG where GroupNum=(select GroupNum from OCRD where CardCode=@CardCode))
			--	return

			--end

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
			--Usar proveedor autorizado
			----------------------------------------------------------------------------------------------------
		
			if (select GroupCode from OCRD where CardCode=@CardCode)=(select U_STR_VALOR from [@STR_PARAM] where Code='CODGRPRTEM') begin
				
				select	@error = 3
				select	@error_message = N'Las órdenes de compra requieren de un proveedor autorizado'
				return
			
			end
		
			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--No debe estar bloqueado
			----------------------------------------------------------------------------------------------------
		
			--if (select U_STR_APRB from OCRD where CardCode=@CardCode)='Y' begin
				
			--	select	@error = 4
			--	select	@error_message = N'El proveedor está bloqueado'
			--	return
			
			--end
		
			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--Validacion de condicion de pago
			----------------------------------------------------------------------------------------------------
		
			--if (select GroupNum from OCRD where CardCode=@CardCode)!=@GroupNum begin
				
			--	select	@error = 5
			--	select	@error_message = N'Se debe utilizar la condicion de pago: '+
			--	(select PymntGroup from OCTG where GroupNum=(select GroupNum from OCRD where CardCode=@CardCode))
			--	return

			--end

			----------------------------------------------------------------------------------------------------

			set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
			if @RoundDif not between -1*@num and @num begin

				select	@error = 6
				select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
				return

			end
		
			----------------------------------------------------------------------------------------------------
			--Validación que tengan como base una OV
			----------------------------------------------------------------------------------------------------
		
			--select @cont=COUNT(*)
			--from DRF1
			--where DocEntry=@DocEntry and ISNULL(BaseType,0)!=17
		
			--if @cont>0 begin
				
			--	select	@error = 7
			--	select	@error_message = N'Las órdenes de compra deben ser creadas desde el asistente de aprovisionamiento'
			--	return
			
			--end

			----------------------------------------------------------------------------------------------------

			----------------------------------------------------------------------------------------------------
			--Validación que el precio de compra sea menor o igual al precio de compra en la OV
			----------------------------------------------------------------------------------------------------
			--declare @qwe nvarchar(255)
			--set @VisOrder=-1
			--select top 1 @VisOrder=p1.VisOrder+1,@qwe=CAST((r1.Quantity*r1.U_STR_PUPR) as nvarchar)+' < '+
			--	CAST(case when r1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end as nvarchar)
			--from DRF1 p1
			--	inner join RDR1 r1 on r1.DocEntry=p1.BaseEntry and r1.LineNum=p1.BaseLine
			--where p1.DocEntry=@DocEntry and ROUND(r1.Quantity*r1.U_STR_PUPR,0)<
			--	case when r1.Currency=(select MainCurncy from OADM) then ROUND(p1.LineTotal,0) else ROUND(p1.TotalFrgn,0) end

			--if @VisOrder>0 begin
		
			--	select	@error = 8
			--	select	@error_message = N'Las '+@qwe+' órdenes de compra no deben superar lo ingresado en la orden de venta. Linea '+cast(@VisOrder as nvarchar)
			--	return

			--end
		
			----------------------------------------------------------------------------------------------------

		end
	
	if @ObjType=14 begin

					----------------------------------------------------------------------------------------------------
		--Monto mayor a 0
		----------------------------------------------------------------------------------------------------
		
		if @DocTotal < 0 begin
		
			select	@error = 2
			select	@error_message = N'El total del documento debe ser mayor a 0'
			return
		
		end
						
		----------------------------------------------------------------------------------------------------
		--Validación de Nota de Crédito interna fuera de mes de contabilización
		----------------------------------------------------------------------------------------------------
		
		if (((select year(OI.DocDate) from OINV OI where OI.DocEntry=@BaseEntry)<>year(@DocDate) OR (select month(OI.DocDate) from OINV OI where OI.DocEntry=@BaseEntry)<>month(@DocDate)) and @U_BPP_MDSD='999') begin
		
			select	@error = 3
			select	@error_message = N'No se puede crear una nota de crédito interna con una fecha contabilización que no coincide con el mes de la factura'
			return
		
		end
		
		-----------------------------------------------------------
		--- Glosa CRP obligatoria para los artículos DIF000001, DIF000002, DIF000003, DIF000004, DIF000005, DIF000006, ING000001, ING000002, ING000003, ING000018
		-----------------------------------------------------------

 		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from drf1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_glosa,'') = ''
		and  i1.ItemCode in ('DIF000001', 'DIF000002', 'DIF000003', 'DIF000004', 'DIF000005', 'DIF000006', 'ING000001', 'ING000002', 'ING000003', 'ING000018')
	

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E002 El campo Glosa CRP es obligatorio en linea -> '+CAST(@VisOrder as nvarchar)
			return
		
		end

		-----------------------------------------------------------
		--- Glosa Auxiliar obligatoria para los artículos DIF000001, DIF000002, DIF000003, DIF000004, DIF000005, DIF000006, ING000001, ING000002, ING000003, ING000018
		-----------------------------------------------------------

 		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from drf1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_OUT_GLOSA,'') = ''
		and  i1.ItemCode in ('DIF000001', 'DIF000002', 'DIF000003', 'DIF000004', 'DIF000005', 'DIF000006', 'ING000001', 'ING000002', 'ING000003', 'ING000018')
	

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E003 El campo Glosa Auxiliar es obligatorio en linea -> '+CAST(@VisOrder as nvarchar)
			return
		
		end

		-----------------------------------------------------------
		--- Marca obligatoria para los artículos de ingresos
		-----------------------------------------------------------

 		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from drf1 i1 where i1.DocEntry = @DocEntry AND ISNULL(OcrCode2,'') = ''
		AND  i1.ItemCode in (SELECT OI.ItemCode FROM OITM OI WHERE OI.ItmsGrpCod=(SELECT OT.ItmsGrpCod FROM OITB OT WHERE OT.ItmsGrpNam='Ingresos'))
	

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E003 El campo Marca es obligatorio en la línea -> '+CAST(@VisOrder as nvarchar)
			return
		
		end


		-----------------------------------------------------------
		--- Para compras locales la moneda del SN debe ser soles
		-----------------------------------------------------------


		if (@DocCur='USD' AND @CurSource='L') begin
		
			select	@error = 3
			select	@error_message = N'Para una compra con moneda local debe cambiar la moneda del SN a soles -> '
			return
		
		end

		-----------------------------------------------------------
		--- La moneda de la cabecera y el detalle debe ser el mismo
		-----------------------------------------------------------

 		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from drf1 i1 where i1.DocEntry = @DocEntry AND @DocCur<>i1.Currency

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La moneda de la cabecera es distinta del detalle en la línea -> '+CAST(@VisOrder as nvarchar)
			return
		
		end

		----------------------------------------------------------------------------------------------------

	end
	 			
	END

	return

END

