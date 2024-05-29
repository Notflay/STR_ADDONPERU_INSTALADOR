CREATE PROCEDURE SBO_SP_TransactionNotification
(
	in object_type nvarchar(20), 			-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
cont1 varchar(200);	
cont2 varchar(200);
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
R1 varchar(200);	
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

IF :error=0 
THEN
	CALL STR_TN_General(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);
END IF;


-- Select the return values
select :error, :error_message FROM dummy;

end;