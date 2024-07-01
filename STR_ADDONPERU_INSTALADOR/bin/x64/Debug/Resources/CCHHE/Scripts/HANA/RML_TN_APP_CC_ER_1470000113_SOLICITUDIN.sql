CREATE FUNCTION RML_TN_APP_CC_ER_1470000113_SOLICITUDIN
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
	iVal int=0;
	mnd VARCHAR(5);
	slc CHAR(1);
	mnt NUMERIC(19,6);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A'
	THEN
		select count('z') into iVal from oprq t0 where "ReqType"!='12' and T0."DocEntry" = id;
		if :iVal>0 
		THEN
			SELECT "U_CE_EAR"  INTO slc FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = id;
			SELECT "U_CE_MNDA" INTO mnd FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = id;
			SELECT "U_CE_IMSL" INTO mnt FROM OPRQ T0 INNER JOIN PRQ1 T1 ON T0."DocEntry" =  T1."DocEntry" WHERE T0."DocEntry" = id;
		
			IF IFNULL(:mnd,'') = '' AND :slc = 'Y'
			THEN
				error_message := 'No se ha definido la moneda de la solicitud de dinero EAR...';
			END IF;
			IF :mnt<=0 AND :slc = 'Y'
			THEN
				error_message := 'Ingrese un monto valido para la solicitud de dinero EAR...';
			END IF;
		END IF;
	END IF;
END