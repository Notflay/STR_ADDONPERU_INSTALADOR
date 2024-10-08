CREATE PROCEDURE STR_SP_LT_ActualizarAsientoGenerado
	@docent INT,
	@lineid INT,
	@trnsid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE "@ST_LT_ELLETRAS"
	SET U_NumAsi = @trnsid
	WHERE DocEntry = @docent AND LineId = @lineid;
END
