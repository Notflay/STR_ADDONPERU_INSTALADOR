CREATE PROCEDURE RML_PT_LC_203_ANTICIPOVENTAS
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    DECLARE @cc NVARCHAR(15);
    DECLARE @tp NVARCHAR(15);
    DECLARE @sr NVARCHAR(15);
    DECLARE @Numero NVARCHAR(15);
    DECLARE @sNumero NVARCHAR(15);
    DECLARE @iNumero INT;

    -- Variable de retorno para POSTRANSAC
	DECLARE @canceled CHAR(1);
    IF @transaction_type IN ('A', 'U')
    BEGIN
        UPDATE ODPI 
        SET NumAtCard = ISNULL(U_BPP_MDTD, '') + '-' + ISNULL(U_BPP_MDSD, '') + '-' + ISNULL(U_BPP_MDCD, ''), 
            FolioNum = 0
        WHERE DocEntry = @id;
  
        UPDATE OJDT 
        SET Ref2 = (SELECT NumAtCard FROM ODPI WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ODPI WHERE DocEntry = @id);
        
        UPDATE JDT1 
        SET Ref2 = (SELECT NumAtCard FROM ODPI WHERE DocEntry = @id)
        WHERE TransId = (SELECT TransId FROM ODPI WHERE DocEntry = @id);
        
        -- ACTUALIZA CORRELATIVO
        IF @transaction_type = 'A'
        BEGIN
            SELECT @tp = U_BPP_MDTD, @sr = U_BPP_MDSD, @sNumero = U_BPP_MDCD,  @canceled = CANCELED
            FROM ODPI 
            WHERE DocEntry = CAST(@id AS INT);
           
			IF @canceled <> 'C' BEGIN
				SET @iNumero = CAST(@sNumero AS INT) + 1;
            
				SET @Numero = (CASE 
								WHEN LEN(@sNumero) >= LEN(CAST(@iNumero AS NVARCHAR(15))) 
								THEN RIGHT(REPLICATE('0', LEN(@sNumero)) + CAST(@iNumero AS NVARCHAR(15)), LEN(@sNumero)) 
								ELSE CAST(@iNumero AS NVARCHAR(15)) 
							   END);
			
				UPDATE "@BPP_NUMDOC" 
				SET U_BPP_NDCD = @Numero 
				WHERE U_BPP_NDTD = @tp AND U_BPP_NDSD = @sr;
			END
			ELSE
			BEGIN
				 UPDATE ODPI 
				SET "NumAtCard" = '***ANULADO***', "Indicator"='ZA'
				WHERE "DocEntry" = CAST(@id AS INT);
		
				UPDATE OJDT 
				SET "Ref2" = '***ANULADO***'
				WHERE "TransId" = (Select top 1 "TransId" FROM ODPI where "DocEntry" = CAST(@id AS INT));
		      
				UPDATE T0
				SET T0."NumAtCard" = '***ANULADO***', T0."Indicator"='ZA'
				FROM ODPI T0 
				INNER JOIN DPI1 T1 ON T1."BaseEntry" = T0."DocEntry"
				WHERE T1."DocEntry" = CAST(@id AS INT);
			END           
        END
    END

    IF @transaction_type = 'C'
    BEGIN
        UPDATE ODPI 
        SET NumAtCard = '***ANULADO***', Indicator = 'ZA'
        WHERE DocEntry = CAST(@id AS INT);
        
        UPDATE OJDT 
        SET Ref2 = '***ANULADO***'
        WHERE TransId = (SELECT TOP 1 TransId FROM ODPI WHERE DocEntry = CAST(@id AS INT));
    END
END