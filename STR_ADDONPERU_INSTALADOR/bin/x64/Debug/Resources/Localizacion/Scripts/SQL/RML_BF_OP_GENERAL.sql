CREATE PROCEDURE RML_BF_OP_GENERAL
	@Objeto		nvarchar(30),
	@NumeroBF	nVarchar(6),/* Elige la busqueda formateada que se desea ejecutar. 
						       Para futuras implementaciones se debe agregar las nuevas condiciones en un numerál distinto.
						  	*/
	@Param01	NUMERIC,
	@Param02	nVarchar(100),
	@Param03	nVarchar(100),
	@Param04	nVarchar(100),
	@Param05	nVarchar(100),
	@Param06	nVarchar(100)
AS
BEGIN
	DECLARE @MONTO1  NUMERIC
    DECLARE @MONTO2  NUMERIC	
    DECLARE @MAXCODITEM01	NVARCHAR(50) 
	DECLARE @NEXTCODITEM01	NVARCHAR(50) 
	DECLARE @FINALCOD01      NVARCHAR(50)
	DECLARE @MAXCODITEM02	NVARCHAR(50) 
	DECLARE @NEXTCODITEM02	NVARCHAR(50) 
	DECLARE @FINALCOD02      NVARCHAR(50)
	DECLARE @MAXCODITEM03	NVARCHAR(50) 
	DECLARE @NEXTCODITEM03	NVARCHAR(50) 
	DECLARE @FINALCOD03      NVARCHAR(50)
	DECLARE @COINI           NVARCHAR(50)
    DECLARE @TipoSAPDocumentoOrigen 	NVARCHAR(3) 
	DECLARE @TipoPersona				NVARCHAR(10)

		
/******************************************************************************************************************/

    --Búsqueda formateada que trae las unidades de Medida de SAP, se han asignado al MAESTRO DE ARTICULOS
	
	-- CALL "RML_BF_OP_GENERAL" ('01','01','0','','','','','')	
	IF (@Objeto = '01' AND @NumeroBF = '01' )
	BEGIN
	SELECT "UomCode" ,"UomName" FROM OUOM
	END


/******************************************************************************************************************/

    --Búsqueda formateada que trae ZONAS, se han asignado al MAESTRO DE SOCIOS DE NEGOCIO
	
	-- CALL "RML_BF_OP_GENERAL" ('01','02','0','','','','','')	
	IF (@Objeto = '01' AND @NumeroBF = '02') 
	BEGIN
	SELECT  "Code","U_RML_TERRI","U_RML_NOMTERRI"  FROM "@RML_ZONAS"
	END	

	
/******************************************************************************************************************/	
	
	--Búsqueda formateada que trae el código de cuenta de acuerdo al motivo de entrada que se seleccionó,
    --se asignó a la entrada de Mercancía de Inventario.
	
	-- CALL "RML_BF_OP_GENERAL" ('01','03','0',$[IGN1.U_IQ_MOTENSAL],'','','','')	
	
	IF (@Objeto = '01' AND @NumeroBF = '03')
	BEGIN
		SELECT  "U_RML_CTA"  FROM  "@RML_MOTENSAL"  WHERE "Code" = @Param02
	END

/******************************************************************************************************************/

    --Búsqueda formateada que el motivo de etrada de la tabla Motivo Entrada / Salida, se asignó a la entrada de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','04','0','','','','','')	
	IF (@Objeto = '01' AND @NumeroBF = '04' )
	BEGIN
		SELECT  "Code","Name"  FROM "@RML_MOTENSAL" WHERE "U_RML_TIPO" = 'Entrada'
	END
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 1, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','05','0','','','','','')	
	IF (@Objeto = '01' AND @NumeroBF = '05' )
	BEGIN
		SELECT "PrcCode","PrcName" FROM OPRC WHERE  "DimCode" = 1
	END
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 2, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','06','0',$[IGE1.OcrCode],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '06' 
	--BEGIN
	--SELECT "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02
	--END
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 4, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','07','0',$[IGE1.OcrCode2],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '07' 
	--BEGIN
	--SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02
	--END
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 5, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','08','0',$[IGE1.OcrCode4],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '08' 
	--BEGIN
	--SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02
	--END					


/******************************************************************************************************************/	
	
	--Búsqueda formateada que trae el código de cuenta de acuerdo al motivo de entrada que se seleccionó,
    --se asignó a la Salida de Mercancía de Inventario.
	
	-- CALL "RML_BF_OP_GENERAL" ('01','09','0',$[IGE1.U_IQ_MOTENSAL],'','','','')	
	
	IF (@Objeto = '01' AND @NumeroBF = '09' )
	BEGIN
	SELECT  "U_RML_CTA"  FROM  "@RML_MOTENSAL"  WHERE "Code" = @Param02
	END

/******************************************************************************************************************/

    --Búsqueda formateada que el motivo de etrada de la tabla Motivo Entrada / Salida, se asignó a la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','10','0','','','','','')	
	IF (@Objeto = '01' AND @NumeroBF = '10' )
	BEGIN
	SELECT  "Code","Name"  FROM "@RML_MOTENSAL" WHERE "U_RML_TIPO" = 'Salida'
	END


/******************************************************************************************************************/

    --Búsqueda formateada que los datos de Usuarios registrados en sap, se asignó a Transferencia de Stock
	
	-- CALL "RML_BF_OP_GENERAL" ('01','11','0','','','','','')	
	IF( @Objeto = '01' AND @NumeroBF = '11' )
	BEGIN
	SELECT "U_NAME","USER_CODE" FROM OUSR
	END
	

		
/******************************************************************************************************************/
/*****************************************COMPRAS NACIONALES Y SERVICIOS*******************************************/
    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
	-- NIVEL 1

	-- CALL "RML_BF_OP_GENERAL" ('01','12',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
/*
     SELECT "U_IQ_Importe" INTO MONTO1 FROM "@IQ_FA_OC"  WHERE "Code"= 01
     SELECT "U_IQ_Importe" INTO MONTO2 FROM "@IQ_FA_OC"  WHERE "Code"= 02
	
	 IF @Objeto = '01' AND @NumeroBF = '12' 
	 BEGIN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  @Param01  <= @MONTO1
       AND    "Code"= 01
       AND    @Param02 IN ('01','03') 
	 END
*/
/******************************************************************************************************************/

    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
    -- NIVEL 2
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','13',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
	
	 IF @Objeto = '01' AND @NumeroBF = '13' 
	 BEGIN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  @Param01 > MONTO1 AND @Param01 <= MONTO2
       AND    "Code"= 02
       AND    @Param02 IN ('01','03') 
	 END	 
	 
	 */
/******************************************************************************************************************/

    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
    -- NIVEL 3
	
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','14',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
	
	 IF @Objeto = '01' AND @NumeroBF = '14' 
	 BEGIN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  @Param01 >= MONTO2
       AND    "Code"= 02
       AND    @Param02 IN ('01','03')	 
	 END	
*/

	 
/******************************************************************************************************************/

    --Búsqueda formateada donde se muestran todas las Ordenes de Compra Cerradas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','21','0','','','','','')	
	IF @Objeto = '01' AND @NumeroBF = '21' 
	BEGIN
	SELECT  "DocNum","CardCode","CardName","DocTotal"  FROM "OPOR" WHERE "CANCELED" = 'N'
	END
	
	 
	 
/******************************************************************************************************************/	


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra los socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','25','0','','','','','')	
	IF @Objeto = '01' AND @NumeroBF = '25' 
	BEGIN
	SELECT "CardCode", "CardName", "CardType" FROM OCRD WHERE "U_BPP_BPAT"= 'Y'
	END


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra NOMBRE de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','26','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	IF @Objeto = '01' AND @NumeroBF = '26' 
	BEGIN
	SELECT "CardName" FROM "OCRD" WHERE "CardCode" = @Param02
	END
	 
/******************************************************************************************************************/	

    --Búsqueda formateada que muestra DIRECCION de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','27','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '27' 
	BEGIN
	SELECT LEFT(ISNULL("Street", '') + ' - ' + /* ISNULL("State", '')+ ' - ' +*/ ISNULL("City",'') + ' - ' +ISNULL("Block", '') ,100)
	FROM "CRD1" WHERE "CardCode" =   @Param02 AND "AdresType" = 'B' AND "Country" = 'PE'
	END
	
	 
/******************************************************************************************************************/	

    --Búsqueda formateada que muestra RUC de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','28','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '28' 
	BEGIN
	SELECT "LicTradNum" FROM "OCRD" WHERE "CardCode" = @Param02
	END		 


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra los choferes
	
	-- CALL "RML_BF_OP_GENERAL" ('01','29','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '29' 
	--BEGINF
	--SELECT T0."U_BPP_CHLI", T0."U_BPP_CHNO" FROM "@BPP_CONDUC"  T0 WHERE "U_BPP_NOMCOND" = @Param02
	--END	
	
/******************************************************************************************************************/	

   --Búsqueda formateada que muestra los choferes
	
	-- CALL "RML_BF_OP_GENERAL" ('01','30','0',$[ODLN."U_IQ_MDFC"],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '30' 
	--BEGIN
	--SELECT "U_BPP_CHNO" FROM "@BPP_CONDUC" --WHERE "U_BPP_CHLI" =  @Param02
	--END		
			
/******************************************************************************************************************/	

   --Búsqueda formateada que muestra DIRECCION punto de partida 
	
	-- CALL "RML_BF_OP_GENERAL" ('01','31','0',$[ODLN."U_IQ_MDFC"],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '31' 
	BEGIN
	SELECT LEFT(ISNULL("StreetNo", '') + ' - ' + ISNULL("City",'') + ' - ' +ISNULL("County", '') ,100)
	FROM ADM1
	END			

	
/******************************************************************************************************************/	

--Búsqueda formateada que muestra DIRECCION punto de llegada

	-- CALL "RML_BF_OP_GENERAL" ('01','32','0',$["ODLN"."CardCode"],'','','','')	

 IF @Objeto = '01' AND @NumeroBF = '32' 
  BEGIN
     SELECT 
     T1."Street"+' - '+ T1."City"+' - '+ T1."Block" as "Dirección Almacén", T1."Address" AS "Almacén"
     FROM "OCRD" t0  INNER JOIN "CRD1" t1 on t1."CardCode" = t0."CardCode" AND  t1."AdresType"  = 'S'                
	 INNER JOIN "OCST" t2  ON  t2."Code" = t1."State"  AND  t2."Country" = t1."Country" 
	 WHERE t0."CardCode" = @Param02
	 ORDER BY "Almacén"  ASC
	 
END	
 
 
/*****************************************************************************************************/	
/*
   --Búsqueda formateada que muestra MOTIVOS DE TRASLADO
	
	-- CALL "RML_BF_OP_GENERAL" ('01','33','0','','','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '33' 
	BEGIN
	SELECT T0."Code", T0."Name", T0."U_IQ_DESC" FROM "@IQ_MOTTRAS"  T0
	END  
*/	
/**********************************************CENTRO COSTO COMPRAS*************************************************/

    --Búsqueda formateada que trae el Centro de Costo 1, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','34','0','','','','','')	
	--IF @Objeto = '01' AND @NumeroBF = '34' 
	--BEGIN
	--SELECT "PrcCode","PrcName" FROM OPRC WHERE "U_RML_TIPO"=01 AND "DimCode" = 1
	--END
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 2, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','35','0',$[$38.2004],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '35' 
	--BEGIN
	--SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02 AND "DimCode" = 2 
	--END
	
	--CALL "RML_BF_OP_GENERAL" ('01','35','0','04','','','','')
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 4, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','36','0',$[$38.2003],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '36' 
	--BEGIN
	--SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02 AND "DimCode" = 4
	--END
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 5, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','37','0',$[$38.2001],'','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '37' 
	--BEGIN
	--SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = @Param02 AND "DimCode" = 5 
	--END					
	
	
			
/*****************************************DOCUMENTO ORIGEN DE VENTAS*******************************************/
	
	--NC PROVEEDORES@	CALL "RML_BF_OP_GENERAL" ('01', '58','0',$[ORPC.U_VS_TDOCORG],$[ORPC.CardCode],'','','')
	IF @Objeto = '01' AND @NumeroBF = '58' 
	BEGIN 
		--DECLARE @TipoSAPDocumentoOrigen NVARCHAR(3) 
		SET @TipoSAPDocumentoOrigen = @Param02

			IF @TipoSAPDocumentoOrigen = '14' 
			BEGIN 
				SELECT	"DocEntry" AS "ID", "DocNum" AS "N° SAP" , "NumAtCard" AS "Referencia de SN", 
						"DocDate" AS "Fecha", "DocCur" AS "Moneda", 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS "Importe", 
						"U_BPP_MDTD" AS "Tipo", "U_BPP_MDSD" AS "Serie", "U_BPP_MDCD" AS "Numero" 
				FROM "OPCH" 
				WHERE "CardCode" = @Param03
			END 
			
			IF @TipoSAPDocumentoOrigen = '204' 
			BEGIN 
				SELECT	"DocEntry" AS ID, "DocNum" AS "N° SAP","NumAtCard" AS "Referencia de SN", "DocDate" AS Fecha, "DocCur" AS Moneda, 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS Importe, 
						"U_BPP_MDTD" AS Tipo, "U_BPP_MDSD" AS Serie, "U_BPP_MDCD" AS Numero 
				FROM "ODPO" WHERE "CardCode" = @Param03 
			END
	END	


/******************************************************************************************************************/


--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '59','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '59' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '14') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDTD") FROM "OPCH" 
				WHERE "DocEntry" = @Param03 
			END	
			IF(@Param02 = '204') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDTD") FROM "ODPO" WHERE "DocEntry" = @Param03 
			END
		END
		ELSE 
			SELECT ''  
	END

	
/******************************************************************************************************************/

	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '60','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '60' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '14') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDSD") FROM "OPCH" WHERE "DocEntry" = @Param03
			END
			
			IF(@Param02 = '204') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDSD") FROM "ODPO" WHERE "DocEntry" = @Param03 
			END
		END
		ELSE 
		SELECT '' 
	END
	
/******************************************************************************************************************/
	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '61','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '61' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '14') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDCD") FROM "OPCH" WHERE "DocEntry" = @Param03 
			END
			
			IF(@Param02 = '204') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDCD") FROM "ODPO" WHERE "DocEntry" = @Param03 
			END		
		END
		ELSE 
		SELECT '' 
	END
	
/******************************************************************************************************************/	
	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '62','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','') 
	IF @Objeto = '01' AND @NumeroBF = '62' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '14') 
			BEGIN 
				SELECT "DocDate" FROM "OPCH" WHERE "DocEntry" = @Param03
			END
			
			IF(@Param02 = '204') 
			BEGIN 
				SELECT "DocDate" FROM "ODPO" WHERE "DocEntry" = @Param03
			END
		END
		ELSE 
		SELECT '' 
	END
	
/******************************************************************************************************************/

	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '63','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '63' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 		
			IF(@Param02 = '14') 
			BEGIN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "OPCH" WHERE "DocEntry" = @Param03 
			END
			IF(@Param02 = '204') 
			BEGIN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "ODPO" WHERE "DocEntry" = @Param03			
			END
		END
		ELSE
			SELECT '' 			
	END	
/******************************************************************************************************************/
	
/******************************************************************************************************************/


   --Búsqueda formateada que los usuarios de Compras.
	
   --CALL "RML_BF_OP_GENERAL" ('01','64','0','','','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '64' 
	--BEGIN
	--SELECT "SlpName" AS "Encargado de Compras"  FROM OSLP T0 WHERE T0."U_TIPO" ='02'
	--END  		 
/******************************************************************************************************************/

   
   --Búsqueda formateada que trae el centro de beneficio 1 formularios de Ventas.

   -- CALL "RML_BF_OP_GENERAL" ('01','65','0',$[$38.1],'','','','')	
	/*

	IF @Objeto = '01' AND @NumeroBF = '65' 
	BEGIN
	SELECT SUBSTR("U_IQ_CEBE",1,2) FROM OITM WHERE "ItemCode" = Param02
	END*/
	
/******************************************************************************************************************/

	
    --Búsqueda formateada que trae el Centro de Beneficio 2, se asignó a los formularios de Ventas
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','66','0',$[$38.1],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '66' 
	BEGIN
	SELECT SUBSTR("U_IQ_CEBE",1,4) FROM OITM WHERE "ItemCode" = Param02
	END
	*/
/******************************************************************************************************************/
    --Búsqueda formateada que trae el Centro de Beneficio 4, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','67','0',$[$38.1],'','','','')	
	/*
	IF @Objeto = '01' AND @NumeroBF = '67' 
	BEGIN
	SELECT SUBSTR("U_IQ_CEBE",1,6) FROM OITM WHERE "ItemCode" = Param02
	END
	*/
	
/******************************************************************************************************************/
/*
    --Búsqueda formateada que trae el Centro de Beneficio 5, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','68','0',$[$38.1],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '68' 
	BEGIN
	SELECT "PrcCode" FROM OPRC WHERE "DimCode" = '5'
	END
	*/

/*****************************************DOCUMENTO ORIGEN DE VENTAS*******************************************/

--CALL "RML_BF_OP_GENERAL" ('01', '71','0',$[ORIN.U_IQ_TDOCORG],$[ORIN.CardCode],'','','')
--CALL "RML_BF_OP_GENERAL" ('01', '71','0','13','C10032132982','','','')

	IF @Objeto = '01' AND @NumeroBF = '71' 
	BEGIN 
		--DECLARE @TipoSAPDocumentoOrigen NVARCHAR(3) 
		SET @TipoSAPDocumentoOrigen = @Param02

			IF @TipoSAPDocumentoOrigen = '13' 
			BEGIN 
				SELECT	"DocEntry" AS "ID", "DocNum" AS "N° SAP" , "NumAtCard" AS "Referencia de SN", 
						"DocDate" AS "Fecha", "DocCur" AS "Moneda", 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS "Importe", 
						"U_BPP_MDTD" AS "Tipo", "U_BPP_MDSD" AS "Serie", "U_BPP_MDCD" AS "Numero" 
				FROM "OINV" 
				WHERE "CardCode"  = @Param03
			END
			
			IF @TipoSAPDocumentoOrigen = '203' 
			BEGIN 
				SELECT	"DocEntry" AS ID, "DocNum" AS "N° SAP","NumAtCard" AS "Referencia de SN", "DocDate" AS Fecha, "DocCur" AS Moneda, 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS Importe, 
						"U_BPP_MDTD" AS Tipo, "U_BPP_MDSD" AS Serie, "U_BPP_MDCD" AS Numero 
				FROM "ODPI" WHERE "CardCode" = @Param03 
			END
	END	

/******************************************************************************************************************/


--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '72','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '72' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '13') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDTD") FROM "OINV" 
				WHERE "DocEntry" = @Param03 
			END
			
			IF(@Param02 = '203') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDTD") FROM "ODPI" WHERE "DocEntry" = @Param03 
			END
		END
		ELSE 
			SELECT ''   
	END

	
/******************************************************************************************************************/

	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '73','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '73' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '13') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDSD") FROM "OINV" WHERE "DocEntry" = @Param03
			END
			
			IF(@Param02 = '203') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDSD") FROM "ODPI" WHERE "DocEntry" = @Param03 
			END
		END
		ELSE 
		SELECT ''  
	
	END
	
/******************************************************************************************************************/
	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '74','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '74' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '13') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDCD") FROM "OINV" WHERE "DocEntry" = @Param03 
			END
			
			IF(@Param02 = '203') 
			BEGIN 
				SELECT RTRIM("U_BPP_MDCD") FROM "ODPI" WHERE "DocEntry" = @Param03 
			END		
		END
		ELSE 	
			SELECT ''  
	END
	
/******************************************************************************************************************/	
	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '75','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','') 
	IF @Objeto = '01' AND @NumeroBF = '75' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 
			IF(@Param02 = '13') 
			BEGIN 
				SELECT "DocDate" FROM "OINV" WHERE "DocEntry" = @Param03
			END
			
			IF(@Param02 = '203') 
			BEGIN 
				SELECT "DocDate" FROM "ODPI" WHERE "DocEntry" = @Param03
			END
		END
		ELSE 
		SELECT '' 
	END
	
/******************************************************************************************************************/

	
	--NC COMPRAS@	CALL "RML_BF_OP_GENERAL" ('01', '76','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF @Objeto = '01' AND @NumeroBF = '76' 
	BEGIN 
		IF(@Param02 <> '') 
		BEGIN 		
			IF(@Param02 = '13') 
			BEGIN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "OINV" WHERE "DocEntry" = @Param03 
			END
			IF(@Param02 = '203') 
			BEGIN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "ODPI" WHERE "DocEntry" = @Param03			
			END
		END
		ELSE
			SELECT '' 			
	END	
	
		 	
/********************************************************************************************************/
--Tipo de operacion en compras por defecto
--CALL "RML_BF_OP_GENERAL" ('01','83','0','','','','','')

 	IF @Objeto = '01' AND @NumeroBF = '83' 
	BEGIN
		--SELECT * FROM "@OK1_T12"
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" --WHERE ISNULL("U_IQ_Compras",0) <> 0 ORDER BY "U_IQ_Compras"
	END	
	
--Tipo de operacion en ventas por defecto
--CALL "RML_BF_OP_GENERAL" ('01','84','0','','','','','')

 	IF @Objeto = '01' AND @NumeroBF = '84' 
	BEGIN
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" --WHERE ISNULL("U_IQ_Ventas",0) <> 0 ORDER BY "U_IQ_Ventas" DESC
	END		


--Tipo de operacion en ventas por defecto
--CALL "RML_BF_OP_GENERAL" ('01','85','0','','','','','')

 	IF @Objeto = '01' AND @NumeroBF = '85' 
	BEGIN
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" --WHERE ISNULL("U_IQ_Almacen",0) <> 0 ORDER BY  "U_IQ_Almacen" DESC
	END			
	
/***********************************************************************************************************/

--Búsqueda formateada que los usuarios de Ventas.
	
   --CALL "RML_BF_OP_GENERAL" ('01','86','0','','','','','')	
	
	--IF @Objeto = '01' AND @NumeroBF = '86' 
	--BEGIN
	--SELECT "SlpName" AS "Encargado de Ventas"  FROM OSLP T0 WHERE T0."U_TIPO" ='01' OR T0."U_TIPO" ='03'
	--END
	
	
/************************************************CENTRO DE COSTO **********************************************/

/******************************************************************************************************************/
/*
   
   --Búsqueda formateada que trae el centro de beneficio 1 formularios de Ventas.

   -- CALL "RML_BF_OP_GENERAL" ('01','87','0',$[$13.1],'','','','')	

	IF @Objeto = '01' AND @NumeroBF = '87' 
	BEGIN
	SELECT SUBSTR("U_IQ_CECO",1,2) FROM OITM WHERE "ItemCode" = Param02
	END
	*/
/******************************************************************************************************************/
/*
	
    --Búsqueda formateada que trae el Centro de Beneficio 2, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','88','0',$[$13.1],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '88' 
	BEGIN
	SELECT SUBSTR("U_IQ_CECO",1,4) FROM OITM WHERE "ItemCode" = Param02
	END
	*/
/******************************************************************************************************************/
 /*
    --Búsqueda formateada que trae el Centro de Beneficio 4, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','89','0',$[$13.1],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '89' 
	BEGIN
	SELECT SUBSTR("U_IQ_CECO",1,6) FROM OITM WHERE "ItemCode" = Param02
	END
	*/
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Beneficio 5, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','90','0',$[$13.1],'','','','')	
	
	IF @Objeto = '01' AND @NumeroBF = '90' 
	BEGIN
	SELECT "PrcCode" FROM OPRC WHERE "DimCode" = '5'
	END
	
	
/******************************************************************************************************************/

    --Búsqueda formateada para los tipos de Documento
	
	-- CALL "RML_BF_OP_GENERAL" ('01','91','0','','','','','')	
	IF @Objeto = '01' AND @NumeroBF = '91' 
	BEGIN
	SELECT "Name","U_BPP_TDDD" FROM "@BPP_TPODOC"
	END	
	  		 			 
/******************************************************************************************************************/

    --Búsqueda formateada para el tipo de Afectación
	
	-- CALL "RML_BF_OP_GENERAL" ('01','92','0','','','','','')	
	IF @Objeto = '01' AND @NumeroBF = '92' 
	BEGIN
	SELECT * FROM "@STR_AFECIGV"
	END	
	
/******************************************************************************************************************/

    --Búsqueda formateada para la concatenación en 
	
	-- CALL "RML_BF_OP_GENERAL" ('01','93','0','tpDoc','@serie','Correlativo','','')	
/*
	Param02	nVarchar(100),
	Param03	nVarchar(100),
	Param04	nVarchar(100),
*/
	IF @Objeto = '01' AND @NumeroBF = '93' 
	BEGIN
		SELECT @Param02 + '-' +@Param03 + '-' +@Param04 
	END
	  		 	  		
/***************************************    ADDON PERÚ  ***************************************************************************/

    --Búsqueda formateada para ADDON PERÚ - PAGO MASIVO DE PROVEEDORES
	
	-- CALL "RML_BF_OP_GENERAL" ('01','94','0',$["@BPP_PAGM_CAB"."U_BPP_FILTRO"],'','','','')	
		IF @Objeto = '01' AND @NumeroBF = '94' 
		BEGIN
			--Param02
			IF @Param02 = '001'
			BEGIN
				SELECT "GroupCode","GroupName" FROM OCRG WHERE "GroupType" = 'S'
			END
			IF @Param02 = '002'
			BEGIN
				SELECT '001','001' FROM "DUMMY"
			END
		END	
		/************************************   CCHHE  **************************************************************/	
		-- Ver los aperturados 
		-- EXEC RML_BF_OP_GENERAL '01','95','0','','','','',''
		IF @Objeto = '01' AND @NumeroBF = '95' 
		BEGIN
			 SELECT DISTINCT 
				T1."DocNum", 
				T0."LineId", 
				T3."DocNum" AS "Solicitud",
				T3."DocDate" AS "Fecha Inicio",
				T3."TaxDate" AS "Fecha Fin",
				T3."DocDueDate" AS "Valido hasta",
				T0."U_ER_EARN", 
				T0."U_ER_DSCP", 
				T0."U_ER_NMER", 

				CASE 
					WHEN T3."U_CE_TTSL" = 0 THEN SUM(ISNULL(T4."U_CE_IMSL", 0)) 
					ELSE T3."U_CE_TTSL" 
				END AS "Monto de solicitud",

				T2."DocNum" AS "Pago",
				T3."Comments" AS "Comentario Sol"
			FROM 
				"@STR_EARAPRDET" T0
				INNER JOIN "@STR_EARAPR" T1 ON T1."DocEntry" = T0."DocEntry" 
				LEFT JOIN OVPM T2 ON T2."U_BPP_CCHI" = T0."U_ER_EARN" AND T0."U_ER_NMER" = T2."U_BPP_NUMC"
				INNER JOIN OPRQ T3 ON T3."DocEntry" = T0."U_ER_DESL"
				LEFT JOIN PRQ1 T4 ON T4."DocEntry" = T3."DocEntry" 
			WHERE 
				T1."DocEntry" <> 6
			GROUP BY 
				T1."DocNum", 
				T0."LineId", 
				T3."DocNum", 
				T3."DocDate", 
				T3."TaxDate", 
				T3."DocDueDate", 
				T0."U_ER_EARN", 
				T0."U_ER_DSCP", 
				T0."U_ER_NMER", 
				T2."DocNum", 
				T3."Comments", 
				T3."U_CE_TTSL";
		END	
		-- Diferencias entre Solicitado y Pagado
		-- CALL RML_BF_OP_GENERAL ('01','96','0','Param2','Param3','Param4','Param5','')	
		IF @Objeto = '01' AND @NumeroBF = '96' 
		BEGIN
			  SELECT 
					T2."DocNum",  
					T0."U_ER_EARN", 
					T0."U_ER_DSCP", 
					T0."U_ER_NMER", 
					T2."DocDate" AS "Fecha Solicitado",
					T1."DocDate" AS "Fecha pagado",
					CASE 
						WHEN T2."U_CE_TTSL" = 0 THEN SUM(ISNULL(T3."U_CE_IMSL", 0)) 
						ELSE T2."U_CE_TTSL" 
					END AS "Total Solicitado",
					T1."DocTotal" AS "Total Pagado",
					CASE 
						WHEN T2."U_CE_TTSL" = 0 THEN SUM(ISNULL(T3."U_CE_IMSL", 0)) 
						ELSE T2."U_CE_TTSL" 
					END - ISNULL(T1."DocTotal", 0) AS "Diferencia"
				FROM 
					"@STR_EARAPRDET" T0
					LEFT JOIN OVPM T1 ON T1."U_BPP_CCHI" = T0."U_ER_EARN" AND T0."U_ER_NMER" = T1."U_BPP_NUMC"
					INNER JOIN OPRQ T2 ON T2."DocEntry" = T0."U_ER_DESL"		
					LEFT JOIN PRQ1 T3 ON T3."DocEntry"  = T2."DocEntry"
				WHERE
					T1."DocTotal" > 0
				GROUP BY 
					T2."DocNum", 
					T0."U_ER_EARN", 
					T0."U_ER_DSCP", 
					T0."U_ER_NMER", 
					T2."DocDate", 
					T1."DocDate", 
					T2."U_CE_TTSL", 
					T1."DocTotal";
		END
		-- Estado de Cuenta de Clientes y Proveedores
		-- CALL RML_BF_OP_GENERAL ('01','97','0','[%0]','[%1]',[%3],[%4],'')	
		IF @Objeto = '01' AND @NumeroBF = '97' 
		BEGIN
			SELECT 
			T0."ShortName", 
			T3."CardName",
			T3."LicTradNum" AS "RUC/DNI/Otro",
			CASE 
			WHEN T1."TransType" = '18' THEN 'TT' 
			WHEN T1."TransType" = '30' THEN 'AS' 
			WHEN T1."TransType" = '46' THEN 'PP' 
			WHEN T1."TransType" = '321' THEN 'ID'
			WHEN T1."TransType" = '24' THEN 'TT' 
			ELSE 'XX'  
			END AS "TransType",  
			T1."BaseRef", 
			T2."FormatCode", 
			T1."TransId", 
			T1."RefDate", 
			T1."TaxDate", 
			T1."Ref1", 
			T1."Ref2", T1."Ref3", 
			T0."Debit" - T0."Credit" AS "Movimiento ML", 
			T0."FCDebit" - T0."FCCredit" AS "Movimiento ME" ,
			T0."ProfitCode" AS "CRP",
			T0."OcrCode2" AS "Partida",
			T1."Memo",
			T7."TransId" AS "Pago", 
			T8."Number" AS "Nro Asiento",
			T8."RefDate" AS "Fecha de Pago",
			T4."Comments"
			
			FROM JDT1 T0  
			INNER JOIN OJDT T1 ON T0."TransId" = T1."TransId" 
			INNER JOIN OACT T2 ON T0."Account" = T2."AcctCode" 
			INNER JOIN OCRD T3 ON T3."CardCode" = T0."ShortName"
			LEFT JOIN OPCH T4 ON T4."DocNum"  = T1."BaseRef" AND T4."DocSubType" = '--'
			LEFT JOIN VPM2 T6 ON T6."DocEntry" =  T4."DocEntry" 
			LEFT JOIN OVPM T7 ON T7."DocEntry" = T6."DocNum"
			LEFT JOIN OJDT T8 ON T8."TransId" = T7."TransId"
			
			WHERE T3."CardCode" BETWEEN @Param02 AND @Param03
			AND T1."RefDate" BETWEEN @Param04 AND @Param05
		END  
		-- Solicitudes de Dinero
		-- CALL RML_BF_OP_GENERAL ('01','98','0','','','','','')	
		IF @Objeto = '01' AND @NumeroBF = '98' 
		BEGIN
				 SELECT 	
				T0."DocNum", 
				T0."CANCELED",	
				T3."U_ER_NMER" AS "NRO VIATICO",
				T0."ReqName" AS "Solicitante",
				T6."Remarks" AS "Area",
				T4."U_BPP_TIPR" AS "Tipo de Rendición",
				T0."ReqDate" AS "Fecha de Solicitud",
				T0."DocDueDate" AS "Fecha de Vencimiento",
				CASE 
					WHEN T0."U_CE_TTSL" = 0 THEN SUM(ISNULL(T7."U_CE_IMSL", 0)) 
					ELSE T0."U_CE_TTSL" 
				END AS "Total",
				T5."DocNum" AS "Apertura",
				T4."DocEntry" AS "Pago"	
			FROM 
				OPRQ T0  
				INNER JOIN PRQ1 T7 ON T7."DocEntry" = T0."DocEntry"
				INNER JOIN OHEM T1 ON T0."Requester" = T1."empID" AND T0."ReqType" = 171 
				LEFT JOIN OUBR T6 ON T6."Code" = T0."Branch"
				LEFT JOIN "@STR_EARAPRDET" T3 ON T3."U_ER_DESL" = T0."DocEntry"
				LEFT JOIN "@STR_EARAPR" T5 ON T5."DocEntry" = T3."DocEntry"
				LEFT JOIN OVPM T4 ON T4."U_BPP_CCHI" = T3."U_ER_EARN" AND T3."U_ER_NMER" = T4."U_BPP_NUMC"
			GROUP BY 
				T0."DocNum", 
				T0."CANCELED",	
				T3."U_ER_NMER",
				T0."ReqName",
				T6."Remarks",
				T4."U_BPP_TIPR", 
				T0."ReqDate",
				T0."DocDueDate",
				T5."DocNum",
				T4."DocEntry",
				T0."U_CE_TTSL";
		END 
END
