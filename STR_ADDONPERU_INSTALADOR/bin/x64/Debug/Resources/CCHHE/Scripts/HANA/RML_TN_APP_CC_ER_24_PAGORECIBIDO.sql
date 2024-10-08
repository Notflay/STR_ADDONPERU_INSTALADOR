CREATE FUNCTION RML_TN_APP_CC_ER_24_PAGORECIBIDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	cnt int;
	ctargt varchar(30);
	dtocta varchar(100);
	tpornd varchar(4);
	ctapgo varchar(30);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' THEN
		SELECT "U_BPP_TIPR" INTO tpornd FROM ORCT WHERE "DocEntry" = id;
		IF tpornd = 'CCH' OR tpornd = 'EAR'
		THEN
		--Validacion de seleccion de nro CCH - EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SELECT COUNT('E') INTO cnt FROM ORCT WHERE RTRIM("U_BPP_NUMC") = '---' AND "DocEntry" =  id;
			IF cnt > 0
			THEN
				error_message := 'No se ha seleccionado el nro caja/entrega...';
			END IF;
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			
			--Validacion de cuenta contable correcta * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
			SELECT CASE "U_BPP_TIPR" WHEN 'CCH' THEN (SELECT "U_BPP_ACCT" FROM "@BPP_CAJASCHICAS" WHERE "Code" = "U_BPP_CCHI") 
									 		WHEN 'EAR' THEN (SELECT "AcctCode" FROM OACT WHERE "FormatCode" = (SELECT "U_CE_CTPT" FROM "@STR_CCHEAR_SYS" WHERE "Code" = '001')) END 
									 		INTO ctargt FROM ORCT 
									 		WHERE "DocEntry" = id;					
			SELECT "CashAcct" INTO ctapgo FROM ORCT	WHERE "DocEntry" = id;
			IF :ctargt != :ctapgo 
			THEN
				SELECT TOP 1 "FormatCode" || ' - ' || "AcctName" INTO dtocta FROM OACT WHERE "AcctCode" = :ctargt;
				error_message := 'La cuenta registrada en el medio de pago no es la correcta, esta debe ser: ' || :dtocta;
			END IF;
			--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
		END IF;
		
	END IF;
END