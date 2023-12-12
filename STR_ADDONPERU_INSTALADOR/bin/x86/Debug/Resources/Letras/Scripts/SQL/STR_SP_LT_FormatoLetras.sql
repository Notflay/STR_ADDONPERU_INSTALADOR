CREATE PROCEDURE STR_SP_LT_FormatoLetras
(
@Letra int
)
as
begin

	
	declare @Monto numeric(19,6)
	declare @Moneda nvarchar(10)
	declare @CodSN nvarchar(20)
	select @Monto = LocTotal, @Moneda = case when isnull(TransCurr,'')='' then 'SOL' else TransCurr end  from OJDT where TransId = @Letra 
	
	select @CodSN = t2.CardCode  from OJDT t0 inner join JDT1 t1 on t0.TransId = t1.TransId 
	inner join OCRD t2 on t1.ShortName = t2.CardCode where t0.TransId = @Letra 
	
	declare @MontoLetras nvarchar(250)
	create table #desc (Nombre nvarchar(250))
	insert into #desc 
	exec [sp_Num2Let] @Monto, @Moneda
	select @MontoLetras = Nombre from #desc 
	
	select Ref2 'NumLetra','' 'RefGirador', 'LIMA' 'LugarGiro', 
	convert(nvarchar,RefDate,101) 'FechaGiro', convert(nvarchar,DueDate,101) 'FechaVenc',
	LocTotal 'MontoLetra', @MontoLetras 'TextoLetra', 
	(select CardName from OCRD where CardCode = @CodSN) 'Girado',	
	(select Address from OCRD where CardCode = @CodSN) 'Domicilio',
	(select LicTradNum from OCRD where CardCode = @CodSN) 'DOI',
	(select Phone1 from OCRD where CardCode = @CodSN) 'Telefono'
	from OJDT t0 where TransId = @Letra 
end