CREATE PROCEDURE SP_RML_TN_APP_PMD
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)
AS
--Pago masivo detracciones
vv_CodComp INTEGER;
vd_FecDeps SECONDDATE;
vv_NumDeps VARCHAR(20);
vv_CdgPvdr VARCHAR(40);
vv_Nmatcar VARCHAR(40);
vv_Status VARCHAR(1);
BEGIN
-- * * * * * * * * * * * * * * * * * * * * * * * * * * Pago Masivo de Detracciones * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	-->30
	IF :object_type = '30'  THEN
		SELECT RML_TN_APP_PMD_30_ASIENTO(:list_of_cols_val_tab_del, :transaction_type) INTO error_message FROM DUMMY;
		IF IFNULL(:error_message,'') <> '' 
		THEN
			SELECT 1 INTO error FROM DUMMY;
		END IF;
	END IF;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
select :error, :error_message FROM DUMMY;
END;