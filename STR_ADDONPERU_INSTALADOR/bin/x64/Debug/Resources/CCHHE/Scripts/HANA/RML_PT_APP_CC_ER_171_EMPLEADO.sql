CREATE PROCEDURE RML_PT_APP_CC_ER_171_EMPLEADO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
--RETURNS VARCHAR(200)
AS
	cnt int;
BEGIN
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CCH * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	/* SOLICITUD DE DINERO */
	IF 	:transaction_type IN ('A','U') THEN
		 SELECT COUNT('E') INTO cnt FROM OHEM WHERE "U_CE_PVAS" IS NOT NULL AND "U_CE_CEAR" IS NULL AND "empID" = id;		
	 	 IF :cnt > 0
	  	 THEN
			UPDATE OHEM SET "U_CE_CEAR" = 'EAR' || "empID"  FROM OHEM WHERE "empID" = id;
	  	 END IF;	 	
	END IF;
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * EAR * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

END;