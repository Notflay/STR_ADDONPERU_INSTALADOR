CREATE  PROCEDURE SBO_SP_TransactionNotification

@object_type nvarchar(20), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'


--IF @object_type = '13' and (@transaction_type = 'A' )
--BEGIN
--UPDATE OINV
--SET U_STR_CdgHash = NULL, U_STR_Estado = NULL, U_STR_EstOtor = NULL, /*U_STR_MtvoCD = NULL,*/ U_STR_ObtEst = NULL,
--U_STR_ObsEst = NULL, U_STR_ResDir = NULL, U_STR_ComBaj = NULL, U_STR_FECorrelativo = NULL, U_STR_FETextoL = NULL
--WHERE-- LEFT(U_BPP_MDTD,1) IN('B', 'F')
--DocEntry= @list_of_cols_val_tab_del
--END
--IF @object_type = '14' and (@transaction_type = 'A' )
--BEGIN
--UPDATE ORIN
--SET U_STR_CdgHash = NULL, U_STR_Estado = NULL, U_STR_EstOtor = NULL,/* U_STR_MtvoCD = NULL,*/ U_STR_ObtEst = NULL,
--U_STR_ObsEst = NULL, U_STR_ResDir = NULL, U_STR_ComBaj = NULL, U_STR_FECorrelativo = NULL, U_STR_FETextoL = NULL
--WHERE-- LEFT(U_BPP_MDTD,1) IN('B', 'F')
--DocEntry= @list_of_cols_val_tab_del
--END

----------------------------------------------------------------------------------------------------------------------------------

   exec [dbo].[ValGeneral] @object_type, @transaction_type, @num_of_cols_in_key, @list_of_key_cols_tab_del, @list_of_cols_val_tab_del, @error output, @error_message output

----------------------------------------------------------------------------------------------------------------------------------


-- Select the return values
select @error, 'TN '+@error_message

end