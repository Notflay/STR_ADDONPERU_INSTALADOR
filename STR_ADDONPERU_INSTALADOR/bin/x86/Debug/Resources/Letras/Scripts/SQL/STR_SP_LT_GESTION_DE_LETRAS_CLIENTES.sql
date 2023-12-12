CREATE PROCEDURE STR_SP_LT_GESTION_DE_LETRAS_CLIENTES
@codSN as varchar(20),
@EstLet as varchar(5) 
as
SELECT 'N' 'Sel', T0.TransId 'NumInt', T1.REF2 NumLetra,(SELECT Top 1 TE.TAXDATE from OJDT TE where TE.REF2 = T1.REF2 
and TE.U_LET_EST = '002') 'FecEmi',T0.DueDate 'FecVen', T1.U_LET_MON 'Moneda', T0.Line_ID 'LineaAs', CASE WHEN 
(SELECT top 1 MainCurncy from OADM) = T1.U_LET_MON then 1 else (select top 1 rate from ortt where currency=T1.U_LET_MON 
and datediff(dd,T1.refdate,ratedate)=0) end 'TC',CASE WHEN (SELECT top 1 MainCurncy from OADM) = T1.U_LET_MON then Debit else FCDebit 
end 'Importe',CASE WHEN (SELECT top 1 MainCurncy from OADM) = T1.U_LET_MON then BalDueDeb else BalFcDeb end 'Saldo', ISNULL((select top 1 
U_MntPrc from [@ST_LT_ELLETRAS] where U_NumAsi = T1.TransId and (isnull(U_NumAsi,'')<>'')),(select top 1 U_MntPrc from [@ST_LT_RENEMI] 
where U_nroInt = T1.TransId)) 'Percepcion',(select top 1 u_numUni from [@ST_LT_DEPDET] where u_nrointDe = T0.Transid) 'NumUni', 
isnull((select top 1 BankDiscou from [@ST_LT_DEPLET] TX inner join [@ST_LT_DEPDET] TX1 on TX.DocEntry = TX1.DocEntry inner join [DSC1] TX2 
on TX2.AbsEntry = TX.u_ctaBan where TX1.u_nrointDe = T0.Transid),T1.U_DEP_CR) 'CtaResp', isnull((select top 1 Tx2.GLAccount
from [@ST_LT_DEPLET] TX inner join [@ST_LT_DEPDET] TX1 on TX.DocEntry = TX1.DocEntry inner join [DSC1] TX2 on TX2.AbsEntry = TX.u_ctaBan 
where TX1.u_nrointDe =  T0.Transid),T1.U_DEP_CB) 'CtaBan' FROM  JDT1 T0  INNER JOIN OJDT T1  ON  T0.TransId = T1.TransId 
WHERE (T0.DebCred = 'D' AND T0.TransType = 30  OR T0.BatchNum > 0 ) AND  T0.ShortName = @codSN  AND  T0.Closed = 'N'  AND  
(T0.BalDueCred <> 0  OR  T0.BalDueDeb <> 0 )AND  ( (T0.SourceLine <> -14  AND  T0.SourceLine <> -6 ) OR T0.SourceLine IS NULL ) AND  
(T0.TransType <> -2  OR  T1.DataSource <> '-T') AND T1.REF2 LIKE 'LET%' AND T1.U_LET_EST = @EstLet





