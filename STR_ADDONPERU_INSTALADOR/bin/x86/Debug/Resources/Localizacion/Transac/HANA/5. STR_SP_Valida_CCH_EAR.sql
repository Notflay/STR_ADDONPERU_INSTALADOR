CREATE PROCEDURE STR_SP_Valida_CCH_EAR
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
BEGIN
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
/*VALIDACION DE SALDOS CAJA CHICA*/
IF object_type = 'STR_CCHCRG' AND (transaction_type = 'A' OR transaction_type = 'U')
THEN 
	SELECT SUM("IMT") INTO ttcch FROM(
			SELECT 
				CASE T0."U_CC_MNDA" WHEN 'SOL' THEN
					CASE T1."U_CC_MNDC" WHEN 'SOL' THEN
						"U_CC_TTLN"
					ELSE
						("U_CC_TTLN"*(SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_CC_FCDC"))
					END
				ELSE
					CASE T1."U_CC_MNDC" WHEN 'SOL' THEN
						("U_CC_TTLN")/(SELECT "Rate" FROM ORTT WHERE "RateDate" = "U_CC_FCDC")
					ELSE
						"U_CC_TTLN" 
					END
				END AS "IMT" 
			FROM "@STR_CCHCRG" T0 INNER JOIN "@STR_CCHCRGDET" T1 ON T0."DocEntry" = T1."DocEntry" 
			WHERE T0."DocEntry" = list_of_cols_val_tab_del AND "U_CC_SLCC" = 'Y' AND "U_CC_ESTD" IN ('CRE','ERR')
			) AS TX0;
			SELECT "U_CC_SLDI" - :ttcch INTO sldcch  FROM "@STR_CCHCRG" WHERE "DocEntry" = list_of_cols_val_tab_del;
			SELECT TOP 1 "U_STR_SLNG" INTO flgsld FROM "@BPP_CAJASCHICAS" T0 INNER JOIN "@STR_CCHCRG" T1 ON T0."Code" = T1."U_CC_NMBR" WHERE T1."DocEntry" = list_of_cols_val_tab_del;
			IF :sldcch < 0 AND IFNULL(:flgsld,'N')<> 'Y'
			THEN
				error := 1;
				error_message := 'El monto total de los documentos registrados (' || ttcch || '), es mayor al saldo de esta caja chica';
			END IF;
END IF;
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
/*GENERA EL CODIGO DE EAR DEL EMPLEADO*/
	IF object_type = '171' AND (transaction_type = 'A' OR transaction_type = 'U')
	THEN
	  SELECT COUNT('E') INTO cnt FROM OHEM WHERE "U_CE_PVAS" IS NOT NULL AND "U_CE_CEAR" IS NULL AND "empID" = list_of_cols_val_tab_del;		
	  IF :cnt > 0
	  THEN
		UPDATE OHEM SET "U_CE_CEAR" = 'EAR' || "empID"  FROM OHEM WHERE "empID" = list_of_cols_val_tab_del;
	  END IF;	 
	END IF;	
	
	
--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
--Solicitud de dinero
IF object_type = '1470000113' AND transaction_type = 'A'
THEN

	select count('z') into iVal from oprq t0 where "ReqType"!='12' and T0."DocEntry" = list_of_cols_val_tab_del;
	
	if :iVal>0 
	THEN
	
		SELECT "U_CE_EAR"  INTO slc FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = list_of_cols_val_tab_del;
		SELECT "U_CE_MNDA" INTO mnd FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = list_of_cols_val_tab_del;
		SELECT "U_CE_IMSL" INTO mnt FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = list_of_cols_val_tab_del;
	
		IF IFNULL(:mnd,'') = '' AND :slc = 'Y'
		THEN
			error_message := 'No se ha definido la moneda de la solicitud de dinero EAR...';
			error := 1;
		END IF;
		IF :mnt<=0 AND :slc = 'Y'
		THEN
			error_message := 'Ingrese un monto valido para la solicitud de dinero EAR...';
			error := 1;
		END IF;
	
	END IF;
END IF;



--Pagos efectuados
IF object_type = '46' AND transaction_type = 'A'
THEN
	SELECT "U_BPP_TIPR" INTO tpornd FROM OVPM WHERE "DocEntry" = list_of_cols_val_tab_del;
	IF tpornd = 'CCH' OR tpornd = 'EAR'
	THEN
	--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		SELECT COUNT('E') INTO cnt FROM OVPM WHERE RTRIM("U_BPP_NUMC") = '---' AND "DocEntry" =  list_of_cols_val_tab_del;
		IF cnt > 0
		THEN
			error := 1;
			error_message := 'No se ha seleccionado el nro caja/entrega...';
		END IF;
		--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		
		--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		SELECT CASE "U_BPP_TIPR" WHEN 'CCH' THEN (SELECT "U_BPP_ACCT" FROM "@BPP_CAJASCHICAS" WHERE "Code" = "U_BPP_CCHI") 
								 		WHEN 'EAR' THEN (SELECT "AcctCode" FROM OACT WHERE "FormatCode" = (SELECT "U_CE_CTPT" FROM "@STR_CCHEAR_SYS" WHERE "Code" = '001')) END 
								 		INTO ctargt FROM OVPM 
								 		WHERE "DocEntry" = list_of_cols_val_tab_del;					
		SELECT "CashAcct" INTO ctapgo FROM OVPM	WHERE "DocEntry" = list_of_cols_val_tab_del;
		IF :ctargt != :ctapgo 
		THEN
			SELECT TOP 1 "FormatCode" || ' - ' || "AcctName" INTO dtocta FROM OACT WHERE "AcctCode" = :ctargt;
			error := 1;
			error_message := 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' || :dtocta;
		END IF;
		--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	END IF;
END IF;
--Pagos recibidos
IF object_type = '24' AND transaction_type = 'A'
THEN
	SELECT "U_BPP_TIPR" INTO tpornd FROM ORCT WHERE "DocEntry" = list_of_cols_val_tab_del;
	IF tpornd = 'CCH' OR tpornd = 'EAR'
	THEN
	--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		SELECT COUNT('E') INTO cnt FROM ORCT WHERE RTRIM("U_BPP_NUMC") = '---' AND "DocEntry" =  list_of_cols_val_tab_del;
		IF cnt > 0
		THEN
			error := 1;
			error_message := 'No se ha seleccionado el nro caja/entrega...';
		END IF;
		--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		
		--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		SELECT CASE "U_BPP_TIPR" WHEN 'CCH' THEN (SELECT "U_BPP_ACCT" FROM "@BPP_CAJASCHICAS" WHERE "Code" = "U_BPP_CCHI") 
								 		WHEN 'EAR' THEN (SELECT "AcctCode" FROM OACT WHERE "FormatCode" = (SELECT "U_CE_CTPT" FROM "@STR_CCHEAR_SYS" WHERE "Code" = '001')) END 
								 		INTO ctargt FROM ORCT 
								 		WHERE "DocEntry" = list_of_cols_val_tab_del;					
		SELECT "CashAcct" INTO ctapgo FROM ORCT	WHERE "DocEntry" = list_of_cols_val_tab_del;
		IF :ctargt != :ctapgo 
		THEN
			SELECT TOP 1 "FormatCode" || ' - ' || "AcctName" INTO dtocta FROM OACT WHERE "AcctCode" = :ctargt;
			error := 1;
			error_message := 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' || :dtocta;
		END IF;
		--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
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
		INSERT INTO "#tbloc" SELECT T0."U_ER_EARN", T0."U_ER_NMER", (SELECT COUNT ('E') FROM OVPM WHERE "U_BPP_TIPR" = 'EAR' AND "U_BPP_CCHI" = T0."U_ER_EARN" AND "U_BPP_NUMC" = T0."U_ER_NMER" 
		AND "Canceled" != 'Y') AS "CNT"	FROM "@STR_EARAPR" T0 INNER JOIN "@STR_EARAPRDET" T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T1."U_ER_STDO" = 'A' AND T0."U_ER_DEPE" = list_of_cols_val_tab_del;	
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
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
select :error, :error_message FROM DUMMY;
END;