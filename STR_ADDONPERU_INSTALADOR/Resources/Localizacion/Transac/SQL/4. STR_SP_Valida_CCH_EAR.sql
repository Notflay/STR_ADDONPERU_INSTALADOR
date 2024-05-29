CREATE PROCEDURE STR_SP_Valida_CCH_EAR
	@object_type  NVARCHAR(20),
	@transaction_type  NVARCHAR(1),
	@list_of_cols_val_tab_del nvarchar(255),
	@error INTEGER OUTPUT,
	@error_message NVARCHAR(200) OUTPUT
AS
BEGIN
select @error = 0
select @error_message = N'Ok'
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	IF @object_type = 'STR_CCHCRG' AND (@transaction_type = 'A' OR @transaction_type = 'U')
	BEGIN
		DECLARE @SLDFIN NUMERIC(19,6)
		DECLARE @SLDCCH NUMERIC(19,6)
		DECLARE @FLGSLD CHAR(1)

		--ACTUALIZACION DE PRECIO POR UNIDAD
		UPDATE [@STR_CCHCRGDET] SET U_CC_TTLN = U_CC_PRPU * CASE U_CC_CNAR WHEN 0 THEN 1 ELSE U_CC_CNAR END 
		WHERE DocEntry = @list_of_cols_val_tab_del
		--VALIDACION DE SALDOS
		SET @SLDFIN = 
		(
			SELECT 
			--IMPORTE TOTAL
			SUM(IMT) AS IMPT
			FROM
				(
					SELECT 
						CASE T0.U_CC_MNDA WHEN 'SOL' THEN
							CASE T1.U_CC_MNDC WHEN 'SOL' THEN
								(U_CC_TTLN)
							ELSE
								(U_CC_TTLN)*(SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC)
							END
						ELSE
							CASE T1.U_CC_MNDC WHEN 'SOL' THEN
								(U_CC_TTLN)/(SELECT Rate FROM ORTT WHERE RateDate = U_CC_FCDC)
							ELSE
								(U_CC_TTLN) 
							END
						END		   
						AS IMT		 
					FROM [@STR_CCHCRG] T0 INNER JOIN [@STR_CCHCRGDET] T1
					ON T0.DocEntry = T1.DocEntry WHERE T0.DocEntry = @list_of_cols_val_tab_del	AND U_CC_SLCC = 'Y' AND U_CC_ESTD IN('CRE','ERR')
				) AS TBL
		)
		SET @SLDCCH = (SELECT U_CC_SLDI - @SLDFIN FROM [@STR_CCHCRG] WHERE DocEntry = @list_of_cols_val_tab_del)
		SET @FLGSLD = (SELECT TOP 1 U_STR_SLNG FROM [@BPP_CAJASCHICAS] T0 INNER JOIN [@STR_CCHCRG] T1 ON T0.Code = T1.U_CC_NMBR WHERE T1.DocEntry = @list_of_cols_val_tab_del)
		IF (@SLDCCH < 0 AND ISNULL(@FLGSLD,'N') <> 'Y')
		BEGIN
			SET @error_message = 'El monto total de los documentos registrados ('+LTRIM(STR(@SLDFIN,LEN(@SLDFIN),2))+'), es mayor al saldo de esta caja chica' 
			SET @error = 1
		END
	END
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	/*GENERA EL CODIGO DE EAR DEL EMPLEADO*/
	IF @object_type = '171' AND (@transaction_type = 'A' OR @transaction_type = 'U')
	BEGIN
	  IF (SELECT COUNT('E') FROM OHEM WHERE U_CE_PVAS IS NOT NULL AND U_CE_CEAR IS NULL AND empID = @list_of_cols_val_tab_del) > 0
	  BEGIN
		UPDATE OHEM SET U_CE_CEAR = 'EAR' + CONVERT(VARCHAR(10),empID) FROM OHEM T0 WHERE empID = @list_of_cols_val_tab_del;
	  END	 
	END
	--Solicitud de dinero
	IF @object_type = '1470000113' AND @transaction_type = 'A'
	BEGIN
		DECLARE @MND VARCHAR(5)
		DECLARE @SLC CHAR(1)
		DECLARE @MNT NUMERIC(19,6)
		SELECT @MND = U_CE_MNDA, @SLC = U_CE_EAR, @MNT = T1.U_CE_IMSL FROM OPRQ T0 INNER JOIN PRQ1 T1 
		ON T0.DocEntry =  T1.DocEntry WHERE T0.DocEntry = @list_of_cols_val_tab_del
		IF ISNULL(@MND,'') = '' AND @SLC = 'Y'
		BEGIN
			SET @error_message = 'No se ha definido la moneda de la solicitud de dinero EAR...'
			SET @error = 1
		END
		IF @MNT<=0 AND @SLC = 'Y'
		BEGIN
			SET @error_message = 'Ingrese un monto valido en el detalle de la solicitud de dinero EAR...'
			SET @error = 1
		END
	END
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  

	--Pagos efectuados
	DECLARE @TPORND VARCHAR(4)
	DECLARE @CNT INT
	DECLARE @CTARGT VARCHAR(30)
	DECLARE @CTAPGO VARCHAR(30)
	DECLARE @DTOCTA VARCHAR(100)
	DECLARE @NMRCCHEAR VARCHAR(50)

	IF @object_type = '46' AND @transaction_type = 'A'
	BEGIN
		SET @TPORND = (SELECT U_BPP_TIPR FROM OVPM WHERE "DocEntry" = @list_of_cols_val_tab_del)
		IF @TPORND = 'CCH' OR @TPORND = 'EAR'
		BEGIN
		--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CNT = (SELECT COUNT('E') FROM OVPM WHERE RTRIM("U_BPP_NUMC") = '---' AND "DocEntry" =  @list_of_cols_val_tab_del)
			IF @CNT > 0
			BEGIN
				SET @error = 1
				SET @error_message = 'No se ha seleccionado el nro caja/entrega...'
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		
			--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CTARGT = (SELECT CASE U_BPP_TIPR WHEN 'CCH' THEN (SELECT U_BPP_ACCT FROM "@BPP_CAJASCHICAS" WHERE Code = U_BPP_CCHI) 
								 			WHEN 'EAR' THEN (SELECT AcctCode FROM OACT WHERE FormatCode = (SELECT U_CE_CTPT FROM "@STR_CCHEAR_SYS" WHERE Code = '001')) END 
								 			FROM OVPM WHERE "DocEntry" = @list_of_cols_val_tab_del)				
			SET @CTAPGO = (SELECT CashAcct FROM OVPM WHERE "DocEntry" = @list_of_cols_val_tab_del)
			IF @CTARGT != @CTAPGO 
			BEGIN
				SET @DTOCTA = (SELECT TOP 1 FormatCode + ' - ' + AcctName FROM OACT WHERE "AcctCode" = @CTARGT)
				SET @error = 1
				SET @error_message = 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' + @DTOCTA
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		END
	END

	--Pagos recibidos
	IF @object_type = '24' AND @transaction_type = 'A'
	BEGIN
		SET @TPORND = (SELECT U_BPP_TIPR FROM ORCT WHERE DocEntry = @list_of_cols_val_tab_del)
		IF @TPORND = 'CCH' OR @TPORND = 'EAR'
		BEGIN
		--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CNT = (SELECT COUNT('E') FROM ORCT WHERE RTRIM(U_BPP_NUMC) = '---' AND "DocEntry" =  @list_of_cols_val_tab_del)
			IF @CNT > 0
			BEGIN
				SET @error = 1
				SET @error_message = 'No se ha seleccionado el nro caja/entrega...'
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		
			--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SET @CTARGT = (SELECT CASE "U_BPP_TIPR" WHEN 'CCH' THEN (SELECT "U_BPP_ACCT" FROM "@BPP_CAJASCHICAS" WHERE "Code" = "U_BPP_CCHI") 
								 			WHEN 'EAR' THEN (SELECT "AcctCode" FROM OACT WHERE "FormatCode" = (SELECT "U_CE_CTPT" FROM "@STR_CCHEAR_SYS" WHERE "Code" = '001')) END 
								 			FROM ORCT WHERE "DocEntry" = @list_of_cols_val_tab_del)	
															
			SET @CTAPGO = (SELECT CashAcct FROM ORCT WHERE DocEntry = @list_of_cols_val_tab_del)
			IF @CTARGT != @CTAPGO 
			BEGIN
				SET @DTOCTA = (SELECT TOP 1 FormatCode + ' - ' + AcctName FROM OACT WHERE AcctCode = @CTARGT)
				SET @error = 1
				SET @error_message = 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' + @DTOCTA
			END
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		END
	END

	--Cerrar un numero de CCH - EAR si este no tiene movimientos
	IF @object_type = '46' AND @transaction_type = 'C'
	BEGIN
		--CCH
		SET @CNT = (SELECT COUNT('E') FROM "@STR_CCHAPR" WHERE U_CC_DEPE = @list_of_cols_val_tab_del)
		IF @CNT > 0 
		BEGIN
			CREATE TABLE #tbloc1 (cmp1 varchar(50),cmp2 varchar(100),cmp3 int)
			INSERT INTO #tbloc1 SELECT U_CC_CJCH, U_CC_NMCC, (SELECT COUNT ('E') FROM OVPM WHERE U_BPP_TIPR = 'CCH' AND U_BPP_CCHI = U_CC_CJCH AND U_BPP_NUMC = U_CC_NMCC 
			AND Canceled != 'Y') AS "CNT" FROM "@STR_CCHAPR" T0 INNER JOIN "@STR_CCHAPRDET" T1 ON T0.DocEntry =  T1.DocEntry WHERE U_CC_STDO = 'A' AND U_CC_DEPE = @list_of_cols_val_tab_del	
			
			SET @CNT = (SELECT COUNT('E') FROM #tbloc1 where cmp3 > 0)
			IF @CNT > 0
			BEGIN
				SET @NMRCCHEAR = (SELECT TOP 1 cmp2 FROM #tbloc1)
				SET @error = 1
				SET @error_message = 'No se puede cancelar esta apertura debido a que el numero de CCH: ' + @NMRCCHEAR + ' tiene movimientos...'
			END
			ELSE
			BEGIN
				UPDATE "@STR_CCHAPRDET" SET U_CC_STDO = 'C' FROM "@STR_CCHAPRDET" T0 INNER JOIN #tbloc1 T1 
				ON T0."U_CC_CJCH" COLLATE DATABASE_DEFAULT = T1.cmp1 COLLATE DATABASE_DEFAULT AND T0.U_CC_NMCC COLLATE DATABASE_DEFAULT = T1.cmp2 COLLATE DATABASE_DEFAULT
			END 
			DROP TABLE #tbloc1
		END

		--EAR
		SET @CNT = (SELECT COUNT('E') FROM "@STR_EARAPR" WHERE U_ER_DEPE = @list_of_cols_val_tab_del)
		IF @CNT > 0 
		BEGIN
			CREATE TABLE #tbloc2 (cmp1 varchar(50),cmp2 varchar(100),cmp3 int)
			INSERT INTO #tbloc2 SELECT U_ER_EARN, U_ER_NMER, (SELECT COUNT ('E') FROM OVPM WHERE U_BPP_TIPR = 'EAR' AND U_BPP_CCHI = U_ER_EARN AND U_BPP_NUMC = U_ER_NMER 
			AND Canceled != 'Y') AS CNT FROM "@STR_EARAPR" T0 INNER JOIN "@STR_EARAPRDET" T1 ON T0.DocEntry =  T1.DocEntry WHERE U_ER_STDO = 'A' AND U_ER_DEPE = @list_of_cols_val_tab_del

			SET @CNT = (SELECT COUNT('E') FROM #tbloc2 where cmp3 > 0)
			IF @CNT > 0
			BEGIN
				SET @NMRCCHEAR = (SELECT TOP 1 cmp2 FROM #tbloc2)
				SET @error = 1
				SET @error_message = 'No se puede cancelar esta apertura debido a que el numero de EAR: ' + @NMRCCHEAR + ' tiene movimientos...'
			END
			ELSE
			BEGIN
				UPDATE [@STR_EARAPRDET] SET U_ER_STDO = 'C' FROM [@STR_EARAPRDET] T0 INNER JOIN #tbloc2 T1 ON T0.U_ER_EARN 
				COLLATE DATABASE_DEFAULT = T1.cmp1 COLLATE DATABASE_DEFAULT AND T0.U_ER_NMER COLLATE DATABASE_DEFAULT = T1.cmp2 COLLATE DATABASE_DEFAULT
			END 
			DROP TABLE #tbloc2
		END
	END
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
SELECT @error,@error_message
END



