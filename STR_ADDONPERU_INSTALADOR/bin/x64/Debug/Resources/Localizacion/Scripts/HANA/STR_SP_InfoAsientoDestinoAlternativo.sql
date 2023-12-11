CREATE PROCEDURE STR_SP_InfoAsientoDestinoAlternativo
(
	IN fIni NVARCHAR(50),
	IN fFin NVARCHAR(50)
)
AS

BEGIN

	select 	"Codigo"
			,"Cuenta"	
			,"Descripcion"
			,case when "Saldo">=0.0 then ABS("Saldo") else 0.0 end as "Debito"
			,case when "Saldo"< 0.0 then ABS("Saldo") else 0.0 end as "Credito" 
			,"Grupo"
			from
			(
				select 	
						"Codigo"
						,"Cuenta"					
						,"Descripcion" 
						,SUM("Saldo") as "Saldo"
						,"Grupo"								
				from 
				(
					select 
					DENSE_RANK() OVER (ORDER BY t3."AcctCode") AS "Grupo",
					case when tt."Linea" = 1 then t3."AcctCode" 				else t2."AcctCode" 					end as "Codigo",
					case when tt."Linea" = 1 then t3."FormatCode" 				else t0."OcrCode3" 					end	as "Cuenta",																					
					case when tt."Linea" = 1 then t3."AcctName" 				else t2."AcctName" 					end	as "Descripcion",
					case when tt."Linea" = 1 then SUM(t0."Credit" - t0."Debit") else SUM(t0."Debit" - t0."Credit") 	end as "Saldo"
					from JDT1 t0 
					inner join OPRC t1 on t0."OcrCode3" = t1."PrcCode"
					inner join OACT t2 on t2."AcctCode" = t0."Account"
					inner join OACT t3 on t3."AcctCode" = t1."U_STR_LC_CDST"
					inner join OJDT t4 on t0."TransId" = t4."TransId"
					inner join OPCH t5 on t4."CreatedBy" = t5."DocEntry" and t5."DocType" = 'S' and t5."U_STR_ADP" = 'N'
					cross join (select 1 as "Linea" from dummy union all select 2 as "Linea" from dummy) as tt
					where TO_DATE(T0."RefDate") BETWEEN case when :fIni = '' then '19000101' else TO_DATE(:fIni) end AND case when :fFin = '' then CURRENT_DATE else TO_DATE(:fFin) end
					group by t2."AcctCode", t3."AcctCode",tt."Linea",t0."OcrCode3",t3."FormatCode",t2."AcctName",t3."AcctName"
				)		
				group by "Grupo","Codigo","Cuenta","Descripcion"
			);

END;