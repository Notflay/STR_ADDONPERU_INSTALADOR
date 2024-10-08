CREATE FUNCTION RML_TN_APP_PGM_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    SET @error_message = '';

    IF @transaction_type IN ('A')
    BEGIN
        DECLARE @rsl2 INT;
		 DECLARE @numDocumento VARCHAR(20);	
        DECLARE @proveedor VARCHAR(20);
        DECLARE @rs14 INT;
        DECLARE @rs13 INT;
        DECLARE @docNum INT;
        DECLARE @estado VARCHAR(20);
        DECLARE @lineNum INT;
        
        -- Valida Configurada la cuenta
        DECLARE @cuentaDefault VARCHAR(50);
        DECLARE @codigoBanco VARCHAR(30);
        DECLARE @cuentaBancaria VARCHAR(50);
        DECLARE @nombreBanco VARCHAR(250);
        DECLARE @controlKey CHAR(2);
        DECLARE @moneda VARCHAR(10);
		
		DECLARE @diferencia DECIMAL(23,6);

		 -- Cursor for processing each document
        DECLARE cursor_prov_doc CURSOR FOR
        SELECT DocEntry, U_BPP_CODPROV, U_BPP_NUMDOC, LineId
        FROM "@BPP_PAGM_DET1"
        WHERE ISNULL(U_BPP_CODPROV, '') <> '' 
        AND ISNULL(U_BPP_NUMDOC, '') <> ''
        AND DocEntry = @id;

         -- Check for missing supplier codes
        SELECT @rsl2 = COUNT(*), @lineNum = MIN(LineId)
        FROM "@BPP_PAGM_DET1"
        WHERE DocEntry = @id 
        AND ISNULL(U_BPP_CODPROV, '') = '';

        -- Check for missing document numbers
        SELECT @rs14 = COUNT(*), @lineNum = MIN(LineId)
        FROM "@BPP_PAGM_DET1"
        WHERE DocEntry = @id 
        AND ISNULL(U_BPP_NUMDOC, '') = '';

        IF @rsl2 > 0
        BEGIN
            SET @error_message = 'Se tiene que agregar mínimo 1 proveedor para continuar con el proceso';
			RETURN @error_message;
		END

		IF @rs14 > 0
        BEGIN
            SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | El documento ingresado no tiene número de documento';
			RETURN @error_message;
		END

		OPEN cursor_prov_doc;
        FETCH NEXT FROM cursor_prov_doc INTO @docNum, @proveedor, @numDocumento, @lineNum;

		 WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check for duplicate documents
            SELECT @rs13 = COUNT(*)
            FROM "@BPP_PAGM_DET1" T0
            INNER JOIN "@BPP_PAGM_CAB" T1 ON T0.DocEntry = T1.DocEntry
            WHERE T0.U_BPP_CODPROV = @proveedor
            AND T0.U_BPP_NUMDOC = @numDocumento
            AND ISNULL(T0.U_BPP_CODPROV, '') <> ''
            AND T1.U_BPP_ESTADO <> 'Cancelado';

            IF @rs13 > 1
            BEGIN
                -- Get the DocEntry of the duplicate
                SELECT @docNum = MIN(T0.DocEntry), @estado = MIN(T1.U_BPP_ESTADO)
                FROM "@BPP_PAGM_DET1" T0
                INNER JOIN "@BPP_PAGM_CAB" T1 ON T0.DocEntry = T1.DocEntry
                WHERE T0.U_BPP_CODPROV = @proveedor
                AND T0.U_BPP_NUMDOC = @numDocumento
                AND T1.U_BPP_ESTADO <> 'Cancelado'
                AND T0.DocEntry <> @id;

				SET @diferencia = (SELECT "U_BPP_MONTOPAG" - "U_BPP_SALDO"  from "@BPP_PAGM_DET1" WHERE "DocEntry" = @docNum  AND "U_BPP_NUMDOC" = @numDocumento);
               
				IF @diferencia = 0 BEGIN  
					-- Generate error message
					SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | El documento ' + @numDocumento + ' del proveedor ' + @proveedor + ' se encuentra registrado en la planilla ' + CAST(@docNum AS NVARCHAR(10)) + ' en estado ' + @estado;
					CLOSE cursor_prov_doc;
					DEALLOCATE cursor_prov_doc;
					RETURN @error_message;
				END
			END

            -- Check if the supplier has their bank account set up
            SELECT TOP 1 @cuentaDefault = ISNULL(T0.DflAccount, ''),
                         @codigoBanco = ISNULL(T1.BankCode, ''),
                         @cuentaBancaria = ISNULL(T1.Account, ''),
                         @nombreBanco = ISNULL(T1.AcctName, ''),
                         @controlKey = ISNULL(T1.ControlKey, ''),
                         @moneda = ISNULL(T1.U_BPP_MONEDA, '')
            FROM OCRD T0
            LEFT JOIN OCRB T1 ON T1.CardCode = T0.CardCode AND T1.Account = T0.DflAccount
            WHERE T0.CardCode = @proveedor;

            IF ISNULL(@cuentaDefault, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró cuenta por defecto del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
			END

            IF ISNULL(@codigoBanco, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró el código de Banco del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
		   END

            IF ISNULL(@cuentaBancaria, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró la cuenta bancaria del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
			END

            IF ISNULL(@nombreBanco, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró el nombre del banco del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
			END

            IF ISNULL(@controlKey, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró el ID Int.Ctrl del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
			END

            IF ISNULL(@moneda, '') = ''
            BEGIN
                SET @error_message = 'Linea: ' + CAST(@lineNum AS NVARCHAR(10)) + ' | No se configuró la moneda del proveedor: ' + @proveedor;
                CLOSE cursor_prov_doc;
                DEALLOCATE cursor_prov_doc;
				RETURN @error_message;
			END

            FETCH NEXT FROM cursor_prov_doc INTO @docNum, @proveedor, @numDocumento, @lineNum;
        END

        CLOSE cursor_prov_doc;
        DEALLOCATE cursor_prov_doc;
    END
    RETURN @error_message;
END

