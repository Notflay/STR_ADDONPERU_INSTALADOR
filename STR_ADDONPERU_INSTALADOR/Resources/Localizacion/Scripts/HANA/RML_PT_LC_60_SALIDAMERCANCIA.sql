CREATE PROCEDURE RML_PT_LC_60_SALIDAMERCANCIA
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
AS
cc nvarchar(15);
tp nvarchar(15);
sr nvarchar(15);
Numero nvarchar(15);
sNumero nvarchar(15);
iNumero integer;

cancelado CHAR(1);
BEGIN
	-- Variable de retorno para POSTRANSAC
	-- ACTUALIZA CORRELATIVO
		IF :transaction_type = 'A' THEN
		
			select "U_BPP_MDTD","U_BPP_MDSD","U_BPP_MDCD","CANCELED" INTO tp,sr,sNumero,cancelado from OIGE where "DocEntry"= TO_INTEGER(:id);
			
			IF :cancelado <> 'C' THEN 
				SELECT  TO_INTEGER(:sNumero) INTO iNumero FROM DUMMY;
			iNumero := :iNumero + 1;
			
			SELECT (CASE WHEN LENGTH(:sNumero)>= LENGTH(TO_VARCHAR(:iNumero)) THEN LPAD (TO_VARCHAR(:iNumero), 
			(length(:sNumero)-LENGTH(TO_VARCHAR(:iNumero))) + LENGTH(TO_VARCHAR(:iNumero)), '0') ELSE TO_VARCHAR(:iNumero)END) INTO Numero FROM DUMMY; 
		
			UPDATE "@BPP_NUMDOC" set "U_BPP_NDCD" = :Numero where "U_BPP_NDTD"= :tp and "U_BPP_NDSD"= :sr;
			END IF;
			
		
		END IF;
END