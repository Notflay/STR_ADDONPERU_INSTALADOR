CREATE FUNCTION RML_TN_LC_59_ENTRADAMERCANCIA
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @error_message NVARCHAR(200);
    DECLARE @R4 INT;

    -- Inicialización de la variable de error
    SET @error_message = ''; 

    IF @transaction_type IN ('A', 'U')
    BEGIN
        -- Verificar la condición del Tipo de Operación en el detalle del documento
        SELECT @R4 = COUNT(*)
        FROM IGN1 T0  
        INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
        WHERE (ISNULL(T0.U_tipoOpT12, '') = '' AND T1.InvntItem = 'Y')
          AND T0.DocEntry = @id;

        IF @R4 > 0 
        BEGIN 
            SET @error_message = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento'; 
            RETURN @error_message;
        END;
    END;

    RETURN @error_message;
END;

