CREATE PROCEDURE ValOjdt

--Asientos

(
	@TransId			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 


	declare @StornoToTr		int
		,	@Transtype		nvarchar(3)
		,	@VisOrder		int
		,	@Series			smallint
	--otras variables
		,	@CodCta			nvarchar(30)

	select	@StornoToTr		= a.StornoToTr
		,	@Transtype		= a.TransType
		,	@Series			= a.Series
	
	from	OJDT a
	Where	TransId=@TransId
	

	if @TipoTransaccion in ('A','U')   and @Transtype=30 begin
	 

		 select top 1 @VisOrder = Line_ID+1 from  JDT1 T1 
		 where T1.transid = @TransId	   and    T1.Account
		  in    ( select  U_codigoC from   [dbo].[@STR_VALIDA6ASIENTO]   ) and ISNULL(T1.ProfitCode,'') = ''    

	 if @VisOrder > 0 begin
		
			select	@error = 3
			select	@error_message = N'E004 La dimension de Centro de Costo es obligatorio en la linea    '+CAST(@VisOrder as nvarchar)
			return
		
		end
	
	
			select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	    and  T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDA6ASIENTO]    )
		 and ISNULL(T1.OcrCode2,'') = ''        
  
	 if @VisOrder > 0 begin
		
			select	@error = 4
			select	@error_message = N'E004 La dimension marcas es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end
	

			select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	 and    T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDA6ASIENTO]    )
		 and ISNULL(T1.OcrCode3,'') = ''        
  
	 if @VisOrder > 0 begin
		
			select	@error = 5
			select	@error_message = N'E004 La dimension cuenta destino es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


			select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	 and    T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDA6ASIENTO]    )
		 and ISNULL(T1.OcrCode4,'') = ''        
  
	 if @VisOrder > 0 begin
		
			select	@error = 6
			select	@error_message = N'E004 La dimension Ciudad-Planta es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

---------------------------------------------------
-- Validación artículo en base a la cuenta de gastos --
---------------------------------------------------

			select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	 and    T1.U_STR_Articulo not in (select OM.ItemCode from OITM OM INNER JOIN OITW OW  on OM.ItemCode=OW.ItemCode where T1.Account=OW.ExpensesAc and OM.GLMethod = 'L' UNION ALL
		 select OM.ItemCode from OITM OM INNER JOIN OITB OB  on OM.ItmsGrpCod=OB.ItmsGrpCod where T1.Account=OB.ExpensesAc and OM.GLMethod = 'C' UNION ALL
		 select OM.ItemCode from OITM OM INNER JOIN OWHS OW  on OM.DfltWH=OW.WhsCode where T1.Account=OW.ExpensesAc and OM.GLMethod = 'W')
		 and T1.Account like '6%'       
  
	 if @VisOrder > 0 begin
		
			select	@error = 6
			select	@error_message = N'E004 El artículo usado no está definido para la cuenta de gastos en la línea '+CAST(@VisOrder as nvarchar)
			return
		
		end

---------------------------------------------------
-- Validación fecha de Presupuesto --
---------------------------------------------------

			select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	 and    T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDASUMASIENT]    )
		 and ISNULL(T1.U_STR_Mes,'') = ''        
  
	 if @VisOrder > 0 begin
		
			select	@error = 6
			select	@error_message = N'E004 La dimension Fecha_Ppto es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end

---------------------------------------------------
-- Validación cuentas 7 --
---------------------------------------------------

	select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	    and  T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDA7ASIENTO]    )
		 and ISNULL(T1.OcrCode2,'') = ''        
  
  
	 if @VisOrder > 0 begin
		
			select	@error = 7
			select	@error_message = N'E004 La dimension Marcas es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end
	 

	 
	select top 1 @VisOrder = Line_ID+1 from OJDT T0  INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId]
		 where T0.transid = @TransId	    and  T1.Account in    ( select  U_codigoC from   [dbo].[@STR_VALIDA7ASIENTO]    )
		 and ISNULL(T1.OcrCode4,'') = ''        
  
  
	 if @VisOrder > 0 begin
		
			select	@error = 8
			select	@error_message = N'E004 La dimension Ciudad - Planta es obligatorio en la linea '+CAST(@VisOrder as nvarchar)
			return
		
		end


	select top 1 @VisOrder = Line_ID+1 from  JDT1 T1 
		 where T1.transid = @TransId	   and    T1.U_STR_PartidaPre
		  not in    ( select  U_STR_Code from   "@STR_PART_PRESUP"   ) and LEFT((SELECT SEGMENT_0 FROM OACT WHERE AcctCode= T1.Account),1)='6'   

	 if @VisOrder > 0 begin
		
			select	@error = 9
			select	@error_message = N'E004 La Partida Presupuestal no Existe    '+CAST(@VisOrder as nvarchar)
			return
		
		end
	 

	 
	end

return

END

