USE [PROD_CRP]
GO
/****** Object:  StoredProcedure [dbo].[SP_RML_PT_APP_LTR]    Script Date: 6/19/2024 5:03:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_RML_PT_APP_LTR]
( 
	@object_type nvarchar(20), --> SBO Object Type
	@transaction_type nchar(1), --> [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	@list_of_key_cols_tab_del nvarchar(255),
	@error int out,
	@error_message nvarchar(200) out
	)
AS
BEGIN
	--> Valores de retorno


	Salir:
END
GO
