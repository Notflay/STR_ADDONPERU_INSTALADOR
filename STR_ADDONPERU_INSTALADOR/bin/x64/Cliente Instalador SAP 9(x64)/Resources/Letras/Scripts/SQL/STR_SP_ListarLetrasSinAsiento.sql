CREATE PROCEDURE STR_SP_ListarLetrasSinAsiento
	@tpo CHAR(2) = NULL,
	@snd VARCHAR(20) = NULL,
	@snh VARCHAR(20) = NULL,
	@fed DATETIME = NULL,
	@feh DATETIME = NULL,
	@fcd DATETIME = NULL,
	@fch DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF ISNULL(@tpo, '') = ''
	BEGIN
		SET @tpo = 'CP';
	END

	IF ISNULL(@snd, '') = ''
	BEGIN
		SELECT @snd = MIN(CardCode) FROM OCRD;
	END

	IF ISNULL(@snh, '') = ''
	BEGIN
		SELECT @snh = MAX(CardCode) FROM OCRD;
	END

	IF ISNULL(@fed, '') = ''
	BEGIN
		SET @fed = '19000101';
	END

	IF ISNULL(@feh, '') = ''
	BEGIN
		SET @feh = '99991231';
	END

	IF ISNULL(@fcd, '') = ''
	BEGIN
		SET @fcd = '19000101';
	END

	IF ISNULL(@fch, '') = ''
	BEGIN
		SET @fch = '99991231';
	END

	SELECT
		'Y' AS Selec,
		T0.U_CardCode AS [Soc. Negocios],
		T1.U_codLet AS [Nro. Letra],
		T0.U_EmiDate AS [Fecha Emision],
		T0.U_TxEmiDat AS [Fecha Contabilizacion],
		T1.U_VencDate AS [Fecha de Vencimiento],
		CONVERT(DECIMAL(19, 6), T1.U_ImpME) AS [Monto Emision],
		'LXC' AS Codigo,
		T0.U_SerLetra AS Serie,
		'001' AS Tipo,
		T0.U_DocCurr AS Moneda,
		T0.U_EstLet AS Estado,
		T2.AcctCode AS Cuenta1,
		TEX.U_cuenta AS Cuenta2,
		'' AS Memo,
		T0.DocEntry AS [Id Emision],
		T1.LineId AS [Nro Linea]
	FROM
		"@ST_LT_EMILET" T0
	INNER JOIN
		"@ST_LT_ELLETRAS" T1 ON T0.DocEntry = T1.DocEntry
	INNER JOIN
		CRD3 T2 ON T0.U_CardCode = T2.CardCode
	CROSS JOIN
		(SELECT U_cuenta FROM "@ST_LT_CONF" WHERE Code = '00000005') AS TEX
	WHERE
		ISNULL(T1.U_codLet, '') != ''
		AND ISNULL(T1.U_NumAsi, '0') = '0'
		AND ISNULL(U_DocStat, '') = 'C'
		AND T0.U_EstLet = '002'
		AND T2.AcctType = 'R'
		AND T0.U_CardCode BETWEEN @snd AND @snh
		AND T0.U_EmiDate BETWEEN @fed AND @feh
		AND T0.U_TxEmiDat BETWEEN @fcd AND @fch;
END
