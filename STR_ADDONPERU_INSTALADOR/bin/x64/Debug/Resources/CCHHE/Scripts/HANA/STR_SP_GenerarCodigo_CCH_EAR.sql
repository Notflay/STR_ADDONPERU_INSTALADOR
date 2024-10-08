CREATE PROCEDURE STR_SP_GenerarCodigo_CCH_EAR
(
	pv_Codigo varchar(10),
	pv_Tipo char(3)
)
AS
BEGIN
	IF pv_Tipo='CCH'THEN
		BEGIN
			SELECT MAX("CODIGO") AS "COD" FROM 
			(
				SELECT :pv_Codigo || '-' || RIGHT(TO_VARCHAR(YEAR(NOW())),2) || '-' 
				||RIGHT('000'||LTRIM(IFNULL((SELECT MAX(RIGHT("U_CC_NMCC",3)) FROM "@STR_CCHAPRDET" WHERE "U_CC_CJCH" = :pv_Codigo),'0')+1),3) AS "CODIGO" FROM DUMMY
			) AA; 
		END;
	END IF;
	IF pv_Tipo='EAR' THEN
		BEGIN
			SELECT MAX("CODIGO") AS "COD" FROM 
			(	SELECT :pv_Codigo || '-' || RIGHT(TO_VARCHAR(YEAR(NOW())),2) || '-' 
				||RIGHT('000'||LTRIM(IFNULL((SELECT MAX(RIGHT("U_ER_NMER",3)) FROM "@STR_EARAPRDET" WHERE "U_ER_EARN" = :pv_Codigo),'0')+1),3) AS "CODIGO" FROM DUMMY
			) AA;
		END;
	END IF;
END;


