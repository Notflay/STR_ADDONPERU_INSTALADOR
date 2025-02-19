CREATE PROCEDURE STR_SP_LTR_LetrasPendientesCP
@p_Pv_ShortName as nvarchar(20)
, @p_Pv_u_Let_Est as nvarchar(3)
AS

SELECT 
'N' 'Sel'
, T0.TransId 'NumInt'
, T1.REF2 NumLetra
, case T1.U_LET_EST when '009' then 'Retencion' else T1.REF1 end as 'REF1'
, T0.TaxDate 'FecEmi'
, T0.DueDate 'FecVen'
, T1.U_LET_MON 'Moneda'
, T0.Line_ID 'LineaAs'
, CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then 1 else (select rate from ortt where currency=T1.U_LET_MON and datediff(dd,T1.refdate,ratedate)=0) end 'TC'
, CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then Credit else SYSCred end 'Importe'
, CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then BalDueCred else BalScCred end 'Saldo' 
, CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then Credit else FCCredit end 'Importe'
, CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then BalDueCred else BalFcCred end 'Saldo' 
, T1.U_WTRate AS 'Retencion'
FROM  JDT1 T0  INNER JOIN OJDT T1  ON  T0.TransId = T1.TransId 
WHERE 
(T0.DebCred = 'C' AND T0.TransType = 30  OR T0.BatchNum > 0 ) 
AND T0.ShortName = @p_Pv_ShortName
AND T0.Closed = 'N'  
AND (T0.BalDueCred <> 0  OR  T0.BalDueDeb <> 0 )
AND ((T0.SourceLine <> -14  AND  T0.SourceLine <> -6 ) OR T0.SourceLine IS NULL ) 
AND (T0.TransType <> -2  OR  T1.DataSource <> '-T') 
AND T1.REF2 LIKE 'LET%' 
AND (T1.U_LET_EST = @p_Pv_u_Let_Est or T1.U_LET_EST='009')