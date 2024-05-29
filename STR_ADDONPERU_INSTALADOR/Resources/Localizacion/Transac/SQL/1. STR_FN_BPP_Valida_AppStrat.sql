CREATE FUNCTION [dbo].[STR_FN_BPP_Valida_AppStrat]
(
--- VALIDACIONES PARA EL ADDON DE STRAT
@object_type AS NVARCHAR(20),
@transaction_type AS NVARCHAR(1),
@list_of_cols_val_tab_del nvarchar(255),
@TIPO AS VARCHAR(50)
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
		  DECLARE @TIPODOC NVARCHAR(10)

	--VALIDA  que se ingrese tipo,serie,correlativo y fecha de DUAS para sujeto no DOMICILIADO
	  SET @TIPODOC = (SELECT U_BPP_MDTD FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del)
	   IF @TIPODOC = '91'
	  begin
			SET @R1 = (select count(*) from OPCH T0
                  WHERE ((T0.U_BPP_MDND = '' OR T0.U_BPP_MDND IS NULL) 
                  OR (T0.U_BPP_MDFD = '' OR T0.U_BPP_MDFD IS NULL)
				  OR (T0.U_STR_TipoDua = '' OR T0.U_STR_TipoDua IS NULL)
				  OR (T0.U_STR_SerieDua = '' OR T0.U_STR_SerieDua IS NULL))
                  AND T0.DocEntry =@list_of_cols_val_tab_del)
                 -- AND T0.U_BPP_MDTO IN ('50','52') 
				 END 
			IF @R1 > 0 BEGIN SET @r = 'STR_A: Debe ingresar Tipo, Numero, serie, fecha, DUA' END


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

IF @TIPO = 'FACT_ELECTRONICA'
BEGIN
	DECLARE @MultiItemCode VARCHAR(500)
	DECLARE	
			@NumAtCard		nvarchar(100)
		,	@CardCode		nvarchar(20)
		,	@DocEntry		int
		,	@U_BPP_MDTD		nvarchar(2)
		,	@U_BPP_MDSD		nvarchar(4)
		,	@U_BPP_MDCD		nvarchar(50)
		,	@U_BPP_CdBn		nvarchar(30)
		,	@U_BPP_CdOp		nvarchar(30)
		,   @U_STR_MtvoCD   nvarchar(15)
		,	@U_STR_ObtEst   nvarchar(15)
		,	@U_STR_ESTOTOR  nvarchar(15)
		,	@U_BPP_MDTO		nvarchar(2)
		,	@U_BPP_MDSO		nvarchar(4)
		,	@U_BPP_MDCO		nvarchar(50)
		,   @Comments		nvarchar(100)
		,   @DocSubType     char(4)
		,   @U_STR_AfctoDtr char(4)
		,   @U_STR_TazaDTR  int
		,   @U_STR_CodBnSs  char(4)
		,   @U_BPP_OPER     char(10)
		,   @DocCurr        char(10)
		,	@U_tipoOpT12    nvarchar(30)
		,	@U_BPP_PRCVAR   nvarchar(10)
		,   @FormaPago      int
		,   @Installmnt     int
		,	@CondicionPago	int

	--Variables de detalle
		,	@VisOrder		int
		,	@cont			int
		,	@ItemCode		nvarchar(30)
		,	@BaseType		int
		,	@BaseEntry		int
		,   @U_STR_FECodAfect nvarchar(50)


			
IF @object_type = '13' AND (@transaction_type = 'A' or @transaction_type = 'U')
       BEGIN
           
				SELECT	@NumAtCard		= f.NumAtCard
					,	@CardCode		= f.CardCode
					,	@DocEntry		= f.DocEntry
					,	@U_BPP_MDTD		= f.U_BPP_MDTD
					,	@U_BPP_MDSD		= f.U_BPP_MDSD
					,	@U_BPP_MDCD		= f.U_BPP_MDCD
					,	@U_STR_ObtEst	= f.U_STR_ObtEst
					,	@U_STR_ESTOTOR	= f.U_STR_ESTOTOR
					,   @DocSubType		= f.DocSubType
					,   @U_STR_MtvoCD   = f.U_STR_MtvoCD
					,   @U_STR_AfctoDtr = f.U_STR_AfctoDtr
					,   @U_STR_TazaDTR  = f.U_STR_TazaDTR
					,   @U_STR_CodBnSs  = f.U_STR_CodBnSs
					,	@U_BPP_MDTO		= f.U_BPP_MDTO
					,	@U_BPP_MDSO		= f.U_BPP_MDSO
					,	@U_BPP_MDCO		= f.U_BPP_MDCO
					,   @Comments		=  f.Comments
					,   @DocCurr        = f.DocCur
					,   @FormaPago      = f.U_STR_FE_FormaPago
					,   @Installmnt     = f.Installmnt
					,	@CondicionPago	= f.GroupNum
   				FROM	OINV f with(nolock) WHERE	f.DocEntry = @list_of_cols_val_tab_del
		
				SELECT
						@BaseType   = f.BaseType
					,	@BaseEntry	= f.BaseEntry
					,   @U_STR_FECodAfect = f.U_STR_FECodAfect
					,   @U_BPP_OPER     = f.U_BPP_OPER
					,	@U_tipoOpT12 = f.U_tipoOpT12
					,	@U_BPP_PRCVAR = f.U_BPP_PRCVAR
				FROM	INV1 f with(nolock)
				WHERE	f.DocEntry = @list_of_cols_val_tab_del  
				  
		/*Correo Electronico SN */
				IF (SELECT COUNT('A') FROM OCRD T0 WHERE T0.CardCode= @CardCode AND ISNULL(T0.E_Mail,'')='' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') ) > 0 
					BEGIN 
						 SET @R = 'STR_A: El Socio de Negocio no cuenta con el Correo electronico' 
						RETURN @R
				END 

		/* Socio de Negocio: Valida el correo electronico cuando el campo Position sea "Y" */
				IF (SELECT COUNT('A') FROM OCPR T0 WHERE ISNULL(T0.Position,'') = 'Y' AND T0.CardCode= @CardCode AND ISNULL(T0.E_MailL,'') = '' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') ) > 0 
					BEGIN 
						 SET @R = 'STR_A: Ingrese el Correo electronico de persona de contacto' 
						RETURN @R
				END 

		
		/*RUC y/o DNI del SN */



		/*Configuracion de la Moneda PEN, USD */
				IF (SELECT COUNT('A') FROM OCRN T0 WHERE T0.CurrCode= @DocCurr AND ISNULL(T0.ISOCurrCod,'')='' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') ) > 0 
					BEGIN 
						 SET @R = 'STR_A: Debe configurar la moneda para la Facturación Electrónica' 
						RETURN @R
				END

	
		/* Datos del Documento de Origen*/
				IF @DocSubType='DN' 
					BEGIN 
					IF (ISNULL(@U_BPP_MDTO,'')='' AND ISNULL(@U_BPP_MDSO,'')='' AND ISNULL(@U_BPP_MDCO,'')='' AND LEFT(@U_BPP_MDSD,1) IN ('F','B')) 
						BEGIN 
							SET @R = 'STR_A: Ingrese los datos del documento origen '
							RETURN @R
					END 
			
			 

		/*Debe existir el documento de origen creado*/
	 
			IF  @DocSubType='DN' AND LEFT(@U_BPP_MDSO, 1) IN ('F', 'B') AND @U_BPP_MDSD!='999'
				BEGIN 
				SET @R4 = (SELECT COUNT('A') FROM OINV T0 WHERE  T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND T0.CardCode=@CardCode AND  LEFT(@U_BPP_MDSD,1) IN ('F','B','9'))
				
			
					IF @R4 = 0 BEGIN
						SET @R = 'STR_A: No se ha creado el numero el documento origen ' + ISNULL(@U_BPP_MDTO,'')+'-'+ ISNULL( @U_BPP_MDSO,'')+'-'+ ISNULL( @U_BPP_MDCO,'')
						RETURN 	@R
					END
				
				SET @R5 = (SELECT COUNT('A') FROM OINV T0 WHERE  T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND LEFT(@U_BPP_MDSO, 1) IN ('F', 'B') AND  (LEFT(T0.U_BPP_MDSD,1)!=LEFT(@U_BPP_MDSD,1) )  )
				  
					IF @R5 > 0 
					BEGIN
						SET @R = 'STR_A: La serie de la ND debe corresponder al documento de origen' -- + ISNULL(@U_BPP_MDTO,'')+'-'+ ISNULL( @U_BPP_MDSO,'')+'-'+ ISNULL( @U_BPP_MDCO,'')+'-'  + ISNULL(@U_BPP_MDTD,'')+'-'+ ISNULL( @U_BPP_MDSD,'')+'-'+ ISNULL( @U_BPP_MDCD,'') + ' ' + cast(@r5 as nvarchar(5))
						RETURN @R
					END
				END 
			END 
			
		/*El usuario debe seleccionar si el documento esta afecto o no a detracción*/
				IF (ISNULL(@U_STR_AfctoDtr,'N')='Y' AND ISNULL(@U_STR_TazaDTR,0)=0 AND LEFT(@U_BPP_MDSD,1) ='F')
					BEGIN 
						SET @R = 'STR_A: Debe ingresar la tasa de detraccion'
						RETURN @R
				END 
		
		/*Si esta afecto a detracción se debe asignar la taza y código de bien.*/
			   IF (ISNULL(@U_STR_AfctoDtr,'N')='Y' AND  ISNULL(@U_STR_CodBnSs,'')=''  )
 					BEGIN 
 					
					SET @R = 'STR_A: Debe ingresar el codigo de bien y/o servicio'
					RETURN @R
		      END 


		/*Debe ingresar el tipo de venta*/
			IF (SELECT COUNT('A') FROM INV1 T0  INNER JOIN OINV T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T0.U_BPP_OPER,'-') = '-' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')) > 0
			BEGIN
				SET @R = 'STR_A: Debe ingresar el tipo de venta'
				RETURN @R
			END


		/*Debe ingresar el tipo de venta*/
		/*
			IF (SELECT COUNT('A') FROM INV1 T0  INNER JOIN OINV T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T0.U_tipoOpT12,'') = '' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')) > 0
			BEGIN
				SET @R = 'STR_A: Debe ingresar el tipo de operación'
				RETURN @R
			END
        */

		/*Debe ingresar el tipo de venta*/
			IF (SELECT COUNT('A') FROM INV1 T0  INNER JOIN OINV T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T0.U_STR_FECodAfect,'') = '' AND T0.DocEntry = @DocEntry AND LEFT(T2.U_BPP_MDSD,1) IN ('F','B')) > 0
			BEGIN
				SET @R = 'STR_A: Debe ingresar el código Afecto Igv'
				RETURN @R
			END

				
		/*Ingresar la la venta se encuentra afecto a detraccion*/
                IF (ISNULL(@U_STR_AfctoDtr,'')=''  AND   @object_type=13 and LEFT(@U_BPP_MDSD,1) IN ('F','B'))
					BEGIN 
					SET @R = 'STR_A: Verificar si el documento se encuentra afecto a detracción' 
						RETURN @R
				END
		
		


        /*Ingresar el sustento del documento a crear*/
				IF	(ISNULL(@Comments,'')=''and @object_type=13 AND LEFT(@U_BPP_MDSD,1) IN ('F','B') AND @DocSubType='DN')
					 BEGIN 
						SET @R = 'STR_A: Ingrese el sustento de la nota de debito'
						RETURN @R
				END   
    
        	
		/*Se debe seleccionar el motivo para las NC o ND. Según catalogo SUNAT*/
				IF	 (ISNULL(@U_STR_MtvoCD,'')!=  ISNULL((SELECT TOP 1 U_STR_Codigo FROM "@STR_FE_MtvNCND" T  WHERE T.U_STR_Codigo=@U_STR_MtvoCD),0) and @object_type=13 AND LEFT(@U_BPP_MDSD,1) IN ('F','B') AND @DocSubType='DN')
					 BEGIN 
						SET @R = 'STR_A: Dbe ingresar el motivo del catálogo'
						RETURN @R
				END   

		/*El documento Boleta origen debe estar otorgado*/
		if @DocSubType='DN' AND LEFT(@U_BPP_MDSO, 1) IN ('F', 'B')
		BEGIN
		SET @R2 = (SELECT COUNT('A') FROM OINV T0 WHERE T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO   
		  AND ISNULL(T0.U_STR_ESTOTOR,'N')='N' and T0.U_BPP_MDTD='03' and LEFT(@U_BPP_MDSD,1) IN ('F','B'))
				IF @R2 > 0 
					BEGIN
						SET @R = 'STR_A: La ND no se puede crear debido que Doc: '+@U_BPP_MDTO+'-'+@U_BPP_MDSO+'-'+@U_BPP_MDCO +' no esta  otorgado' 
						RETURN @R
				END
				
		/*El documento Factura origen debe estar otorgado*/
		SET @R3 = (SELECT COUNT('A') FROM OINV T0 WHERE T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO  
		 AND (ISNULL(T0.U_STR_ObtEst ,1)=1 OR  ISNULL(T0.U_STR_ESTOTOR,'N')='N') and T0.U_BPP_MDTD='01'  and LEFT(@U_BPP_MDSD,1) IN ('F','B'))
				IF @R3 > 0 
					BEGIN
						SET @R = 'STR_A: La ND no se puede crear debido que Doc: '+@U_BPP_MDTO+'-'+@U_BPP_MDSO+'-'+@U_BPP_MDCO +'  no esta aprobado y/o otorgado ' 
						RETURN @R
				END

		END
		
		SELECT @MultiItemCode = COALESCE(@MultiItemCode + ', ', '') + T0.ItemCode FROM INV1 T0 INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode INNER JOIN OINV T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T1.SalUnitMsr,'') = '' AND T2.DocType = 'I' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')
		IF ISNULL(@MultiItemCode,'') != ''
		BEGIN
			SET @R = 'STR_A: El artículo no cuenta con la unidad de medida: ' + @MultiItemCode
			RETURN @R
		END

		--SELECT @MultiItemCode = COALESCE(@MultiItemCode + ', ', '') + T0.ItemCode FROM INV1 T0 INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode INNER JOIN OINV T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T1.SWW,'') = '' AND T2.DocType = 'I' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')
		--IF ISNULL(@MultiItemCode,'') != '' 
		--BEGIN 
		--	SET @R = 'STR_A: El artículo no cuenta con la unidad de medida adicional (ID adicional): ' + @MultiItemCode
		--	RETURN @R
		--END


		  /* ############   NUEVAS VALIDACIONES PARA FACTURA ELECTRONICA - CAMBIOS SEGUN LA RESOLUCION 193-2020   ############### */

		/*Verifica que la Forma de Pago tenga seleccionada Contado o Crédito*/
                IF @FormaPago IS NULL --= 1  AND  @Installmnt > 1
					BEGIN 
					SET @R = 'STR_A: Debe seleccionar la Forma de Pago Sunat (Contado o Crédito).' 
						RETURN @R
				END

		/*Si la forma de pago es contado, la condicion de pago también lo debe ser*/
                IF @FormaPago = 1  AND  @CondicionPago != -1
					BEGIN 
					SET @R = 'STR_A: La forma de pago es "Contado", la condición de pago no puede ser a crédito.' 
						RETURN @R
				END

		/*Verifica que la venta al Contado no tenga Cuotas*/
                IF @FormaPago = 1  AND  @Installmnt > 1
					BEGIN 
					SET @R = 'STR_A: Una venta al contado no puede tener cuotas.' 
						RETURN @R
				END

	END --FIN OBETO 13




	IF @object_type = '14' AND (@transaction_type = 'A' or @transaction_type = 'U')
      BEGIN

				SELECT	@NumAtCard		= f.NumAtCard
					,	@CardCode		= f.CardCode
					,	@DocEntry		= f.DocEntry
					,	@U_BPP_MDTD		= f.U_BPP_MDTD
					,	@U_BPP_MDSD		= f.U_BPP_MDSD
					,	@U_BPP_MDCD		= f.U_BPP_MDCD
					,	@U_BPP_CdBn		= f.U_BPP_CdBn
					,	@U_BPP_CdOp		= f.U_BPP_CdOp
					,   @U_STR_MtvoCD   = f.U_STR_MtvoCD
					,	@U_STR_ObtEst	= f.U_STR_ObtEst
					,	@U_STR_ESTOTOR	= f.U_STR_ESTOTOR
					,	@U_BPP_MDTO		= f.U_BPP_MDTO
					,	@U_BPP_MDSO		= f.U_BPP_MDSO
					,	@U_BPP_MDCO		= f.U_BPP_MDCO
					,   @Comments		= F.Comments
				FROM	ORIN f with(nolock)
				WHERE	f.DocEntry = @list_of_cols_val_tab_del
			  
				SELECT
						@BaseType   = f.BaseType
					,	@BaseEntry	= f.BaseEntry
					,   @U_STR_FECodAfect =f.U_STR_FECodAfect
					,   @U_BPP_OPER     = f.U_BPP_OPER
				FROM	RIN1 f with(nolock)
				WHERE	f.DocEntry = @list_of_cols_val_tab_del       
    
    
	/*Correo Electronico SN */
				IF (SELECT COUNT('A') FROM OCRD T0 WHERE T0.CardCode= @CardCode AND ISNULL(T0.E_Mail,'')='' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') ) > 0 
					BEGIN 
						 SET @R = 'STR_A: El Socio de Negocio no cuenta con el Correo electronico' 
						RETURN @R
				END 

		/* Socio de Negocio: Valida el correo electronico cuando el campo Position sea "Y" */
				IF (SELECT COUNT('A') FROM OCPR T0 WHERE ISNULL(T0.Position,'') = 'Y' AND T0.CardCode= @CardCode AND ISNULL(T0.E_MailL,'') = '' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') ) > 0 
					BEGIN 
						 SET @R = 'STR_A: Ingrese el Correo electronico de persona de contacto' 
						RETURN @R
				END 

	/*Configuracion de la Moneda PEN, USD */
				IF (SELECT COUNT('A') FROM OCRN T0 WHERE T0.CurrCode= @DocCurr AND ISNULL(T0.ISOCurrCod,'')='' AND  LEFT(@U_BPP_MDSD,1) IN ('F','B') )>0 
					BEGIN 
						 SET @R = 'STR_A: Debe configurar la moneda para la Facturación Electrónica' 
						RETURN @R
				END
    
		/*Valida que el tipo de documento se igual a origen*/
			
	
				IF (SELECT TOP 1 LEFT(T0.U_BPP_MDSD,1) FROM OINV T0 WHERE T0.ObjType = @BaseType AND T0.DocEntry = @BaseEntry) = LEFT(@U_BPP_MDSD,1)
				BEGIN
					SET @R1 = (SELECT COUNT ('A') FROM OINV T0 WHERE T0.ObjType=@BaseType AND T0.DocEntry = @BaseEntry AND (LEFT(T0.U_BPP_MDSD,1) != LEFT(@U_BPP_MDSD,1)) AND @U_BPP_MDTD = '07')
						IF @R1 > 0 
						BEGIN
							SET @R = 'STR_A: La serie de la NC debe corresponder al documento de origen' 
							RETURN @R
						END
					
					SET @R7 = (SELECT COUNT('A') FROM OINV T0 WHERE  T0.U_BPP_MDTD = @U_BPP_MDTO AND T0.U_BPP_MDSD = @U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND (LEFT(T0.U_BPP_MDSD,1)!=LEFT(@U_BPP_MDSD,1)) AND @U_BPP_MDTD = '07')
				  
						IF @R7 > 0 
						BEGIN
							SET @R = 'STR_A: La serie de la NC debe corresponder al documento de origen' 
							RETURN @R
						END
			   END
					
		/*Se debe seleccionar el motivo para las NC o ND. Según catalogo SUNAT*/
				/*IF ISNULL(@U_STR_MtvoCD,'')!= ISNULL((SELECT top 1 U_STR_Codigo FROM "@STR_FE_MtvNCND" T  WHERE T.U_STR_Codigo=@U_STR_MtvoCD),0) AND  LEFT(@U_BPP_MDSD,1) IN ('F','B')  AND  @object_type=14
					BEGIN 
						SET @R = 'STR_A: Debe ingresar el motivo del catálogo '
						RETURN @R
					END */
				
		/*Solo se puede anular un Documento Factura si este cuenta con CDR Rechazado o es parte de un Comunicado de Bajas.*/
			
			IF (SELECT TOP 1 LEFT(T0.U_BPP_MDSD,1) FROM OINV T0 WHERE T0.ObjType = @BaseType AND T0.DocEntry = @BaseEntry) = LEFT(@U_BPP_MDSD,1)
			BEGIN
				SET @R2 = (SELECT COUNT ('A') FROM OINV T0 WHERE T0.ObjType=@BaseType AND T0.DocEntry=@BaseEntry AND  (ISNULL(T0.U_STR_ObtEst ,1)=1 OR  ISNULL(T0.U_STR_ESTOTOR,'N')='N') AND LEFT(T0.U_BPP_MDSD,1) = 'F'  AND T0.U_BPP_MDTD='01' )
				      
					IF @R2 > 0 
						BEGIN
							SET @R = 'STR_A: La NC no se puede crear debido que Doc: '+(SELECT T0.U_BPP_MDTD+'-'+T0.U_BPP_MDSD+'-'+T0.U_BPP_MDCD  FROM OINV T0 WHERE T0.ObjType=@BaseType AND T0.DocEntry=@BaseEntry)+'  no esta aprobado y/o otorgado' 
							RETURN @R
						END
			
			
				
				SET @R3 = (SELECT COUNT('A') FROM OINV T0 WHERE  T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND  (ISNULL(T0.U_STR_ObtEst ,1)=1 OR  ISNULL(T0.U_STR_ESTOTOR,'N')='N')  AND  T0.U_BPP_MDTD='01' AND T0.CardCode=@CardCode AND @BaseType=-1 )
				
					IF @R3 > 0 
						BEGIN
							SET @R = 'STR_A: La NC no se puede crear debido que Doc: '+(SELECT ISNULL(T0.U_BPP_MDTD,'')+'-'+ISNULL(T0.U_BPP_MDSD,'')+'-'+ISNULL(T0.U_BPP_MDCD,'')  FROM OINV T0 WHERE T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND ISNULL(T0.U_STR_ObtEst ,1)=1 AND T0.U_BPP_MDTD='01'   )+'  no esta aprobado y/o otorgado' 
							RETURN @R
						END
			END

	  /* Datos del Documento de Origen*/
	  			IF ISNULL(@U_BPP_MDTO,'')='' AND ISNULL(@U_BPP_MDSO,'')='' AND ISNULL(@U_BPP_MDCO,'')='' AND @BaseType=-1 AND LEFT(@U_BPP_MDSD,1) IN ('F','B') AND   @object_type=14
					BEGIN 
						sET @R = 'STR_A: Ingrese los datos del documento origen'
						RETURN @R
					END 


		/*Debe ingresar el tipo de venta*/
			IF (SELECT COUNT('A') FROM RIN1 T0  INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T0.U_BPP_OPER,'-') = '-' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')) > 0
			BEGIN
				SET @R = 'STR_A: Debe ingresar el tipo de venta'
				RETURN @R
			END


		/*Debe ingresar el tipo de venta*/
			IF (SELECT COUNT('A') FROM RIN1 T0  INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T0.U_STR_FECodAfect,'') = '' AND T0.DocEntry = @DocEntry AND LEFT(T2.U_BPP_MDSD,1) IN ('F','B')) > 0
			BEGIN
				SET @R = 'STR_A: Debe ingresar el código Afecto Igv'
				RETURN @R
			END

		
	  /*Ingresar el sustento del documento a crear*/
					IF	(ISNULL(@Comments,'')='' AND @object_type=14 AND LEFT(@U_BPP_MDSD,1) IN ('F','B'))
					 BEGIN 
						SET @R = 'STR_A: Ingrese el sustento de la nota de credito'
						RETURN @R
					 END
				
	 /*Debe existir el documento de origen creado*/
	 
			IF @BaseType=-1 and LEFT(@U_BPP_MDSD,1) IN ('F','B') and LEFT(@U_BPP_MDSO,1) IN ('F','B')
				BEGIN 
				SET @R4 = (SELECT COUNT(*) FROM OINV T0 WHERE  T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND T0.CardCode=@CardCode)
				
			
				IF @R4 = 0 BEGIN
						SET @R = 'STR_A: No se ha creado el numero el documento '+	 ISNULL(@U_BPP_MDTO,'')+'-'+ ISNULL( @U_BPP_MDSO,'')+'-'+ ISNULL( @U_BPP_MDCO,'')
						RETURN 	@R
					END
			END 
		
			
	/*Solo se puede anular un Documento Boleta () si este cuenta con CDR Rechazado o es parte de un Comunicado de Bajas.*/	
			
		SET @R5 = (SELECT COUNT ('A') FROM OINV T0 WHERE T0.ObjType=@BaseType AND T0.DocEntry=@BaseEntry AND ISNULL(T0.U_STR_ESTOTOR,'N')='N' AND T0.U_BPP_MDSD = '999' AND  (LEFT(T0.U_BPP_MDSD,1) = 'B'  AND T0.U_BPP_MDTD = '03'))
				IF @R5 > 0 
					BEGIN
							SET @R = 'STR_A: La NC no se puede crear debido que Doc: '+(SELECT T0.U_BPP_MDTD+'-'+T0.U_BPP_MDSD+'-'+T0.U_BPP_MDCD  FROM OINV T0 WHERE T0.ObjType=@BaseType AND T0.DocEntry=@BaseEntry)+'  no esta  otorgado' 
						RETURN @R
					END

		SET @R6 = (SELECT COUNT('A') FROM OINV T0 WHERE  T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND ISNULL(T0.U_STR_ESTOTOR,'N')='N' AND T0.U_BPP_MDSD = '999' AND T0.U_BPP_MDTD='03' AND T0.CardCode=@CardCode AND @BaseType=-1 )
				IF @R6 > 0 
					BEGIN
						SET @R = 'STR_A: La NC no se puede crear debido que Doc: '+(SELECT ISNULL(T0.U_BPP_MDTD,'')+'-'+ISNULL(T0.U_BPP_MDSD,'')+'-'+ISNULL(T0.U_BPP_MDCD,'')  FROM OINV T0 WHERE T0.U_BPP_MDTD =@U_BPP_MDTO AND T0.U_BPP_MDSD=@U_BPP_MDSO AND T0.U_BPP_MDCD=@U_BPP_MDCO AND ISNULL(T0.U_STR_ObtEst ,1)=1 AND T0.U_BPP_MDTD='03'   )+'  no esta  otorgado' 
						RETURN @R
					END


		SELECT @MultiItemCode = COALESCE(@MultiItemCode + ', ', '') + T0.ItemCode FROM RIN1 T0 INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T1.SalUnitMsr,'') = '' AND T2.DocType = 'I' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')
		IF ISNULL(@MultiItemCode,'') != ''
		BEGIN
			SET @R = 'STR_A: El artículo no cuenta con la unidad de medida: ' + @MultiItemCode
			RETURN @R
		END

		--SELECT @MultiItemCode = COALESCE(@MultiItemCode + ', ', '') + T0.ItemCode FROM RIN1 T0 INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE ISNULL(T1.SWW,'') = '' AND T2.DocType = 'I' AND T0.DocEntry = @DocEntry AND LEFT(@U_BPP_MDSD,1) IN ('F','B')
		--IF ISNULL(@MultiItemCode,'') != '' 
		--BEGIN 
		--	SET @R = 'STR_A: El artículo no cuenta con la unidad de medida adicional (ID adicional): ' + @MultiItemCode
		--	RETURN @R
		--END
		
	 END -- OBJETO 14


	 /* Socio de Negocio: Valida el correo electronico de Persona de Contacto cuando el campo Position sea "Y" */
	   IF @object_type = '2' AND (@transaction_type = 'A' or @transaction_type = 'U')
       BEGIN
			SET @R1 = (SELECT COUNT(*) FROM OCPR  T0  WHERE T0.Position = 'Y' AND ISNULL(T0.E_MailL,'') = '' AND T0.CardCode = @list_of_cols_val_tab_del)
			
			IF @R1 > 0 
			BEGIN 
				SET @R = 'STR_A: Ingrese el Correo electrónico de persona de contacto.' 
				RETURN @R
			END
       END

	   /* Socio de Negocio: La unidad de medida adicional */
	  -- IF @object_type = '4' AND (@transaction_type = 'A' or @transaction_type = 'U')
	  -- BEGIN
			--SET @R1 = (SELECT COUNT(*) FROM OITM  T0  WHERE ISNULL(T0.SWW,'') = '' AND T0.ItemCode = @list_of_cols_val_tab_del)
			
			--IF @R1 > 0 
			--BEGIN 
			--	SET @R = 'STR_A: Ingrese la unidad de medida adicional(ID adicional).' 
			--	RETURN @R
			--END
   --    END


   /* ############   NUEVAS VALIDACIONES PARA FACTURA ELECTRONICA - CAMBIOS SEGUN LA RESOLUCION 193-2020   ############### */
   
   
      /* Nota de crédito Especial: Valida el que el motivo 13 no se aplique a una factura al contado */
	            IF  (SELECT U_STR_FE_FormaPago FROM OINV WHERE U_BPP_MDTD = @U_BPP_MDTO AND  U_BPP_MDSD = @U_BPP_MDSO AND U_BPP_MDCD = @U_BPP_MDCO) = 1 AND  @U_STR_MtvoCD = '13'
					BEGIN
						SET @R = 'STR_A: No puede aplicar una NC Especial (Motivo 13) a una factura al contado.' 
						RETURN @R
					END

	  /* Nota de crédito Especial: Valida el que el motivo 13 Tenga valor Total 0.00*/
	            IF  (SELECT DocTotal FROM ORIN WHERE DocEntry = @DocEntry) <> 0 AND  @U_STR_MtvoCD = '13'
					BEGIN
						SET @R = 'STR_A: No puede aplicar una NC Especial (Motivo 13) con valor total mayor a 0.' 
						RETURN @R
					END

	  /* Nota de crédito Especial: Valida el que el motivo 13 Tenga indicador EXO (Exonerado) */
	            IF  (SELECT COUNT('A') FROM RIN1 T0 INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE T0.DocEntry = @DocEntry AND LEFT(T0.TaxCode,3) <> 'EXO') > 0 AND  @U_STR_MtvoCD = '13'
					BEGIN
						SET @R = 'STR_A: No puede aplicar una NC Especial (Motivo 13) con indicador diferente a EXO (Exonerado).' 
						RETURN @R
					END

	   /* Nota de crédito Especial: Valida el que el motivo 13 Tenga Tipo de venta E (Exonerado) */
	            IF  (SELECT COUNT('A') FROM RIN1 T0 INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE T0.DocEntry = @DocEntry AND T0.U_BPP_OPER <> 'E') > 0 AND  @U_STR_MtvoCD = '13'
					BEGIN
						SET @R = 'STR_A: No puede aplicar una NC Especial (Motivo 13) con tipo de venta diferente a E (Exonerado).' 
						RETURN @R
					END

	   /* Nota de crédito Especial: Valida el que el motivo 13 Tenga Codigo de Afectación 20 (Exonerado - Operación Onerosa) */
	            IF  (SELECT COUNT('A') FROM RIN1 T0 INNER JOIN ORIN T2 ON T2.DocEntry = T0.DocEntry WHERE T0.DocEntry = @DocEntry AND T0.U_STR_FECodAfect  <> '20') > 0 AND  @U_STR_MtvoCD = '13'
					BEGIN
						SET @R = 'STR_A: No puede aplicar una NC (Motivo 13) con codigo de afectación diferente a 20 (Exonerado - Operación Onerosa).' 
						RETURN @R
					END


END -- FIN FACTURA ELECTRONICA

RETURN @R
--return @object_type

END