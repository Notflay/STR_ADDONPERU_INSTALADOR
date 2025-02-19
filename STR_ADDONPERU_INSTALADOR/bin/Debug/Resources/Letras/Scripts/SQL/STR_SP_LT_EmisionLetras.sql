CREATE PROCEDURE STR_SP_LT_EmisionLetras
(
@NumEmi int
)
as
begin
	
	select U_CardCode, U_CardName, U_EmiDate, U_CantLet, t1.Address 
	into #TEMPCAB
	from [@ST_LT_EMILET] t0 inner join OCRD t1 on t0.U_CardCode = t1.CardCode 
	where t0.DocEntry = @NumEmi
	
	select 
	ROW_NUMBER() over(order by t1.u_docentry) 'D_LineaDoc', t1.U_DocEntry 'D_DocEntry', t1.U_tipDoc 'D_TipoDoc', 
	t1.U_numLeg 'D_Legal', t1.U_Pago 'D_Monto', t1.U_DocCurr 'D_Moneda',
	(select tx.DocDate from OINV tx where tx.DocEntry = t1.U_DocEntry and t1.u_tipDoc = 'FA') 'D_Fecha',
	U_Total 'D_MontoDoc',
	cast(round(U_Total /t1.U_Pago*100,0) as int) 'D_Porcentaje'
	into #TEMPDOC
	from [@ST_LT_ELDOCS] t1 where t1.U_chkSel = 'Y' and t1.DocEntry = @NumEmi
	
	select 
	ROW_NUMBER() over(order by t2.U_NumAsi) 'L_LineaLetra', t2.U_diaLet 'L_Dias', t2.U_DocCurr 'L_Moneda', 
	case when t2.U_DocCurr = 'SOL' then t2.U_ImpML else t2.U_ImpME end 'L_Monto', 
	t2.U_NumAsi 'L_Asiento', t2.U_codLet 'L_Letra', t2.U_VencDate 'L_VencLetra'
	into #TEMPLET 
	from [@ST_LT_ELLETRAS] t2 where t2.DocEntry = @NumEmi
	
	create table #FINAL
	(
		C_CardCode		nvarchar(20),
		C_CardName		nvarchar(200),
		C_FecEmi		datetime,
		C_CantLet		int,
		C_NumCanje		int,
		C_Dato1			nvarchar(200),
		C_Dato2			nvarchar(200),
		D_LineaDoc		int,
		D_DocEntry		int,
		D_TipoDoc		nvarchar(10),
		D_Legal			nvarchar(20),
		D_Monto			numeric(19,6),
		D_Moneda		nvarchar(10),
		D_Fecha			datetime,
		D_MontoDoc		numeric(19,6),
		D_Dato1			nvarchar(20),
		D_Dato2			nvarchar(20),
		D_PorcCanje		int,
		L_LineaLetra	int,
		L_Dias			int,
		L_Moneda		nvarchar(10),
		L_Monto			numeric(19,6),
		L_Asiento		int,
		L_Letra			nvarchar(20),
		L_VencLet		datetime,
		L_Dato1			nvarchar(20),
		L_Dato2			nvarchar(20)
	)
	
	if ((select COUNT(*) from #TEMPDOC)>(select COUNT(*) from #TEMPLET))
		begin
			insert into #FINAL 
			(D_LineaDoc,D_DocEntry,D_TipoDoc,D_Legal,D_Monto,D_Moneda, D_Fecha, D_MontoDoc, D_PorcCanje,
			L_LineaLetra, C_CardCode, C_CardName, C_FecEmi, C_CantLet,C_NumCanje, C_Dato1  )
			select t0.*, D_LineaDoc, t1.U_CardCode, t1.U_CardName, t1.U_EmiDate, t1.U_CantLet, @NumEmi, t1.Address   from #TEMPDOC t0 , #TEMPCAB t1
			update t0
			set t0.L_Asiento = t1.L_Asiento,
				t0.L_Dias = t1.L_Dias,
				t0.L_Letra = t1.L_Letra,
				t0.L_Moneda = t1.L_Moneda,
				t0.L_Monto = t1.L_Monto,
				t0.L_VencLet = t1.L_VencLetra 				
			from #FINAL t0 inner join #TEMPLET t1 on t0.L_LineaLetra = t1.L_LineaLetra 
		end
	else
		begin
			insert into #FINAL 
			(L_LineaLetra,L_Dias,L_Moneda,L_Monto,L_Asiento,L_Letra, L_VencLet,
			D_LineaDoc, C_CardCode, C_CardName, C_FecEmi, C_CantLet, C_NumCanje, C_Dato1 )
			select t0.*, L_LineaLetra, t1.U_CardCode, t1.U_CardName, t1.U_EmiDate, t1.U_CantLet, @NumEmi, t1.Address   from #TEMPLET t0 , #TEMPCAB t1
			
			update t0
			set t0.D_DocEntry = t1.D_DocEntry,
				t0.D_Legal = t1.D_Legal,
				t0.D_Moneda = t1.D_Moneda,
				t0.D_Monto = t1.D_Monto,
				t0.D_TipoDoc = t1.D_TipoDoc,
				t0.D_MontoDoc = t1.D_MontoDoc,
				t0.D_PorcCanje = t1.D_Porcentaje ,
				t0.D_Fecha = t1.D_Fecha 
			from #FINAL t0 inner join #TEMPDOC t1 on t0.D_LineaDoc = t1.D_LineaDoc
		end
	
	select * from #FINAL
end