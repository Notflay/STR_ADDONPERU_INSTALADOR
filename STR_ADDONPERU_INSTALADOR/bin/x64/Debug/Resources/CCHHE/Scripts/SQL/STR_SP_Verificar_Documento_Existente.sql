CREATE PROCEDURE STR_SP_VERIFICAR_DOCUMENTO_EXISTENTE
	@NUMUNI VARCHAR(30),
	@CARDCODE  VARCHAR(50)
AS
	SELECT COUNT('A') FROM OPCH WHERE RIGHT(REPLICATE('0',2)+U_BPP_MDTD,2)+RIGHT(REPLICATE('0',4)+U_BPP_MDSD,4)
	+RIGHT(REPLICATE('0',15)+U_BPP_MDCD,15) = @NUMUNI AND CardCode = @CARDCODE


