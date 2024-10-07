CREATE PROCEDURE SP_RML_TN_APP_CC_ER
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)
--RETURNS VARCHAR(200)
AS
	cnt int;
	ttcch decimal(19,6);
	sldcch decimal(19,6);
	flgsld char(1);
	ctargt varchar(30);
	ctapgo varchar(30);
	dtocta varchar(100);
	tpornd varchar(4);
	nmrcchear varchar(50);
	mnd VARCHAR(5);
	slc CHAR(1);
	mnt NUMERIC(19,6);
	iVal int=0;
	inct int=0;
	part int=0;
BEGIN

	error :=0;
	error_message := N'Ok';
	
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	/*VALIDACION DE CAJA CHICA APERTURA*/
	IF object_type = 'STR_CCHAPR' 
	THEN 
		SELECT RML_TN_APP_CC_APR_001_UDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	
	/*VALIDACION DE CAJA CHICA*/
	IF object_type = 'STR_CCHCRG' 
	THEN 
		SELECT RML_TN_APP_CC_ER_001_UDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	/*VALIDACION DE ENTREGA A RENDIR APERTURA*/	
	IF object_type = 'STR_EARAPR' 
	THEN 
		SELECT RML_TN_APP_CC_APR_002_UDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;

	/*VALIDACION DE ENTREGA A RENDIR STR_EARCRG*/
	IF object_type = 'STR_EARCRG' 
	THEN 
		SELECT RML_TN_APP_CC_ER_002_UDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	--Solicitud de dinero
	IF object_type = '1470000113' 
	THEN 
		SELECT RML_TN_APP_CC_ER_1470000113_SOLICITUDIN(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;

	--Pagos efectuados
	IF object_type = '46' 
	THEN 
		SELECT RML_TN_APP_CC_ER_46_PAGOEFECTUADO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;

	

	--Pagos recibidos
	IF object_type = '24' 
	THEN 
		SELECT RML_TN_APP_CC_ER_24_PAGORECIBIDO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;
	--Cerrar un numero de CCH - EAR si este no tiene movimientos

	IF object_type = '46' AND transaction_type = 'C'
	THEN
	--CCH
		SELECT COUNT('E') INTO cnt FROM "@STR_CCHAPR" WHERE "U_CC_DEPE" = list_of_cols_val_tab_del;
		IF cnt > 0 
		THEN
			CREATE LOCAL TEMPORARY TABLE "#tbloc"(cmp1 varchar(50),cmp2 varchar(100),cmp3 int);
			INSERT INTO "#tbloc" SELECT T1."U_CC_CJCH", T1."U_CC_NMCC", (SELECT COUNT ('E') FROM OVPM WHERE "U_BPP_TIPR" = 'CCH' AND "U_BPP_CCHI" = T1."U_CC_CJCH" AND "U_BPP_NUMC" = T1."U_CC_NMCC" 
			AND "Canceled" != 'Y') AS "CNT"	FROM "@STR_CCHAPR" T0 INNER JOIN "@STR_CCHAPRDET" T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T1."U_CC_STDO" = 'A' AND T0."U_CC_DEPE" = list_of_cols_val_tab_del;	
			SELECT COUNT('E') INTO cnt FROM "#tbloc" where cmp3 > 0;		--	SELECT * FROM "@STR_CCHAPRDET"	
			IF cnt > 0
			THEN
				SELECT TOP 1 cmp2 INTO nmrcchear FROM "#tbloc";	
				error := 1;
				error_message := 'No se puede cancelar esta apertura debido a que el numero de CCH: '|| :nmrcchear || ' tiene movimientos...';
			ELSE
				UPDATE "@STR_CCHAPRDET" T0 SET T0."U_CC_STDO" = 'C' FROM "@STR_CCHAPRDET" T0 INNER JOIN "#tbloc" T1 ON T0."U_CC_CJCH" = T1.cmp1 AND T0."U_CC_NMCC" = T1.cmp2;
			END IF; 
			DROP TABLE "#tbloc";
		END IF;
		--EAR
		SELECT COUNT('E') INTO cnt FROM "@STR_EARAPR" WHERE "U_ER_DEPE" = list_of_cols_val_tab_del;
		IF cnt > 0 
		THEN
			CREATE LOCAL TEMPORARY TABLE "#tbloc"(cmp1 varchar(50),cmp2 varchar(100),cmp3 int);
			INSERT INTO "#tbloc" SELECT T1."U_ER_EARN", T1."U_ER_NMER", (SELECT COUNT ('E') FROM OVPM WHERE "U_BPP_TIPR" = 'EAR' AND "U_BPP_CCHI" = T1."U_ER_EARN" AND "U_BPP_NUMC" = T1."U_ER_NMER" 
			AND "Canceled" != 'Y') AS "CNT"	FROM "@STR_EARAPR" T0 INNER JOIN "@STR_EARAPRDET" T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T1."U_ER_STDO" = 'A' AND "U_ER_DEPE" = list_of_cols_val_tab_del;	
			SELECT COUNT('E') INTO cnt FROM "#tbloc" where cmp3 > 0;
			IF cnt > 0
			THEN
				SELECT TOP 1 cmp2 INTO nmrcchear FROM "#tbloc";
				error := 1;
				error_message := 'No se puede cancelar esta apertura debido a que el numero de EAR: '|| :nmrcchear || ' tiene movimientos...';
			ELSE
				UPDATE "@STR_EARAPRDET" T0 SET T0."U_ER_STDO" = 'C' FROM "@STR_EARAPRDET" T0 INNER JOIN "#tbloc" T1 ON T0."U_ER_EARN" = T1.cmp1 AND T0."U_ER_NMER" = T1.cmp2;
			END IF; 
			DROP TABLE "#tbloc";
		END IF;
	END IF;
/*
	IF :object_type = 'BPP_PAGM' AND IFNULL(:error,0) = 0 THEN
		SELECT 1,'ERROR' INTO error,error_message FROM DUMMY;
	END IF;
*/
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
select :error, :error_message FROM DUMMY;

END;