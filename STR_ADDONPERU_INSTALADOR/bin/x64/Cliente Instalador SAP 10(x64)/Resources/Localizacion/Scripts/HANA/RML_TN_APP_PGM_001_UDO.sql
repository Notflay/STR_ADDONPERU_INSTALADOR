CREATE FUNCTION RML_TN_APP_PGM_001_UDO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
LANGUAGE SQLSCRIPT
AS
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' THEN	
		declare rsl2 int;
		DECLARE numDocumento VARCHAR(20);	
		DECLARE proveedor VARCHAR(20);
		DECLARE rs14 int;
		DECLARE rs13 int;
		DECLARE docNum INT;
		DECLARE estado VARCHAR(20);
		DECLARE lineNum INT;
		
		-- Valida Configurada la cuenta
		DECLARE cuentaDefault VARCHAR(50);
		DECLARE codigoBanco VARCHAR(30);
		DECLARE cuentaBancaria VARCHAR(50);
		DECLARE nombreBanco VARCHAR(250);
		DECLARE controlKey CHAR(2);
		DECLARE moneda VARCHAR(10);
		
		-- Valida el pago del documento
		DECLARE diferencia DECIMAL(23,6);
		--DECLARE saldoImporte DECIMAL(23,6)
		
		DECLARE cursor CURSOR_PROV_DOC  FOR
        SELECT "DocEntry", "U_BPP_CODPROV", "U_BPP_NUMDOC","LineId"
        FROM "@BPP_PAGM_DET1"  
        WHERE IFNULL("U_BPP_CODPROV",'') <> '' 
        and IFNULL("U_BPP_NUMDOC",'')<>''
        AND "DocEntry" = :id;
		
		SELECT COUNT(*), MIN("LineId") INTO rsl2, lineNum
        FROM "@BPP_PAGM_DET1"
        WHERE "DocEntry" = :id 
        AND IFNULL("U_BPP_CODPROV", '') = '';

		 SELECT COUNT(*), MIN("LineId") INTO rs14, lineNum
        FROM "@BPP_PAGM_DET1"
        WHERE "DocEntry" = :id 
        AND IFNULL("U_BPP_NUMDOC", '') = '';

        IF rsl2 > 0 THEN 
            error_message := 'Se tiene que agregar mínimo 1 proveedor para continuar con el proceso';
            RETURN;
        END IF;	
			
		IF rs14 > 0 THEN 
            error_message := 'Linea: '|| lineNum || ' | El documento ingresado no tiene número de documento';
            RETURN;
        END IF;			
			
		FOR DATA AS CURSOR_PROV_DOC
		DO
			 -- Verificar si existe un duplicado del documento (U_BPP_CODPROV y U_BPP_NUMDOC)
            SELECT COUNT(T0."U_BPP_CODPROV") 
            INTO rs13 
            FROM "@BPP_PAGM_DET1" T0 
            INNER JOIN "@BPP_PAGM_CAB" T1 ON T0."DocEntry" = T1."DocEntry"
            WHERE T0."U_BPP_CODPROV" = DATA."U_BPP_CODPROV" 
            AND T0."U_BPP_NUMDOC" = DATA."U_BPP_NUMDOC"
            AND IFNULL(T0."U_BPP_CODPROV",'') <> '' 
            AND T1."U_BPP_ESTADO" <> 'Cancelado';
			
			-- Mapear el caso de que solo se pago una parte 
			
            IF rs13 > 1 THEN
                -- Get the DocEntry of the duplicate
                SELECT MIN(T0."DocEntry"),MIN(T1."U_BPP_ESTADO")
                INTO docNum,estado
                FROM "@BPP_PAGM_DET1" T0 
                inner join "@BPP_PAGM_CAB" T1 ON T0."DocEntry" = T1."DocEntry"
                WHERE T0."U_BPP_CODPROV" = DATA."U_BPP_CODPROV"
                AND T0."U_BPP_NUMDOC" = DATA."U_BPP_NUMDOC"
                AND T1."U_BPP_ESTADO" <> 'Cancelado'
                AND T0."DocEntry" <> :id;

				-- TRAE EL DocNum 


				select "U_BPP_MONTOPAG" - "U_BPP_SALDO" INTO diferencia from "@BPP_PAGM_DET1" WHERE "DocEntry" = :docNum  AND "U_BPP_NUMDOC" = DATA."U_BPP_NUMDOC";
               
				IF :diferencia = 0 THEN                
                -- Generate error message
                	error_message := 'Linea: ' || DATA."LineId" || ' | El documento ' || DATA."U_BPP_NUMDOC" || ' del proveedor ' || DATA."U_BPP_CODPROV" || ' se encuentra registrado en la planilla ' || docNum || ' en estado ' ||estado;
               		break;	
                END IF;
                -- Exit loop if duplicate is found
                
            END IF;
            
            -- Check if the supplier has your bank account set up
			SELECT TOP 1 IFNULL(T0."DflAccount",''),IFNULL(T1."BankCode",''),IFNULL(T1."Account",''),IFNULL(T1."AcctName",''),IFNULL(T1."ControlKey",''),IFNULL(T1."U_BPP_MONEDA",'')
			INTO cuentaDefault,codigoBanco, cuentaBancaria, nombreBanco, controlKey, moneda
			FROM OCRD T0
			LEFT JOIN OCRB T1 ON T1."CardCode" = T0."CardCode" AND T1."Account" = T0."DflAccount"
			WHERE T0."CardCode" = DATA."U_BPP_CODPROV";
			
			IF IFNULL(:cuentaDefault,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró cuenta por defecto del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
																		
			IF IFNULL(:codigoBanco,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró el codigo de Banco del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
			
			IF IFNULL(:cuentaBancaria,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró la cuenta bancaria del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
			
			IF IFNULL(:nombreBanco,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró el nombre del banco del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
			
			IF IFNULL(:controlKey,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró el ID Int.Ctrl del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
			
			IF IFNULL(:moneda,'') = '' THEN
				error_message := 'Linea: ' || DATA."LineId" || ' | No se configuró la moneda del proveedor: ' || DATA."U_BPP_CODPROV";
				break;
			END IF;
		END FOR;
	END IF;
END