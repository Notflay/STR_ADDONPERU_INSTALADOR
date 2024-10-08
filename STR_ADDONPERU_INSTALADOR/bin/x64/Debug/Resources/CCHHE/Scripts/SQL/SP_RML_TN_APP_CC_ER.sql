CREATE PROCEDURE SP_RML_TN_APP_CC_ER
( 
	@object_type nvarchar(20), --> SBO Object Type
	@transaction_type nchar(1), --> [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	@num_of_cols_in_key int,
	@list_of_key_cols_tab_del nvarchar(255),
	@id nvarchar(255),
	@error int out,
	@error_message nvarchar(200) out
	)
AS
BEGIN
	--> Valores de retorno
	DECLARE @enabled bit --> Activa o desactiva las validaciones. Valores: 1-Activa, 0-Desactiva
	
	SELECT @error = 0
	SELECT @error_Message = N''
	SELECT @enabled = 1
							 
	/*============================================== OBJETOS ======================================================*/

	IF @Object_Type = 'STR_CCHAPR' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_APR_001_UDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END

	IF @Object_Type = 'STR_CCHCRG' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_ER_001_UDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END
	
	IF @Object_Type = 'STR_EARAPR' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_APR_002_UDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END


	IF @Object_Type = 'STR_EARCRG' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_ER_002_UDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END


	IF @Object_Type = '1470000113' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_ER_1470000113_SOLICITUDIN](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END


	IF @Object_Type = '46' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_ER_46_PAGOEFECTUADO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END


	IF @Object_Type = '24' AND @enabled = 1
	BEGIN
		SELECT @error_message = [dbo].[RML_TN_APP_CC_ER_24_PAGORECIBIDO](@id, @transaction_type)
		IF isnull(@error_message,'') <> '' 
		BEGIN
			SELECT @error = 1
			GOTO Salir
		END
	END


	IF @Object_Type = '46' AND @enabled = 1  AND @transaction_type = 'C'

	BEGIN
	--Pagos efectuados
	DECLARE @TPORND VARCHAR(4)
	DECLARE @CNT INT
	DECLARE @CTARGT VARCHAR(30)
	DECLARE @CTAPGO VARCHAR(30)
	DECLARE @DTOCTA VARCHAR(100)
	DECLARE @NMRCCHEAR VARCHAR(50)
			--CCH
		SET @CNT = (SELECT COUNT('E') FROM "@STR_CCHAPR" WHERE U_CC_DEPE = @id)
		IF @CNT > 0 
		BEGIN
			CREATE TABLE #tbloc1 (cmp1 varchar(50),cmp2 varchar(100),cmp3 int)
			INSERT INTO #tbloc1 SELECT U_CC_CJCH, U_CC_NMCC, (SELECT COUNT ('E') FROM OVPM WHERE U_BPP_TIPR = 'CCH' AND U_BPP_CCHI = U_CC_CJCH AND U_BPP_NUMC = U_CC_NMCC 
			AND Canceled != 'Y') AS "CNT" FROM "@STR_CCHAPR" T0 INNER JOIN "@STR_CCHAPRDET" T1 ON T0.DocEntry =  T1.DocEntry WHERE U_CC_STDO = 'A' AND U_CC_DEPE = @id	
			
			SET @CNT = (SELECT COUNT('E') FROM #tbloc1 where cmp3 > 0)
			IF @CNT > 0
			BEGIN
				SET @NMRCCHEAR = (SELECT TOP 1 cmp2 FROM #tbloc1)
				SET @error = 1
				SET @error_message = 'No se puede cancelar esta apertura debido a que el numero de CCH: ' + @NMRCCHEAR + ' tiene movimientos...'
				GOTO Salir
			END
			ELSE
			BEGIN
				UPDATE "@STR_CCHAPRDET" SET U_CC_STDO = 'C' FROM "@STR_CCHAPRDET" T0 INNER JOIN #tbloc1 T1 
				ON T0."U_CC_CJCH" COLLATE DATABASE_DEFAULT = T1.cmp1 COLLATE DATABASE_DEFAULT AND T0.U_CC_NMCC COLLATE DATABASE_DEFAULT = T1.cmp2 COLLATE DATABASE_DEFAULT
			END 
			DROP TABLE #tbloc1
		END

		--EAR
		SET @CNT = (SELECT COUNT('E') FROM "@STR_EARAPR" WHERE U_ER_DEPE = @id)
		IF @CNT > 0 
		BEGIN
			CREATE TABLE #tbloc2 (cmp1 varchar(50),cmp2 varchar(100),cmp3 int)
			INSERT INTO #tbloc2 SELECT T0.U_ER_EARN, T0.U_ER_NMER, (SELECT COUNT ('E') FROM OVPM WHERE U_BPP_TIPR = 'EAR' AND U_BPP_CCHI =T0.U_ER_EARN AND U_BPP_NUMC = T0.U_ER_NMER 
			AND Canceled != 'Y') AS CNT FROM "@STR_EARAPR" T0 INNER JOIN "@STR_EARAPRDET" T1 ON T0.DocEntry =  T1.DocEntry WHERE U_ER_STDO = 'A' AND U_ER_DEPE = @id

			SET @CNT = (SELECT COUNT('E') FROM #tbloc2 where cmp3 > 0)
			IF @CNT > 0
			BEGIN
				SET @NMRCCHEAR = (SELECT TOP 1 cmp2 FROM #tbloc2)
				SET @error = 1
				SET @error_message = 'No se puede cancelar esta apertura debido a que el numero de EAR: ' + @NMRCCHEAR + ' tiene movimientos...'
				GOTO Salir
			END
			ELSE
			BEGIN
				UPDATE [@STR_EARAPRDET] SET U_ER_STDO = 'C' FROM [@STR_EARAPRDET] T0 INNER JOIN #tbloc2 T1 ON T0.U_ER_EARN	
				COLLATE DATABASE_DEFAULT = T1.cmp1 COLLATE DATABASE_DEFAULT AND T0.U_ER_NMER COLLATE DATABASE_DEFAULT = T1.cmp2 COLLATE DATABASE_DEFAULT
			END 
			DROP TABLE #tbloc2
		END
	END

	Salir:
END
