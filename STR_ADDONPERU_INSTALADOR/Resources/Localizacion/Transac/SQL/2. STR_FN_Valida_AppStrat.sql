CREATE  FUNCTION STR_FN_Valida_AppStrat
(
@object_type AS NVARCHAR(20),
@transaction_type AS NVARCHAR(1),
@list_of_cols_val_tab_del nvarchar(255),
@TIPO AS VARCHAR(10)
)
RETURNS VARCHAR(200)
AS
BEGIN

DECLARE @R VARCHAR(200)
DECLARE @user VARCHAR(20)
DECLARE @R1 VARCHAR(30)
DECLARE @R2 VARCHAR(30)
DECLARE @R3 VARCHAR(30)
DECLARE @R4 VARCHAR(30)
DECLARE @R5 VARCHAR(30)
DECLARE @DOCTYPE NCHAR(1)




IF @TIPO = 'VENTAS'
BEGIN
	--FACTURA / NOTA DEBITO PROVEEDORES (OINV)
	IF @object_type = '13' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		-- Indicador de Factura
		SET @R1 = (SELECT count(*) FROM OINV T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD =''/* OR T0.U_BPP_MDTD <>'01'*/) and T0.DocSubType ='--'
		 AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		-- Indicador de Nota de Debito
		SET @R2 = (SELECT count(*) FROM OINV T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD =''/* OR T0.U_BPP_MDTD <>'08'*/)and  T0.DocSubType ='DN'
		AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		-- Indicador de Boleta
		SET @R3 = (SELECT count(*) FROM OINV T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD =''/*OR T0.U_BPP_MDTD <>'03'*/) and T0.DocSubType = 'IB' AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		--Tipo de Operacion	
		SET @DOCTYPE= (select A.DocType  from oinv A where A.docentry =@list_of_cols_val_tab_del )
		IF @DOCTYPE='I'	  
			
		SET @R4 = (SELECT count(*) FROM INV1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)

		
	IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
  IF @R2 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
  IF @R3 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
  IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END

	--OBJETO ENTREGA (ODLN)                   
	IF @object_type = '15' AND (@transaction_type = 'A' or @transaction_type = 'U')
		BEGIN
		-- Indicador de la Entrega
		SET @R1 = (SELECT count(*) FROM ODLN T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD ='' /*OR T0.Indicator <>'09'*/) AND T0.DocEntry = @list_of_cols_val_tab_del)

		--Valida el tipo de salida de documento
		DECLARE @DATA INT, @R6 INT, @R7 INT, @R8 INT, @R9 INT, @R10 INT
		
		SET @DATA = (SELECT count(*) FROM ODLN T0 WHERE  T0.U_BPP_Mdts='TSE'AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		IF @DATA >0
		BEGIN
		--Valida el Nombre de Transportista
		SET @R2 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDNT IS NULL OR T0.U_BPP_MDNT ='') AND T0.DocEntry = @list_of_cols_val_tab_del)
		--Valida el Direccion del Transportista
		SET @R3 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDDT IS NULL OR T0.U_BPP_MDDT ='') AND T0.DocEntry = @list_of_cols_val_tab_del)	
		--Valida el RUC del transportista
		SET @R4 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDRT IS NULL OR T0.U_BPP_MDRT ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		--Valida el Nombre del conductor
		SET @R5 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDFN IS NULL OR T0.U_BPP_MDFN ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		--Valida la Marca del vehiculo
		SET @R6 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDVN IS NULL OR T0.U_BPP_MDVN ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		--Valida la Licencia del conductor
		SET @R7 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDFC IS NULL OR T0.U_BPP_MDFC ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		--Valida la placa del Vehiculo
		SET @R8 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDVC IS NULL OR T0.U_BPP_MDVC ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		--Valida la Placa de la Tolva
		SET @R9 = (SELECT count(*) FROM ODLN T0 
					WHERE (T0.U_BPP_MDVT IS NULL OR T0.U_BPP_MDVT ='') AND T0.DocEntry = @list_of_cols_val_tab_del)			
		END
		
			--Tipo de Operacion	
		SET @DOCTYPE= (select A.DocType  from ODLN A where A.docentry =@list_of_cols_val_tab_del )
		IF @DOCTYPE='I'	  
			
		SET @R10 = (SELECT count(*) FROM DLN1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
			
		  IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
  IF @R2 > 0 BEGIN SET @r = 'STR_A: Ingrese el Nombre del Transportista' END
  IF @R3 > 0 BEGIN SET @r = 'STR_A: Ingrese la Dirección del Transportista' END
  IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese la RUC del Transportista' END
  IF @R5 > 0 BEGIN SET @r = 'STR_A: Ingrese la Nombre del transportista' END
  IF @R6 > 0 BEGIN SET @r = 'STR_A: Ingrese la Marca del vehiculo' END
  IF @R7 > 0 BEGIN SET @r = 'STR_A: Ingrese la Licencia del conductor' END
  IF @R8 > 0 BEGIN SET @r = 'STR_A: Ingrese la Placa del vehiculo' END
  IF @R9 > 0 BEGIN SET @r = 'STR_A: Ingrese Placa de la tolva' END
  IF @R10 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
		
	END                      

		--OBJETO NOTA DE CREDITO (ORIN) 
	IF @object_type = '14' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
			 -- Indicador de la Nota de Credito
				SET @R1 = (SELECT count(*) FROM ORIN T1 WHERE (T1.U_BPP_MDTD IS NULL OR T1.U_BPP_MDTD =''/* OR  T1.U_BPP_MDTD NOT IN ('07','ZA','01')*/) 
				and T1.Docentry=@list_of_cols_val_tab_del)
			--Tipo de Operacion	
				SET @DOCTYPE= (select A.DocType  from ORIN A where A.docentry =@list_of_cols_val_tab_del )
				IF @DOCTYPE='I'	  
			
				SET @R2 = (SELECT count(*) FROM RIN1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
				WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
				
				
			IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
			IF @R2 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END
	
		--OBJETO DEVOLUCION (ORDN) 
	IF @object_type = '16' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
			
			--Tipo de Operacion	
				SET @DOCTYPE= (select A.DocType  from ORDN A where A.docentry =@list_of_cols_val_tab_del )
				IF @DOCTYPE='I'	  
			
				SET @R2 = (SELECT count(*) FROM RDN1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
				WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
				
				 IF @R2 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END


END -- FIN VENTAS




IF @TIPO = 'COMPRAS'
BEGIN
	--FACTURA DE PROVEEDORES (OPCH)
	
	IF @object_type = '18' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		--Indicador de la Factura de Proveedor
		SET @R1 = (SELECT count(*) FROM OPCH T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD ='' /*OR T0.Indicator <>'01'*/) AND T0.DocEntry = @list_of_cols_val_tab_del)
		--Tipo de Operacion	
		SET @DOCTYPE= (select A.DocType  from OPCH A where A.docentry =@list_of_cols_val_tab_del )
		IF @DOCTYPE='I'	  
			
		SET @R4 = (SELECT count(*) FROM PCH1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
		IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END

	--NOTA DE CREDITO (ORPC)
	IF @object_type = '19' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		--Indicador de la Nota de Credito
		SET @R1 = (SELECT count(*) FROM ORPC T0 
		WHERE (T0.U_BPP_MDTD IS NULL OR T0.U_BPP_MDTD =''/* OR T0.U_BPP_MDTD <>'01'*/) AND T0.DocEntry = @list_of_cols_val_tab_del)
		--Tipo de Operacion	
		SET @DOCTYPE= (select A.DocType  from ORPC A where A.docentry =@list_of_cols_val_tab_del )
		IF @DOCTYPE='I'	  
			
		SET @R4 = (SELECT count(*) FROM RPC1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		  IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
			IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END
-----------------------------------------++++++++++++++++++++++++++++++++++++++++
		
	--Valida que se ingrese el indicador en Facturas de Anticipo Ventas
	IF @object_type = '203' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		SET @R1 = (select count(*) from ODPI T0
                  WHERE (T0.U_BPP_MDTD = '' or T0.U_BPP_MDTD IS NULL) AND T0.DocEntry =@list_of_cols_val_tab_del)
		 
		 IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe seleccionar el tipo de documento SUNAT' END
	END
	
	--Valida que se ingrese el indicador en Facturas de Anticipo Compras
	--IF @object_type = '204' AND (@transaction_type = 'A' or @transaction_type = 'U')
	--BEGIN
	--	SET @R1 = (select count(*) from ODPO T0
 --                 WHERE (T0.Indicator = '' or T0.Indicator IS NULL) AND T0.DocEntry =@list_of_cols_val_tab_del)
		 
	--	 IF @R1 > 0 BEGIN SET @r = 'STR_A: Ingrese Numero de Folio ( Serie y Numero de Documento) ' END
	--END
	
	
	
	--Valida que se ingrese la serie y el correlativo de documento si el indicador no empieza con "Z"
	IF @object_type = '18' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		SET @R1 = (select count(*) from OPCH T0
                  WHERE ((T0.U_BPP_MDSD = '' or T0.U_BPP_MDSD IS NULL) 
                  OR (T0.U_BPP_MDCD = '' or T0.U_BPP_MDCD IS NULL))
                  AND T0.DocEntry =@list_of_cols_val_tab_del
                  /*AND T0.U_BPP_MDTD NOT LIKE 'Z%'*/)
		 
		 IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe ingresar la serie y el número SUNAT' END
	END
	
	--Valida DUA
	IF @object_type = '18' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		SET @R1 = (select count(*) from OPCH T0
                  WHERE ((T0.U_BPP_MDND = '' or T0.U_BPP_MDND IS NULL) 
                  OR (T0.U_BPP_MDFD = '' or T0.U_BPP_MDFD IS NULL))
                  AND T0.DocEntry =@list_of_cols_val_tab_del
                  AND T0.U_BPP_MDTD = '50')
		
		  IF @R1 > 0 BEGIN SET @r = 'STR_A: Ingrese los datos de DUA' END
	END
    
    --Valida que se ingrese la serie y el correlativo de documento si el indicador no empieza con "Z"
	IF @object_type = '204' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		SET @R1 = (select count(*) from ODPO T0
                  WHERE ((T0.U_BPP_MDSD = '' or T0.U_BPP_MDSD IS NULL) 
                  OR (T0.U_BPP_MDCD = '' or T0.U_BPP_MDCD IS NULL))
                  AND T0.DocEntry =@list_of_cols_val_tab_del
                  /*AND T0.U_BPP_MDTD NOT LIKE 'Z%'*/)
		
		IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe ingresar la serie y el número SUNAT' END
	END
	
	--Valida DUA
	IF @object_type = '204' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		SET @R1 = (select count(*) from ODPO T0
                  WHERE ((T0.U_BPP_MDND = '' or T0.U_BPP_MDND IS NULL) 
                  OR (T0.U_BPP_MDFD = '' or T0.U_BPP_MDFD IS NULL))
                  AND T0.DocEntry =@list_of_cols_val_tab_del
                  AND T0.U_BPP_MDTD = '50')
		
		IF @R1 > 0 BEGIN SET @r = 'STR_A: Ingrese los datos de DUA' END
	END
-----------------------------------------+++++++++++++++++++++++++++++++++++++++++

END -- FIN COMPRAS

IF @TIPO = 'INVENTARIO'
BEGIN



--OBJETO ENTRADA (OIGN) 
	IF @object_type = '59' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		--Tipo de Operacion	
		SET @R4 = (SELECT count(*) FROM IGN1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		
		IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END

--OBJETO SALIDA (OIGE)
	IF @object_type = '60' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
		--Tipo de Operacion	
		SET @R4 = (SELECT count(*) FROM IGE1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	END
	--OBJETO TRANSFERENCIA DE STOCK (OWTR)
	IF @object_type = '67' AND (@transaction_type = 'A' or @transaction_type = 'U')
	BEGIN
			--Tipo de Operacion	
		SET @R4 = (SELECT count(*) FROM WTR1  T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
		WHERE ((T0.U_tipoOpT12 IS NULL OR T0.U_tipoOpT12 ='') and t1.InvntItem='Y' ) AND T0.DocEntry = @list_of_cols_val_tab_del)
		
		  IF @R4 > 0 BEGIN SET @r = 'STR_A: Ingrese el Tipo de Operacion en el detalle del documento' END
	
	END


END -- FIN INVENTARIO

RETURN @R
--return @object_type

END

