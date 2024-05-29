CREATE  PROCEDURE ValOpor

--Ordenes de compra.

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

	declare	@NumAtCard		nvarchar(100)
		,	@CardCode		nvarchar(15)
		,	@DocDate		datetime
		,	@DocDueDate		datetime
		,	@TaxDate		datetime
		,	@DocCur			nvarchar(3)
		,	@UserSign2		smallint
		,	@draftKey		int
		,	@Series			smallint
		,	@DocTotal		numeric(19,6)
		,	@DiscPrcnt		numeric(19,6)
		,	@GroupNum		smallint
		,	@RoundDif		numeric(19,6)
		
	--variables del detalle
		,	@VisOrder		int
		,	@cont			int
		,	@SeriesName		nvarchar(20)
		,	@AcctCode		nvarchar(30)
		,	@ItemCode		nvarchar(30)
		,	@U_COSTO		nvarchar(8)
		,	@U_Anticipo		nvarchar(8)
		,	@U_Recon		nvarchar(8)
		,	@U_Canje		nvarchar(8)
		,	@Usuario		int
		,	@U_Area_Crp		nvarchar(10)
		

	select	@NumAtCard		= f.NumAtCard
		,	@CardCode		= f.CardCode
		,	@DocDate		= f.DocDate
		,	@DocDueDate		= f.DocDueDate
		,	@TaxDate		= f.TaxDate
		,	@DocCur			= f.DocCur
		,	@draftKey		= f.draftKey
		,	@Series			= f.Series
		,	@DocTotal		= f.DocTotal
		,	@UserSign2		= f.UserSign2
		,	@DiscPrcnt		= f.DiscPrcnt
		,	@GroupNum		= f.GroupNum
		,	@RoundDif		= f.RoundDif
		,	@Usuario		= ISNULL(f.UserSign2,f.UserSign)
		,  @U_COSTO   = f.U_cCosto
		,  @U_Anticipo = f.U_anticipo100
		,	@U_Recon = f.U_areconciliar
		,	@U_Canje = f.U_canje
		,	@U_Area_Crp = f.U_Area_Crp
		
	from	[dbo].[opor] f with(nolock)
	where	f.DocEntry = @DocEntry

	------------------------------------------------------------------------------------------------
	--Validaciones
	------------------------------------------------------------------------------------------------

	IF (@TipoTransaccion in ('A','U')) BEGIN
	
		----------------------------------------------------------------------------------------------------
		--Se debe ingresar un descuento positivo
		----------------------------------------------------------------------------------------------------
		
		if @DiscPrcnt < 0 begin
			select	@error = 1
			select	@error_message = N'El descuento debe ser siempre mayor a cero'
			return
		END
		
		----------------------------------------------------------------------------------------------------

		----------------------------------------------------------------------------------------------------
		--Monto mayor a 0
		----------------------------------------------------------------------------------------------------
		
		if @DocTotal < 0 begin
				
			select	@error = 2
			select	@error_message = N'El total del documento debe ser mayor a 0'
			return
		
		end
		

		----------------------------------------------
		----  Centro de costo en campo de usuario no esta vacio 
		--------------------------------------------------------
		-------------------------------------------------------------

		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and ISNULL(T0.U_cCosto,'') !=  T1.OcrCode


		if (  @U_COSTO!= 'multiple' AND @U_COSTO!= 'Sin CC' ) begin 
		
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E002 CC especifico a nivel de Campo de usuario (OPOR) debe ser igual a nivel de detalle  '  
			return
		
		end
		                             end



		----------------------------------------------------------------------------------------------------
		
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		and OcrCode in ( '252','253' )
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E001 El proyecto es obligatorio para los centros de costo (252,253)  '+CAST(@VisOrder as nvarchar)
			return
		
		end
		
			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(Project,'') = ''
		and OcrCode in ( '255' ) and U_STR_Part_Des='Costos Operativos Conciertos'
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E001 El proyecto es obligatorio para el centro de costo 255 cuando use la partida Costos Operativos Conciertos  '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') = ''
		
		if @VisOrder > 0 begin
		
		select	@error = 3
			select	@error_message = N'E004 La dimension de Centro de Costo es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
		return
		
		end

		--Requerimiento: Para artículo "construcciones en curso", siempre pedir campo proyecto
		
                          
        set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
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
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and @CardCode like 'PEX%' and T1.ItemCode like 'AFJ%' and (select ItemName from OITM OI where OI.ItemCode=T1.ItemCode) like '%Compra Local'
	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 No se puede ingresar un artículo de AF local para un SN extranjero en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
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
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and (select OC.QryGroup24 from ocrd OC where OC.cardcode=@CardCode) ='N' and T1.ItemCode like 'AFJ%'

	
		if @VisOrder > 0 begin
		
			select	@error = 10
			select	@error_message = N'E006 El proveedor no cuenta con la propiedad para la creación de artículos de activo fijo en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		set @VisOrder=-777

		--		

			set @VisOrder=-776
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Marca es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		
			set @VisOrder=-775
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode3,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode4,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension Ciudades - Planta  es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

		--	Validación de poner como obligatorio el campo Descripción CRP

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and ISNULL(U_descripcion2,'') = ''
		
		if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 El campo Descripción CRP es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end
				
		--	validación de crear partidas presupuestales del 2016 sólo para contabilidad

	if @Usuario not in (select UserID from OWTM w0 inner join WTM1 w1 on w0.WtmCode=w1.WtmCode where Name='Usuarios-Partidas-Pr')
	begin	

			set @VisOrder=-774
		select top 1 @VisOrder = VisOrder+1 from POR1 i1 where i1.DocEntry = @DocEntry and LEFT(u_str_partidaPr,3) = 'P16'
		
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
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%'
	
			if @VisOrder > 0 begin
		
				select	@error = 10
				select	@error_message = N'No tiene permiso para crear una OC con un artículo de Activo Fijo en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		end		

		--	Validación para que al seleccionar AF - Activo Fijo sea obligatrio que se seleccione un artículo de Activo Fijo

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T0.U_Area_Crp='AF'
	
			if @VisOrder = -777 AND @U_Area_Crp='AF' begin
		
				select	@error = 11
				select	@error_message = N'La opción del campo Área CRP AF - Activo Fijo es sólo para la compra de Activos'
				return
		
			end

		--	Validación para que por la compra de un activo se elija de forma obligatoria el área CRP AF - Activo Fijo

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T0.U_Area_Crp<>'AF'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe seleccionar el Área CRP AF - Activo Fijo'
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el CC 011

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode<>'011'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar el CC 011 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el Marca 10

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode2<>'10'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar la Marca 10 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el Ciudad/Planta LIM1

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode4<>'LIM1'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar la Ciudad/Planta LIM1 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se creen Líneas de AF con el CC 011

			set @VisOrder=-777
			select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
			where T0.DocEntry = @DocEntry AND T1.ItemCode like 'AFJ%' AND T1.OcrCode<>'011'
	
			if @VisOrder > 0 begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de un activo debe usar el CC 011 en la línea '+CAST(@VisOrder as nvarchar)
				return
		
			end

		--	Validación para que sólo se cree con el campo Área CRP AF - Activo Fijo para los centros de costo 011(Sin CC) y multilple

			if((select T0.U_Area_Crp A from OPOR T0 where T0.DocEntry = @DocEntry AND T0.U_Area_Crp='AF' AND (T0.U_cCosto not in ('011','Sin CC','Multiple')))='AF') begin
		
				select	@error = 11
				select	@error_message = N'Para la compra de AF los CECO pueden ser sólo el 011 y Multiple'
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

			-----------valida CCcon tabla CC--------

		declare	@USUARIO_CODIGO		nvarchar(100)
		set @VisOrder=0
		set	@USUARIO_CODIGO =    (select USER_CODE from OUSR where USERID=@UserSign2) 

		select top 1 @VisOrder = VisOrder+1 from por1 i1 where i1.DocEntry = @DocEntry and ISNULL(OcrCode,'') not in (
		select U_C_costo from  [dbo].[@STR_CC] where [U_Usuario_VAL] = @USUARIO_CODIGO)

		if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'No tienes permiso para la dimension en la linea  '+CAST(@VisOrder as nvarchar)
			return
		
		end
		----

		----------------------------------------------------------------------------------------------------
		--Usar proveedor autorizado
		----------------------------------------------------------------------------------------------------
		
		--if (select GroupCode from OCRD where CardCode=@CardCode)=(select U_STR_VALOR from [@STR_PARAM] where Code='CODGRPRTEM') begin
				
		--	select	@error = 3
		--	select	@error_message = N'Las órdenes de compra requieren de un proveedor autorizado'
		--	return
			
		--end
		
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

		--declare @num numeric(10,2)
		--set @num=ISNULL((select U_STR_VALOR from [@STR_PARAM] where Code='REDMAX'),0)
			
		--if @RoundDif not between -1*@num and @num begin

		--	select	@error = 6
		--	select	@error_message = N'El redondeo debe ser menor a '+CAST(@num as nvarchar)
		--	return

		--end
		


		
			 



--		set @SeriesName=(select RIGHT(SeriesName,3) from NNM1 where Series=@Series)
	/*	if @SeriesName in (select U_STR_VALOR from [@STR_PARAM] where Code in ('SEROPE001','SERGEN001','SERCOR001')) begin

			----------------------------------------------------------------------------------------------------
		 
			----------------------------------------------------------------------------------------------------
		 
		  
		
			----------------------------------------------------------------------------------------------------
        ---------------------------------------------------------------------------------
		---VALIDACION DE CC por linea -------------
		------------------------------------------





			----------------------------------------------------------------------------------------------------
			--Todos los documentos deben pasar por aprobación
			----------------------------------------------------------------------------------------------------
		
			--if @draftKey is null begin
				
			--	select	@error = 9
			--	select	@error_message = N'Todas las órdenes de compra deben pasar por proceso de aprobación'
			--	return
			
			--end

			----------------------------------------------------------------------------------------------------

		end
		*/
	--	update OPOR set U_OUT_MNTO=dbo.ObtMontoTexto(@DocCur,case when DocTotalFC=0 then DocTotal else DocTotalFC end) where DocEntry = @DocEntry
		
if (  ISNULL(@U_Recon,'')= '' ) 
	begin 		
	
			select	@error = 10
			select	@error_message = N' Defina si se va Reconciliar'  
			return		

		                             
	end

if (  ISNULL(@U_Canje,'')= '' ) 
	begin 		
	
			select	@error = 10
			select	@error_message = N'Defina el Tipo de Compra'  
			return		

		                             
	end

if (  ISNULL(@U_Anticipo,'')= '' ) 
	begin 		
	
			select	@error = 10
			select	@error_message = N' Ingrese Tipo de Anticipo'  
			return		

		                             
	end

			set @VisOrder=-777
		select top 1 @VisOrder = VisOrder+1 from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = T1.[DocEntry]
		
		where T0.DocEntry = @DocEntry and ISNULL(T0.U_cCosto,'') !=  T1.OcrCode
		
			declare @MULTIPLE varchar(8)
	--	set @MULTIPLE = (select  top 1 U_cCosto  from ODRF T0  INNER JOIN DRF1 T1 ON T0.[DocEntry] = T1.[DocEntry]  )

	--	select    U_cCosto  from OPOR T0  INNER JOIN POR1 T1 ON T0.[DocEntry] = 23

if (  ISNULL(@U_COSTO,'')= '' ) 
	begin 		
		if @VisOrder > 0 begin		
			select	@error = 10
			select	@error_message = N' Ingrese CECO'  
			return		
		end
		                             
	end

	END
	
	
	--IF @TipoTransaccion='C' BEGIN	
	
	--	if @UserSign=(select USERID from OUSR where USER_CODE=(select U_Valor from [@STR_PARAM] where Code='OCUSUCAN')) begin
		
	--		select	@error = 1
	--		select	@error_message = N'Solo puede cerrar una orden de compra el usuario '+(select U_NAME from OUSR where USER_CODE=(select U_Valor from [@STR_PARAM] where Code='OCUSUCAN'))
	--		return
			
	--	end
	
	--END

----------------------------------------------------------------------------------------------------
-- No está permitido actualizar la data una vez creada la OC
----------------------------------------------------------------------------------------------------
	

	--IF (@TipoTransaccion in ('U')) BEGIN

	--	select	@error = 50
	--			select	@error_message = N'No está permitido modificar una OC una vez creada'
	--			return

	--END
	
END

