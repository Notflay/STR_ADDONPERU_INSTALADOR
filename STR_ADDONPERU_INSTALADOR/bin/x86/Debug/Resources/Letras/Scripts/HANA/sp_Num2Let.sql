CREATE PROCEDURE sp_Num2Let
(
	IN Numero DECIMAL(20,2),
	IN MND CHAR(3),
	OUT VALOR VARCHAR(500)
)
AS
	LnEntero INTEGER;
    LcRetorno VARCHAR(512);
    LnTerna INTEGER;
    LcMiles VARCHAR(512);
    LcCadena VARCHAR(512);
    LnUnidades INTEGER;
    LnDecenas INTEGER;
    LnCentenas INTEGER;
    LnFraccion INTEGER;
BEGIN
	VALOR := '';
	LnEntero:= CAST(Numero AS INT);
	LnFraccion := ((:Numero - :LnEntero) * 100);
	
	LcRetorno := '';
    LnTerna := 1;
    
    WHILE :LnEntero > 0 DO
		-- Recorro terna por terna
		LcCadena := '';
		LnUnidades := MOD(:LnEntero, 10);
		LnEntero := CAST(LnEntero/10 AS INT);
		
		LnDecenas := MOD(LnEntero, 10);
		LnEntero := CAST(LnEntero/10 AS INT);
		
		LnCentenas := MOD(LnEntero, 10);
		LnEntero := CAST(LnEntero/10 AS INT);
		
		-- Analizo las unidades
		SELECT 
		(
			CASE -- UNIDADES 
				WHEN LnUnidades = 1 AND LnTerna = 1 THEN 'UNO ' || LcCadena
				WHEN LnUnidades = 1 AND LnTerna <> 1 THEN 'UN ' || LcCadena
				WHEN LnUnidades = 2 THEN 'DOS ' || LcCadena
				WHEN LnUnidades = 3 THEN 'TRES ' || LcCadena
				WHEN LnUnidades = 4 THEN 'CUATRO ' || LcCadena
				WHEN LnUnidades = 5 THEN 'CINCO ' || LcCadena
				WHEN LnUnidades = 6 THEN 'SEIS ' || LcCadena
				WHEN LnUnidades = 7 THEN 'SIETE ' || LcCadena
				WHEN LnUnidades = 8 THEN 'OCHO ' || LcCadena
				WHEN LnUnidades = 9 THEN 'NUEVE ' || LcCadena
			ELSE LcCadena
			END -- UNIDADES
		)
		INTO LcCadena
		FROM DUMMY;
		
		-- Analizo las decenas
		SELECT
		(
			CASE -- DECENAS 
				WHEN LnDecenas = 1 THEN
				(
					CASE LnUnidades
						WHEN 0 THEN 'DIEZ '
						WHEN 1 THEN 'ONCE '
						WHEN 2 THEN 'DOCE '
						WHEN 3 THEN 'TRECE '
						WHEN 4 THEN 'CATORCE '
						WHEN 5 THEN 'QUINCE '
					ELSE 'DIECI' || LcCadena
					END
				)
				WHEN LnDecenas = 2 AND LnUnidades = 0 THEN 'VEINTE ' || LcCadena
				WHEN LnDecenas = 2 AND LnUnidades <> 0 THEN 'VEINTI' || LcCadena
				WHEN LnDecenas = 3 AND LnUnidades = 0 THEN 'TREINTA ' || LcCadena
				WHEN LnDecenas = 3 AND LnUnidades <> 0 THEN 'TREINTA Y ' || LcCadena
				WHEN LnDecenas = 4 AND LnUnidades = 0 THEN 'CUARENTA ' || LcCadena
				WHEN LnDecenas = 4 AND LnUnidades <> 0 THEN 'CUARENTA Y ' || LcCadena
				WHEN LnDecenas = 5 AND LnUnidades = 0 THEN 'CINCUENTA ' || LcCadena
				WHEN LnDecenas = 5 AND LnUnidades <> 0 THEN 'CINCUENTA Y ' || LcCadena
				WHEN LnDecenas = 6 AND LnUnidades = 0 THEN 'SESENTA ' || LcCadena
				WHEN LnDecenas = 6 AND LnUnidades <> 0 THEN 'SESENTA Y ' || LcCadena
				WHEN LnDecenas = 7 AND LnUnidades = 0 THEN 'SETENTA ' || LcCadena
				WHEN LnDecenas = 7 AND LnUnidades <> 0 THEN 'SETENTA Y ' || LcCadena
				WHEN LnDecenas = 8 AND LnUnidades = 0 THEN 'OCHENTA ' || LcCadena
				WHEN LnDecenas = 8 AND LnUnidades <> 0 THEN 'OCHENTA Y ' || LcCadena
				WHEN LnDecenas = 9 AND LnUnidades = 0 THEN 'NOVENTA ' || LcCadena
				WHEN LnDecenas = 9 AND LnUnidades <> 0 THEN 'NOVENTA Y ' || LcCadena
			ELSE LcCadena
			END -- DECENAS
		)
		INTO LcCadena
		FROM DUMMY;
		
		-- Analizo las centenas
		SELECT
		(
			CASE -- CENTENAS 
				WHEN LnCentenas = 1 AND LnUnidades = 0 AND LnDecenas = 0 THEN 'CIEN ' || LcCadena
				WHEN LnCentenas = 1 AND NOT(LnUnidades = 0 AND LnDecenas = 0) THEN 'CIENTO     ' || LcCadena
				WHEN LnCentenas = 2 THEN 'DOSCIENTOS ' || LcCadena
				WHEN LnCentenas = 3 THEN 'TRESCIENTOS ' || LcCadena
				WHEN LnCentenas = 4 THEN 'CUATROCIENTOS ' || LcCadena
				WHEN LnCentenas = 5 THEN 'QUINIENTOS ' || LcCadena
				WHEN LnCentenas = 6 THEN 'SEISCIENTOS ' || LcCadena
				WHEN LnCentenas = 7 THEN 'SETECIENTOS ' || LcCadena
				WHEN LnCentenas = 8 THEN 'OCHOCIENTOS ' || LcCadena
				WHEN LnCentenas = 9 THEN 'NOVECIENTOS ' || LcCadena
			ELSE LcCadena
			END -- CENTENAS
		)
		INTO LcCadena
		FROM DUMMY;
		
		-- Analizo la terna
		SELECT 
		(
			CASE -- TERNA
				WHEN LnTerna = 1 THEN LcCadena
				WHEN LnTerna = 2 AND (LnUnidades + LnDecenas + LnCentenas <> 0) THEN LcCadena || ' MIL '
				WHEN LnTerna = 3 AND (LnUnidades + LnDecenas + LnCentenas <> 0) AND LnUnidades = 1 AND LnDecenas = 0 AND LnCentenas = 0 THEN LcCadena || ' MILLON '
				WHEN LnTerna = 3 AND (LnUnidades + LnDecenas + LnCentenas <> 0) AND NOT (LnUnidades = 1 AND LnDecenas = 0 AND LnCentenas = 0) THEN LcCadena || ' MILLONES '
				WHEN LnTerna = 4 AND (LnUnidades + LnDecenas + LnCentenas <> 0) THEN LcCadena || ' MIL MILLONES '
			ELSE ''
			END -- TERNA
		)
		INTO LcCadena
		FROM DUMMY;
		-- Armo el retorno terna a terna
		LcRetorno := (LcCadena || LcRetorno);
		LnTerna := (:LnTerna + 1);
	END WHILE;
	
	IF LnTerna = 1 THEN
		LcRetorno := 'CERO';
	END IF;
	
	SELECT
	(
		RTRIM(LcRetorno) ||
		' CON ' ||
		(
			CASE
				WHEN LnFraccion < 10 THEN 
				(
					'0' || LTRIM(LnFraccion)
				)
			ELSE LTRIM(LnFraccion)
			END
		) ||
		'/100 ' ||
		(SELECT "CurrName" FROM "OCRN" WHERE "CurrCode" = MND)
	)
	INTO VALOR
	FROM DUMMY;
	
	SELECT VALOR FROM DUMMY;
END;