CREATE PROCEDURE STR_TN_Localizacion
(
	IN object_type  NVARCHAR(20),
	IN transaction_type  NVARCHAR(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)

AS

BEGIN
error :=0;
error_message := N'Ok';


--------------------------------------------------------------------------

IF IFNULL(:error,0) = 0 THEN

    CALL STR_SP_VALIDA_APPSTRAT(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);
END IF;

IF IFNULL(:error,0) = 0 THEN
    CALL STR_SP_BPP_LocAnulSUNAT (:object_type, :transaction_type, :list_of_cols_val_tab_del, :error, :error_message);
END IF;

IF IFNULL(:error,0) = 0 THEN
    CALL STR_SP_BPP_LocNumSUNAT (:object_type, :transaction_type,  :list_of_cols_val_tab_del, :error, :error_message);
END IF;

IF IFNULL(:error,0) = 0 THEN
    CALL STR_SP_BPP_LOCDETRACCIONES (:object_type, :transaction_type, :list_of_cols_val_tab_del, :error, :error_message);
END IF;

--------------------------------------------------------------------------

SELECT :error, :error_message from dummy;

END;




