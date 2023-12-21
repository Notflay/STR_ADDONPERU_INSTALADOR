CREATE PROCEDURE STR_SP_LT_FormatoLetras
(
	/*********************************** 
		Migracion hana: Formato de Letras
		==================
		por: Nilton condori
		Fecha: 13/08/2014
		Comentarios: Este SP fue crado basandose del SP de la version SQL
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/
	IN Letra INTEGER
)
AS
	/************************
	declaracion de variable 
	*************************/
	Monto DECIMAL(19,6);
	Moneda NVARCHAR(10);
	CodSN NVARCHAR(20);
	MontoLetras NVARCHAR(500);
BEGIN
	
	SELECT(select "LocTotal" from OJDT where "TransId" = :Letra) INTO Monto FROM DUMMY; 
	SELECT(select case when IFNULL("TransCurr",'')='' then 'SOL' else "TransCurr" end  from OJDT where "TransId" = :Letra) INTO Moneda FROM DUMMY; 
	
	SELECT(select t2."CardCode" from OJDT t0 inner join JDT1 t1 on t0."TransId" = t1."TransId" 
	inner join OCRD t2 on t1."ShortName" = t2."CardCode" where t0."TransId" = :Letra)INTO CodSN FROM DUMMY; 
	
	/*****************************************************************************************************************************
	Llamada al procedimiento sp_Num2Let, ":MontoLetras" es una variable local que tomará el valor de retorno en el proc sp_Num2Let
	******************************************************************************************************************************/
	CALL sp_Num2Let(:Monto, :Moneda, :MontoLetras);
	
	select 
		"Ref2" AS "NumLetra",
		'' AS "RefGirador", 
		'LIMA' AS "LugarGiro", 
		TO_VARCHAR("RefDate", 'mm/dd/yyyy') AS "FechaGiro", 
		TO_VARCHAR("DueDate", 'mm/dd/yyyy') AS "FechaVenc",
		"LocTotal" AS "MontoLetra", 
		:MontoLetras AS "TextoLetra", /***** Aqui hacemos uso de la variable que se cargo con el valor de retorno del proc "sp_Num2Let" *****/
		(select "CardName" from OCRD where "CardCode" = :CodSN) AS "Girado",	
		(select "Address" from OCRD where "CardCode" = :CodSN) AS "Domicilio",
		(select "LicTradNum" from OCRD where "CardCode" = :CodSN) AS "DOI",
		(select "Phone1" from OCRD where "CardCode" = :CodSN) AS "Telefono"

	from OJDT t0 where "TransId" = :Letra;

END;