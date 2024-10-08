CREATE PROCEDURE STR_SP_LT_HistorialLetras
(
@Letra nvarchar(50)
)
as
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
	'Comentario'	=	T1.Memo	 	
	,cast(ROW_NUMBER() OVER(PARTITION BY T1.REF2 ORDER BY T0.TRANSID) as int)'ID'
	INTO #TEMP
	FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0.TransId = T1.TransId   
	WHERE T1.Ref2 = @Letra
	
	SELECT * FROM #TEMP
end