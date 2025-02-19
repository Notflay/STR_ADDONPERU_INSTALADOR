CREATE PROCEDURE RML_PT_APP_CC_ER_171_EMPLEADO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    DECLARE @cnt INT;

    -- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    -- SOLICITUD DE DINERO
    IF @transaction_type IN ('A', 'U')
    BEGIN
        SELECT @cnt = COUNT(*)
        FROM OHEM
        WHERE U_CE_PVAS IS NOT NULL AND U_CE_CEAR IS NULL AND empID = @id;

        IF @cnt > 0
        BEGIN
            UPDATE OHEM
            SET U_CE_CEAR = 'EAR' + CAST(empID AS NVARCHAR)
            WHERE empID = @id;
        END
    END
    -- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
END;