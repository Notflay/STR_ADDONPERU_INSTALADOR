CREATE PROCEDURE STR_SP_InfoAsientoDestino
@fIni as NVARCHAR(50),
@fFin as NVARCHAR(50)
AS
BEGIN
	SET DATEFORMAT dmy
    DECLARE @SEGMENTADO CHAR(1);

	--Modidicado el 20140812 DGC
	--Se adiciono campo de usuario para distinguir de las cuentas que generaran un asiento de destino.
	--Plan de cuentas - U_STR_DESTINO

  set @SEGMENTADO  = (SELECT TOP 1 EnbSgmnAct   FROM CINF);
  
	IF @SEGMENTADO = 'Y' BEGIN
		select 

	[Codigo],
	[Cuenta],
	[Descripcion],
	CASE when [Saldo]>=0.0 then ABS([Saldo]) else 0.0 end as 'Debito',
	CASE when [Saldo]<0.0 then ABS([Saldo]) else 0.0 end as 'Credito'

	from
	(
		select 
		(select top 1 U_BPP_CdgCuenta from [@BPP_CONFIG]) as 'Codigo', 
		(select top 1 U_BPP_FmtCuenta from [@BPP_CONFIG]) as 'Cuenta', 
		(select top 1 U_BPP_NmbCuenta from [@BPP_CONFIG]) as 'Descripcion', 
		SUM([Credito]) as 'Debito', 
		SUM([Debito]) as 'Credito',
		(SUM([Credito]) - SUM([Debito])) as 'Saldo'
		from (
			select 
			/*T1.AcctCode*/'' as 'Codigo', /*T0.OcrCode3*/'' as 'Cuenta', /*T1.AcctName*/'' as 'Descripcion', SUM(T0.Debit) as 'Debito', SUM(T0.Credit) as 'Credito' 
			from 
			JDT1 T0 inner join OACT T1 on T0.OcrCode3=T1.Segment_0 
					inner join OACT T2 ON T0.Account=T2.AcctCode
			where 
			isnull(T0.OcrCode3, '')<>'' 
			and (T0.OcrCode3 like '9%' or T0.OcrCode3 like '6%')
			and T0.RefDate between CONVERT(DATETIME, @fIni) and CONVERT(DATETIME, @fFin)
			and T2.U_STR_DESTINO='Y'
			Group By OcrCode3, T1.AcctName, T1.AcctCode
			) CD

		UNION ALL

		select 
		T1.AcctCode as 'Codigo', 
		T0.OcrCode3 as 'Cuenta', 
		T1.AcctName as 'Descripcion', 
		SUM(T0.Debit) as 'Debito', 
		SUM(T0.Credit) as 'Credito',
		(SUM(T0.Debit) - SUM(T0.Credit)) as 'Saldo'
		from 
		JDT1 T0 inner join OACT T1 on T0.OcrCode3=T1.Segment_0
				inner join OACT T2 ON T0.Account=T2.AcctCode 
		where 
		isnull(T0.OcrCode3, '')<>'' 
		and (T0.OcrCode3 like '9%' or T0.OcrCode3 like '6%')
		and T0.RefDate between CONVERT(DATETIME, @fIni) and CONVERT(DATETIME, @fFin)
		and T2.U_STR_DESTINO='Y'
		Group By OcrCode3, T1.AcctName, T1.AcctCode
	) CtaDst
	end
	ELSE IF @SEGMENTADO = 'N' BEGIN
	select 

	[Codigo],
	[Cuenta],
	[Descripcion],
	CASE when [Saldo]>=0.0 then ABS([Saldo]) else 0.0 end as 'Debito',
	CASE when [Saldo]<0.0 then ABS([Saldo]) else 0.0 end as 'Credito'

	from
	(
		select 
		(select top 1 U_BPP_CdgCuenta from [@BPP_CONFIG]) as 'Codigo', 
		(select top 1 U_BPP_FmtCuenta from [@BPP_CONFIG]) as 'Cuenta', 
		(select top 1 U_BPP_NmbCuenta from [@BPP_CONFIG]) as 'Descripcion', 
		SUM([Credito]) as 'Debito', 
		SUM([Debito]) as 'Credito',
		(SUM([Credito]) - SUM([Debito])) as 'Saldo'
		from (
			select 
			/*T1.AcctCode*/'' as 'Codigo', /*T0.OcrCode3*/'' as 'Cuenta', /*T1.AcctName*/'' as 'Descripcion', SUM(T0.Debit) as 'Debito', SUM(T0.Credit) as 'Credito' 
			from 
			JDT1 T0 --inner join OACT T1 on T0.OcrCode3=T1.Segment_0 
					inner join OACT T1 ON T0.OcrCode3=T1.AcctCode 
			where 
			isnull(T0.OcrCode3, '')<>'' 
			and (T0.OcrCode3 like '9%' or T0.OcrCode3 like '6%')
			and T0.RefDate between CONVERT(DATETIME, @fIni) and CONVERT(DATETIME, @fFin)
			and T1.U_STR_DESTINO='Y'
			Group By OcrCode3, T1.AcctName, T1.AcctCode
			) CD

		UNION ALL

		select 
		T1.AcctCode as 'Codigo', 
		T0.OcrCode3 as 'Cuenta', 
		T1.AcctName as 'Descripcion', 
		SUM(T0.Debit) as 'Debito', 
		SUM(T0.Credit) as 'Credito',
		(SUM(T0.Debit) - SUM(T0.Credit)) as 'Saldo'
		from 
		JDT1 T0 --inner join OACT T1 on T0.OcrCode3=T1.Segment_0
				inner join OACT T1 ON T0.OcrCode3=T1.AcctCode 
		where 
		isnull(T0.OcrCode3, '')<>'' 
		and (T0.OcrCode3 like '9%' or T0.OcrCode3 like '6%')
		and T0.RefDate between CONVERT(DATETIME, @fIni) and CONVERT(DATETIME, @fFin)
		and T1.U_STR_DESTINO='Y'
		Group By OcrCode3, T1.AcctName, T1.AcctCode
	) CtaDst

	END
END