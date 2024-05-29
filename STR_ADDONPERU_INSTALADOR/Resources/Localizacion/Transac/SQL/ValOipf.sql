CREATE  PROCEDURE ValOipf

--Costos de importación

(
	@DocEntry			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

	declare	@DocCur			varchar(3)
	declare @JdtNum			int

	select	@DocCur			= i.DocCur,
			@JdtNum			= i.JdtNum
	from	oipf i
	where	docentry = @DocEntry

	--IF (@TipoTransaccion in ('A','U')) BEGIN
	----------------------------------------------------------------------------------------------------------
	--El costeo siempre debe ser en dolares puesto que la mayoria de documentos será en soles
	----------------------------------------------------------------------------------------------------------
		--if @moneda <> 'USD' begin
		--	set @error = 10
		--	set @error_message = 'ValOipf: La moneda de costeo debe ser moneda USD'
		--	return
		--end
	--END

	----------------------------------------------------------------------------------------------------------
	--Actualziación de datos obligatorios para cuentas 6
	----------------------------------------------------------------------------------------------------------

UPDATE T1
SET T1.ProfitCode='011', T1.OcrCode2='10', T1.OcrCode3='94111', T1.OcrCode4='LIM1', T1.U_STR_PartidaPre='PGG-CC011-00009', T1.U_STR_Articulo='AFJ000019'
FROM JDT1 T1
WHERE (T1.Account IN (SELECT OA.AcctCode FROM OACT OA WHERE (T1.Account=OA.AcctCode AND Segment_0 like '6%')) AND T1.TransId=@JdtNum)


return

END

