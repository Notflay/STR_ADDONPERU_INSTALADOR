CREATE FUNCTION RML_TN_LC_2_SociosNegocio 
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	C1 INTEGER;
	E_MAIL NVARCHAR(100);
	nmdocumento NVARCHAR(20);
	cardCode NVARCHAR(100);
	cardName NVARCHAR(100);
	cardType CHAR(1);
	tipoPersona CHAR(3);
	tipoDoc CHAR(1);
	nombre NVARCHAR(100);
	apellidoP NVARCHAR(100);
	apellidoM NVARCHAR(100);
	C2 INT;
	moneda NVARCHAR(5);
BEGIN
	error_message := ''; 
	
	SELECT
		IFNULL(T1."E_Mail",''), "LicTradNum","CardCode","CardName","CardType","U_BPP_BPTP","U_BPP_BPTD","U_BPP_BPNO","U_BPP_BPAP","U_BPP_BPAM","Currency"
		INTO E_MAIL, nmdocumento, cardCode,cardName,cardType,tipoPersona, tipoDoc,nombre,apellidoP,apellidoM,moneda
	FROM OCRD T1
	WHERE T1."CardCode" = :id;
	
	select count(*) INTO C2 FROM OCRD WHERE "LicTradNum" = :nmdocumento and "CardType" = :cardType;

	C1 := CASE WHEN E_MAIL = '' THEN 1 ELSE 0 END;
	
	IF :transaction_type = 'A' OR :transaction_type =  'U' THEN
		/*
		IF :C1 > 0 THEN
			error_message := 'Debe ingresar el correo electrónico de la pestaña general.';
		END IF;
		
		IF (LENGTH(:nmdocumento) <> '8' AND :tipoPersona = 'TPN') OR (:tipoPersona  = 'TPJ' OR LENGTH(:nmdocumento) <> '11')  THEN
			error_message := 'El RUC o DNI debe ser de 11 u 8 dígitos';
		END IF;
		*/
		IF :tipoPersona = 'TPN' THEN
			IF LEFT(:nmdocumento,2) = '10' OR LEFT(:nmdocumento,2) = '15' 
			THEN
				IF LENGTH(:nmdocumento) <> '11' THEN
					error_message := 'El RUC o DNI debe ser de 11 u 8 dígitos';
				END IF;
			ELSEIF LENGTH(:nmdocumento) <> '8'
				THEN 
				IF ((LEFT(:nmdocumento,2) = '10' OR LEFT(:nmdocumento,2) = '15') AND LENGTH(:nmdocumento) = '11') THEN
				ELSE
					error_message := 'El RUC o DNI debe ser de 11 u 8 dígitos';
				END IF;
			-- AND (LENGTH(:nmdocumento) <> '11' AND LENGTH(:nmdocumento) <> '8'))	
			END IF;

		ELSEIF :tipoPersona = 'TPJ' THEN
			IF LENGTH(:nmdocumento) <> '11' THEN
				error_message := 'El RUC o DNI debe ser de 11 u 8 dígitos';
			END IF;
		END IF;
		
		IF IFNULL(:cardName,'') = '' THEN
			error_message := 'El Nombre o Razon Social es obligatorio';
		END IF;
		
		IF  1<:C2 THEN
			error_message := 'El RUC/DNI ingresado ya ha sido registrado anteriormente';
		END IF;
		
		IF LENGTH(:nmdocumento) = '11' AND :tipoDoc <> '6' THEN
			error_message := 'La cantidad de 11 carácteres de número de doc. solo puede ser RUC como tipo de doc.';
		END IF;
		
		IF LENGTH(:nmdocumento) = '8' AND :tipoDoc <> '1' THEN
			error_message := 'La cantidad de 8 carácteres de número de doc. solo puede ser DNI como tipo de doc.';
		END IF;
		
		IF (LEFT(:nmdocumento,2) = '10' OR LEFT(:nmdocumento,2) = '15') AND :tipoDoc = '6' AND :tipoPersona <> 'TPN' THEN
			error_message := 'RUC 10 o 15 solo pueden ser de personas naturales';
		END IF;
		
		IF :tipoDoc = '1' AND :tipoPersona <> 'TPN' THEN
			error_message := 'Tipo de documento DNI solo es para el tipo de Persona Natural';
		END IF;
		
		IF LEFT(:nmdocumento,2) = '20' AND :tipoDoc = '6' AND :tipoPersona <> 'TPJ' THEN
			error_message := 'Tipo de documento RUC solo es para el tipo de Persona Juridica';
		END IF; 
		
		IF :tipoPersona = 'TPN' AND ( IFNULL(:nombre,'') = '' OR  IFNULL(:apellidoP,'') = '' OR IFNULL(:apellidoM,'') = '' )  THEN
			error_message := 'Es obligatorio completar nombre y apellido al ser Persona Natural';
		END IF;
		
		IF :moneda != '##' AND (:cardType = 'C' OR :cardType = 'S') THEN
			error_message := 'La moneda debe ser de tipo todas para cliente y proveedores';
		END IF;
	END IF;
END