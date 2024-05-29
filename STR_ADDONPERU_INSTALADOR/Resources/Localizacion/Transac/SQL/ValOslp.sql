CREATE  PROCEDURE ValOslp

--Empleado de Ventas/Encargado de Compras

(
	@lctCode			int
,	@TipoTransaccion	nchar(1)
,	@error				int output-- Result (0 for no error)
,	@error_message		nvarchar(200) output-- Error string to be displayed
)
AS  
BEGIN 

--IF (@TipoTransaccion in ('A'))
--begin
--	declare @Sucur int
--	select @Sucur = max(cast(Code as int)) + 1 from oubr

--	insert into oubr (Code, [Name], Remarks, UserSign)
--	values (@Sucur, @CoSucursal, @NoSucursal, 1)

--end
--IF (@TipoTransaccion in ('D'))
--Begin
	
--End


return

END

