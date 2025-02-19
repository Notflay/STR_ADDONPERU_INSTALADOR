CREATE PROCEDURE STR_SP_LT_DetalleLetras
(
@CodCliente nvarchar(20),
@FecIni datetime,
@FecFin datetime,
@Estado nvarchar(10),
@banco nvarchar(10)
)
as
begin
if @CodCliente = '' set @CodCliente = null
if @Estado = '' set @Estado = null
	if @banco = ''		
	begin		
		SELECT 
		'TransId'		=	T0.TransId, 
		'Letra'			=	T1.Ref2, 
		'Estado'		=	CASE   
								WHEN T1.U_LET_EST = '002' THEN 'Cartera'  
								WHEN T1.U_LET_EST = '003' THEN 'Enviado Cobranza'  
								WHEN T1.U_LET_EST = '004' THEN 'Cobranza Libre'  
								WHEN T1.U_LET_EST = '005' THEN 'Cobranza Garantía'  
								WHEN T1.U_LET_EST = '006' THEN 'Enviado Descuento'  
								WHEN T1.U_LET_EST = '007' THEN 'Descuento' 
								WHEN T1.U_LET_EST = '008' THEN 'Protesto'  
								ELSE '0'  
							END  ,
		'Fecha'			=	T1.RefDate, 
		'Comentario'	=	T1.Memo,
		'Banco'			=  (select BankName from odsc where BankCode = T3.U_nomBan)
		,cast(ROW_NUMBER() OVER(PARTITION BY T1.REF2 ORDER BY T0.TRANSID) as int)'ID'
		INTO #TEMP
		FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0.TransId = T1.TransId 
		left join
		(select U_nroInt,U_nomBan from [@ST_LT_DEPLET] X0 inner join [@ST_LT_DEPDET] X1 on  X0.DocEntry = X1.DocEntry) T3
		on T1.TransId = t3.U_nroInt
		WHERE T0.ShortName = isnull(@CodCliente, t0.ShortName) AND T1.TransType = '30' and t0.RefDate between
		@FecIni and @FecFin and t1.U_LET_EST = isnull(@Estado,t1.U_LET_EST) 
		
		DELETE #TEMP WHERE ID = 1 AND Letra IN (SELECT Letra from #TEMP WHERE ID = 2)	

		SELECT * FROM #TEMP
		ORDER BY 2	
	end
	else
	begin
		SELECT 
		'TransId'		=	T0.TransId, 
		'Letra'			=	T1.Ref2, 
		'Estado'		=	CASE   
								WHEN T1.U_LET_EST = '002' THEN 'Cartera'  
								WHEN T1.U_LET_EST = '003' THEN 'Enviado Cobranza'  
								WHEN T1.U_LET_EST = '004' THEN 'Cobranza Libre'  
								WHEN T1.U_LET_EST = '005' THEN 'Cobranza Garantía'  
								WHEN T1.U_LET_EST = '006' THEN 'Enviado Descuento'  
								WHEN T1.U_LET_EST = '007' THEN 'Descuento' 
								WHEN T1.U_LET_EST = '008' THEN 'Protesto'  
								ELSE '0'  
							END  ,
		'Fecha'			=	T1.RefDate, 
		'Comentario'	=	T1.Memo,
		'Banco'			=  (select BankName from odsc where BankCode = T3.U_nomBan)
		,cast(ROW_NUMBER() OVER(PARTITION BY T1.REF2 ORDER BY T0.TRANSID) as int)'ID'
		INTO #TEMP1
		FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0.TransId = T1.TransId 
		left join
		(select U_nroInt,U_nomBan from [@ST_LT_DEPLET] X0 inner join [@ST_LT_DEPDET] X1 on  X0.DocEntry = X1.DocEntry) T3
		on T1.TransId = t3.U_nroInt
		WHERE T0.ShortName = isnull(@CodCliente, t0.ShortName) AND T1.TransType = '30' and t0.RefDate between
		@FecIni and @FecFin and t1.U_LET_EST = isnull(@Estado,t1.U_LET_EST) and T3.U_nomBan = @banco 
		
		DELETE #TEMP1 WHERE ID = 1 AND Letra IN (SELECT Letra from #TEMP1 WHERE ID = 2)	

		SELECT * FROM #TEMP1
		ORDER BY 2
	end
end





 