CREATE PROCEDURE STR_SP_LT_MostrarLetras
(@fecha DateTime, @fechafin DateTime, @moneda varchar(10),@nomCli varchar(200), @codCli varchar(30))
--  exec SP_LT_MaestroLetra '20090911','SOL','NombreCliente','CodCliente'

as 
begin

SELECT * FROM  
(SELECT T1.U_LET_EST 'Estado', T0.shortname 'cardcode','Letras' 'TipoDoc',T1.U_LET_SER 'Serie' ,T1.ref2 'CodTipoDoc', T0.TransId 'NumInt',  
T1.U_LET_MON 'DocCur', (SELECT OC.cardname FROM OCRD OC WHERE OC.cardcode = T0.shortname) 'CardName',  
Convert(varchar(10), T1.DueDate, 103) 'DueDate',Convert(varchar(10), T1.refdate, 103) 'DocDate',  
CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then LOCTOTAL else FCTOTAL end 'Monto',  
CASE WHEN (SELECT MainCurncy from OADM) = T1.U_LET_MON then T0.BalDueDeb else T0.BalFcDeb end 'Saldo',  
  
'EstSal' = CASE   
WHEN T0.BalDueDeb = 0 THEN 'Pago Total'   
WHEN T0.BalDueDeb < LOCTOTAL THEN 'Pago Parcial'   
WHEN T0.BalDueDeb = LOCTOTAL THEN 'Pendiente' ELSE 'Pago en Exceso' END,  
'NumOpe' = CASE   
WHEN T1.U_LET_EST = '002' THEN  (SELECT DISTINCT EL.DocEntry  
        FROM [@ST_LT_ELLETRAS] EL  
        WHERE EL.U_codLet = T1.ref2  
        UNION  
        (SELECT DISTINCT DocEntry   
        FROM [@ST_LT_RENEMI]   
        WHERE U_nroLet = T1.ref2))   
WHEN T1.U_LET_EST = '003' THEN (SELECT TOP 1 EL.DocEntry  
        FROM [@ST_LT_ELLETRAS] EL  
        WHERE EL.U_codLet = T1.ref2 order by DocEntry Desc)  
WHEN T1.U_LET_EST = '004' THEN (SELECT TOP 1 DocEntry  
        FROM [@ST_LT_DEPDET]  
        WHERE U_nroLet = T1.ref2 and U_codPago is not null and U_nroIntDe is not null order by DocEntry Desc)  
WHEN T1.U_LET_EST = '005' THEN (SELECT TOP 1 DocEntry  
        FROM [@ST_LT_DEPDET]  
        WHERE U_nroLet = T1.ref2 and U_codPago is not null and U_nroIntDe is not null order by DocEntry Desc)  
WHEN T1.U_LET_EST = '006' THEN (SELECT TOP 1 DocEntry  
        FROM [@ST_LT_DEPDET]  
        WHERE U_nroLet = T1.ref2 and U_codPago is not null and U_nroIntDe is not null order by DocEntry Desc)  
WHEN T1.U_LET_EST = '007' THEN (SELECT TOP 1 DocEntry  
        FROM [@ST_LT_DEPDET]  
        WHERE U_nroLet = T1.ref2 and U_codPago is not null and U_nroIntDe is not null order by DocEntry Desc)   
WHEN T1.U_LET_EST = '008' THEN (SELECT TOP 1 DocEntry  
        FROM [@ST_LT_RENDET]  
        WHERE U_numLet = T1.ref2 and U_sel = 'Y' order by DocEntry Desc)   
  
ELSE '0'  
END,  
'NomOpe' = CASE   
WHEN T1.U_LET_EST = '002' THEN 'Cartera'  
WHEN T1.U_LET_EST = '003' THEN 'Enviado Cobranza'  
WHEN T1.U_LET_EST = '004' THEN 'Cobranza Libre'  
WHEN T1.U_LET_EST = '005' THEN 'Cobranza Garantía'  
WHEN T1.U_LET_EST = '006' THEN 'Enviado Descuento'  
WHEN T1.U_LET_EST = '007' THEN 'Descuento'  
WHEN T1.U_LET_EST = '008' THEN 'Protesto'  
ELSE '0'  
END  
FROM OJDT T1 INNER JOIN JDT1 T0 ON  T0.TransId = T1.TransId   
WHERE (T0.DebCred = 'D' AND T0.TransType = 30  OR T0.BatchNum > 0 ) AND  
  T0.ShortName like 'C%'  AND  T0.Closed = 'N' AND --(T0.BalDueCred <> 0  OR  T0.BalDueDeb <> 0 ) AND  
( (T0.SourceLine <> -14  AND  T0.SourceLine <> -6 ) OR T0.SourceLine IS NULL ) AND   
(T0.TransType <> -2  OR  T1.DataSource <> '-T') AND T1.REF2 LIKE 'LET%' AND   
T1.U_LET_EST Not In ('001', '000') AND T1.U_LET_TIP = '001'  
and (select count(*) from ojdt  tx where tx.transtype = 24 and tx.ref2 = 'ANL-LT' and tx.Memo= T1.REF2 and tx.u_let_est = t1.u_let_est and tx.u_let_ser = t1.u_let_ser) =0  
and T1.U_LET_EST = (  
SELECT MS3.U_estAct  
FROM [@ST_LT_MSTLET] MS3   
WHERE MS3.Code = (  
  
SELECT MAX(convert(Numeric,MS2.Code))   
FROM [@ST_LT_MSTLET] MS2   
WHERE  MS2.U_cdStLet = T1.ref2 AND MS2.u_tipo = '001' AND u_serie = T1.u_let_ser)  
)  
) T   
WHERE  
DocCur like @moneda  
AND cardcode like @codCli  
AND CardName like @nomCli  
AND docdate between isnull(@fecha, docdate) and isnull(@fechafin, docdate)  
order by CodTipoDoc

END


