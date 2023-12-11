CREATE PROCEDURE STR_SP_ListarLetrasSinAsiento
(
	tpo char(2),
	snd varchar(20),
	snh varchar(20),
	fed timestamp,
	feh timestamp,
	fcd timestamp,
	fch timestamp
)
as
begin

	if ifnull(:tpo,'')='' 
	then 
		select 'CP' into tpo from dummy; 
	end if; 
	
	if ifnull(:snd,'')='' 
	then 
		select MIN("CardCode") into snd from OCRD; 
	end if;
	 
	if ifnull(:snh,'')='' 
	then 
		select MAX("CardCode") into snh from OCRD; 
	end if;	
	
	if ifnull(:fed,'')='' 
	then 
		select '19000101' into fed from dummy; 
	end if;
	
	if ifnull(:feh,'')='' 
	then 
		select '99991231' into feh from dummy; 
	end if;
	
	if ifnull(:fcd,'')='' 
	then 
		select '19000101' into fcd from dummy; 
	end if;
	
	if ifnull(:fch,'')='' 
	then 
		select '99991231'into fch from dummy;
	end if;
	
	select 
		'Y' as "Selec",
		T0."U_CardCode"	as "Soc. Negocios",
		T1."U_codLet" as "Nro. Letra",
		T0."U_EmiDate" as "Fecha Emision",
		T0."U_TxEmiDat" as "Fecha Contabilizacion",
		T1."U_VencDate" as "Fecha de Vencimiento",
		TO_DECIMAL(T1."U_ImpME",19,6) as "Monto Emision",
		'LXC' AS "Codigo",
		T0."U_SerLetra" as "Serie",
		'001' as "Tipo", 
		T0."U_DocCurr" as "Moneda",
		T0."U_EstLet" as "Estado",
		T2."AcctCode" as "Cuenta1",
		TEX."U_cuenta" as "Cuenta2",
		'' AS "Memo",
		T0."DocEntry" as "Id Emision",
		T1."LineId" as "Nro Linea"
	from "@ST_LT_EMILET" T0 inner join "@ST_LT_ELLETRAS" T1
	on T0."DocEntry" = T1."DocEntry" inner join CRD3 T2 on T0."U_CardCode" = T2."CardCode" cross join 
	(select "U_cuenta" from "@ST_LT_CONF" where "Code" = '00000005') as TEX
	where IFNULL(T1."U_codLet",'') != '' AND IFNULL(T1."U_NumAsi",'0')='0' 
	AND IFNULL("U_DocStat",'') = 'C'  AND T0."U_EstLet" = '002' AND T2."AcctType" = 'R'
	AND T0."U_CardCode" between :snd and :snh 
	AND T0."U_EmiDate" between :fed and :feh
	AND T0."U_TxEmiDat" between :fcd and :fch;
end