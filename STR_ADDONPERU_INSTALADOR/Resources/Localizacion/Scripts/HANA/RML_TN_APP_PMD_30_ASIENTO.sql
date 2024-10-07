CREATE FUNCTION RML_TN_APP_PMD_30_ASIENTO
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
BEGIN
	-- Variable de retorno de mensaje de error
	--DECLARE error_message NVARCHAR(200);
	error_message := ''; 
	
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN	
		DECLARE rsl int;
		SELECT COUNT('a') into rsl from OJDT T0  inner join OJDT T1 ON T0."TransId" != T1."TransId" AND T0."U_BPP_DocKeyDest" = T1."U_BPP_DocKeyDest"
		AND T0."U_BPP_CtaTdoc" = T1."U_BPP_CtaTdoc"  AND T1."TransCode" = 'DTR' and T1."StornoToTr" is null AND T1."TransId" = :id;
		IF :rsl > 0 
		THEN 
			error_message :='Existe un asiento de detracción con la misma referencia';
		END IF;
	END IF;
END