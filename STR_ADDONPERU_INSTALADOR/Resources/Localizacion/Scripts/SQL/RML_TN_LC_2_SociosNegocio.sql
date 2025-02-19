CREATE FUNCTION RML_TN_LC_2_SociosNegocio 
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @C1 INT;
    DECLARE @E_MAIL NVARCHAR(100);
    DECLARE @nmdocumento NVARCHAR(20);
    DECLARE @cardCode NVARCHAR(100);
    DECLARE @cardName NVARCHAR(100);
    DECLARE @cardType CHAR(1);
    DECLARE @tipoPersona CHAR(3);
    DECLARE @tipoDoc CHAR(1);
    DECLARE @nombre NVARCHAR(100);
    DECLARE @apellidoP NVARCHAR(100);
    DECLARE @apellidoM NVARCHAR(100);
    DECLARE @error_message NVARCHAR(200);

    -- Variable de retorno de mensaje de error
    SET @error_message = ''; 

    SELECT
        @E_MAIL = ISNULL(T1.E_Mail, ''), 
        @nmdocumento = T1.LicTradNum, 
        @cardCode = T1.CardCode, 
        @cardName = T1.CardName, 
        @cardType = T1.CardType, 
        @tipoPersona = T1.U_BPP_BPTP, 
        @tipoDoc = T1.U_BPP_BPTD, 
        @nombre = T1.U_BPP_BPNO, 
        @apellidoP = T1.U_BPP_BPAP, 
        @apellidoM = T1.U_BPP_BPAM
    FROM OCRD T1
    WHERE T1.CardCode = @id;

    SET @C1 = CASE WHEN @E_MAIL = '' THEN 1 ELSE 0 END;
    
    IF @transaction_type IN ('A', 'U')
    BEGIN
        IF @C1 > 0
        BEGIN
            SET @error_message = 'Debe ingresar el correo electrónico de la pestaña general.';
            RETURN @error_message;
        END
        
        IF LEN(@nmdocumento) NOT IN (8, 11) AND @tipoPersona IN ('TPJ', 'TPN')
        BEGIN
            SET @error_message = 'El RUC o DNI debe ser de 11 u 8 dígitos';
            RETURN @error_message;
        END
        
        IF ISNULL(@cardName, '') = ''
        BEGIN
            SET @error_message = 'El Nombre o Razon Social es obligatorio';
            RETURN @error_message;
        END
        
        IF (SELECT COUNT(*) FROM OCRD WHERE LicTradNum = @nmdocumento AND CardType = @cardType) > 1
        BEGIN
            SET @error_message = 'El RUC/DNI ingresado ya ha sido registrado anteriormente';
            RETURN @error_message;
        END
        
        IF LEN(@nmdocumento) = 11 AND @tipoDoc <> '6'
        BEGIN
            SET @error_message = 'La cantidad de 11 carácteres de número de doc. solo puede ser RUC como tipo de doc.';
            RETURN @error_message;
        END
        
        IF LEN(@nmdocumento) = 8 AND @tipoDoc <> '1'
        BEGIN
            SET @error_message = 'La cantidad de 8 carácteres de número de doc. solo puede ser DNI como tipo de doc.';
            RETURN @error_message;
        END
        
        IF LEFT(@nmdocumento, 2) IN ('10', '15') AND @tipoDoc = '6' AND @tipoPersona <> 'TPN'
        BEGIN
            SET @error_message = 'RUC 10 o 15 solo pueden ser de personas naturales';
            RETURN @error_message;
        END
        
        IF @tipoDoc = '1' AND @tipoPersona <> 'TPN'
        BEGIN
            SET @error_message = 'Tipo de documento DNI solo es para el tipo de Persona Natural';
            RETURN @error_message;
        END
        
        IF LEFT(@nmdocumento, 2) = '20' AND @tipoDoc = '6' AND @tipoPersona <> 'TPJ'
        BEGIN
            SET @error_message = 'Tipo de documento RUC solo es para el tipo de Persona Juridica';
            RETURN @error_message;
        END 
        
        IF @tipoPersona = 'TPN' AND (ISNULL(@nombre, '') = '' OR ISNULL(@apellidoP, '') = '' OR ISNULL(@apellidoM, '') = '')
        BEGIN
            SET @error_message = 'Es obligatorio completar nombre y apellido al ser Persona Natural';
            RETURN @error_message;
        END
    END
    
    RETURN @error_message;
END;
