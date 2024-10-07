CREATE PROCEDURE STR_SP_LOC_InfoTotalesPorParametroEAR
(
    @Impuesto VARCHAR(10),
    @TotalLinea DECIMAL(19,6),
    @MonedaDetalle VARCHAR(10),
    @FechaDocumento VARCHAR(10),
    @MonedaCabecera VARCHAR(10)
)
AS
BEGIN
    DECLARE @mndloc CHAR(3);
    DECLARE @TSI DECIMAL(19,6);
    DECLARE @TIM DECIMAL(19,6);
    DECLARE @IMT DECIMAL(19,6);
    DECLARE @RateMonedaDetalle DECIMAL(19,6) = 1;
    DECLARE @RateMonedaCabecera DECIMAL(19,6) = 1;

    -- Obtener la moneda local
    SELECT TOP 1 @mndloc = MainCurncy FROM OADM;

    -- Obtener el tipo de cambio para MonedaDetalle
    IF @MonedaDetalle <> @mndloc
    BEGIN
        SELECT @RateMonedaDetalle = Rate 
        FROM ORTT 
        WHERE RateDate = CAST(@FechaDocumento AS DATE) 
        AND Currency = @MonedaDetalle;
    END

    -- Obtener el tipo de cambio para MonedaCabecera
    IF @MonedaCabecera <> @mndloc
    BEGIN
        SELECT @RateMonedaCabecera = Rate 
        FROM ORTT 
        WHERE RateDate = CAST(@FechaDocumento AS DATE) 
        AND Currency = @MonedaCabecera;
    END

    -- Calcular TSI, TIM, IMT
    SELECT 
        @TSI = CASE 
            WHEN @Impuesto = 'EXO' THEN @TotalLinea * (@RateMonedaDetalle / @RateMonedaCabecera)
            ELSE (@TotalLinea - (@TotalLinea * (SELECT Rate FROM OSTC WHERE Code = @Impuesto) / 
                ((SELECT Rate FROM OSTC WHERE Code = @Impuesto) + 100))) * 
                (@RateMonedaDetalle / @RateMonedaCabecera)
        END,
        @TIM = CASE 
            WHEN @Impuesto = 'EXO' THEN 0
            ELSE (@TotalLinea * (SELECT Rate FROM OSTC WHERE Code = @Impuesto) / 
                ((SELECT Rate FROM OSTC WHERE Code = @Impuesto) + 100)) * 
                (@RateMonedaDetalle / @RateMonedaCabecera)
        END,
        @IMT = @TotalLinea * (@RateMonedaDetalle / @RateMonedaCabecera);

    -- Devolver los resultados
    SELECT @TSI AS TSIM, @TIM AS TTIM, @IMT AS IMPT;
END;
