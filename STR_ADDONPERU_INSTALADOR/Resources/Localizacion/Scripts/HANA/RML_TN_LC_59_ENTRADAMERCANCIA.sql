CREATE FUNCTION RML_TN_LC_59_ENTRADAMERCANCIA
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS

R1 VARCHAR(30);
R2 VARCHAR(30);
R3 VARCHAR(30);
R4 VARCHAR(30);
R5 VARCHAR(30);


v_BaseEntry nvarchar(50);
v_LocManTran nvarchar(10);
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type IN ('A','U') THEN
		   --Tipo de Operacion	
		SELECT(SELECT count(*) FROM IGN1 T0  INNER JOIN OITM T1 ON T0."ItemCode" = T1."ItemCode"
		WHERE (IFNULL(T0."U_tipoOpT12",'') ='' and t1."InvntItem"='Y' ) 
		AND T0."DocEntry" = :id)INTO R4 FROM DUMMY;
		
		IF :R4 > 0 THEN 
			error_message := 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento'; 
		END IF;
	END IF;
END