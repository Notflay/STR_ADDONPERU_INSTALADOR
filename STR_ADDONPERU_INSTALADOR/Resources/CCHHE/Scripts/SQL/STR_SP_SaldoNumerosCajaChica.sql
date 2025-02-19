CREATE PROCEDURE STR_SP_SaldoNumerosCajaChica
(
    @NMROCCH VARCHAR(30)
)
AS
BEGIN
    DECLARE @mndloc CHAR(3);

    -- Obtener la moneda principal
    SELECT TOP 1 @mndloc = MainCurncy FROM OADM;

    -- Calcular la suma aplicada de OVPM
    DECLARE @SumAppliedOVPM FLOAT;
    SELECT @SumAppliedOVPM = ISNULL(SUM(
        CASE TX2.DocCur
            WHEN @mndloc THEN
                CASE TX0.DocCurr
                    WHEN @mndloc THEN TX1.SumApplied
                    ELSE TX1.SumApplied / TY0.Rate
                END
            ELSE
                CASE TX0.DocCurr
                    WHEN @mndloc THEN TX1.SumApplied
                    ELSE TX1.AppliedFC
                END
        END
    ), 0.0)
    FROM OVPM TX0
    INNER JOIN VPM2 TX1 ON TX0.DocEntry = TX1.DocNum
    INNER JOIN OPCH TX2 ON TX1.DocEntry = TX2.DocEntry
    LEFT JOIN ORTT TY0 ON TY0.RateDate = TX0.DocDate AND TY0.Currency = TX0.DocCurr
    WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = (SELECT T0.U_CC_NMCC FROM "@STR_CCHAPRDET" T0 WHERE T0.U_CC_NMCC = @NMROCCH AND T0.U_CC_STDO = 'A');

    -- Calcular la suma aplicada de ORCT
    DECLARE @SumAppliedORCT FLOAT;
    SELECT @SumAppliedORCT = ISNULL(SUM(
        CASE TX2.DocCur
            WHEN @mndloc THEN
                CASE TX0.DocCurr
                    WHEN @mndloc THEN TX1.SumApplied
                    ELSE TX1.SumApplied / TY0.Rate
                END
            ELSE
                CASE TX0.DocCurr
                    WHEN @mndloc THEN TX1.SumApplied
                    ELSE TX1.AppliedFC
                END
        END
    ), 0.0)
    FROM ORCT TX0
    INNER JOIN RCT2 TX1 ON TX0.DocEntry = TX1.DocNum
    INNER JOIN OINV TX2 ON TX1.DocEntry = TX2.DocEntry
    LEFT JOIN ORTT TY0 ON TY0.RateDate = TX0.DocDate AND TY0.Currency = TX0.DocCurr
    WHERE TX0.Canceled != 'Y' AND TX0.U_BPP_NUMC = (SELECT T0.U_CC_NMCC FROM "@STR_CCHAPRDET" T0 WHERE T0.U_CC_NMCC = @NMROCCH AND T0.U_CC_STDO = 'A');

    -- Calcular el saldo
    SELECT 
        T0.U_CC_MNAP - @SumAppliedOVPM + @SumAppliedORCT AS SALDO,
        T1.U_CC_MNDA AS MONEDA
    FROM "@STR_CCHAPRDET" T0
    INNER JOIN "@STR_CCHAPR" T1 ON T0.DocEntry = T1.DocEntry
    WHERE T0.U_CC_NMCC = @NMROCCH AND T0.U_CC_STDO = 'A';
END;
