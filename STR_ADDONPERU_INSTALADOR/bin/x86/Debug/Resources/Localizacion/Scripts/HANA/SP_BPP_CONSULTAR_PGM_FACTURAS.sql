CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_FACTURAS
(
IN IDNUMBER INT
)
aS
BEGIN
	
select 
t1."WizardName",
t0."InvKey",
t0."DocNum",
t0."CardCode",
t0."CardName",
t0."NumAtCard",
t0."PayAmount" "Saldo Pendiente",
t0."InvPayAmnt" "Importe a Pagar" 

from pwz3 t0
inner join opwz t1 on t0."IdEntry"=t1."IdNumber"
where t0."IdEntry"=IDNUMBER and t0."Checked"='Y';


END