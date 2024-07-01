CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_FACTURAS
(
    @IDNUMBER INT
)
AS
BEGIN

    SELECT 
        t1.WizardName,
        t0.InvKey,
        t0.DocNum,
        t0.CardCode,
        t0.CardName,
        t0.NumAtCard,
        t0.PayAmount AS [Saldo Pendiente],
        t0.InvPayAmnt AS [Importe a Pagar]
    FROM 
        pwz3 t0
    INNER JOIN 
        opwz t1 ON t0.IdEntry = t1.IdNumber
    WHERE 
        t0.IdEntry = @IDNUMBER AND t0.Checked = 'Y';

END