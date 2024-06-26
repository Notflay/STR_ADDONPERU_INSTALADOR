CREATE PROCEDURE RML_BF_OP_GENERAL
(
	Objeto		nvarchar(30),
	NumeroBF	nVarchar(6),/* Elige la busqueda formateada que se desea ejecutar. 
						       Para futuras implementaciones se debe agregar las nuevas condiciones en un numerál distinto.
						  	*/
	Param01	NUMERIC,
	Param02	nVarchar(100),
	Param03	nVarchar(100),
	Param04	nVarchar(100),
	Param05	nVarchar(100),
	Param06	nVarchar(100)
)AS
BEGIN
	DECLARE MONTO1  NUMERIC;
    DECLARE MONTO2  NUMERIC;	
    DECLARE MAXCODITEM01	NVARCHAR(50); 
	DECLARE NEXTCODITEM01	NVARCHAR(50); 
	DECLARE FINALCOD01      NVARCHAR(50);
	DECLARE MAXCODITEM02	NVARCHAR(50); 
	DECLARE NEXTCODITEM02	NVARCHAR(50); 
	DECLARE FINALCOD02      NVARCHAR(50);
	DECLARE MAXCODITEM03	NVARCHAR(50); 
	DECLARE NEXTCODITEM03	NVARCHAR(50); 
	DECLARE FINALCOD03      NVARCHAR(50);
	DECLARE COINI           NVARCHAR(50);
    DECLARE TipoSAPDocumentoOrigen 	NVARCHAR(3); 
	DECLARE TipoPersona				NVARCHAR(10);

		
/******************************************************************************************************************/

    --Búsqueda formateada que trae las unidades de Medida de SAP, se han asignado al MAESTRO DE ARTICULOS
	
	-- CALL "RML_BF_OP_GENERAL" ('01','01','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '01' 
	THEN
	SELECT "UomCode" ,"UomName" FROM OUOM;
	END IF; 


/******************************************************************************************************************/

    --Búsqueda formateada que trae ZONAS, se han asignado al MAESTRO DE SOCIOS DE NEGOCIO
	
	-- CALL "RML_BF_OP_GENERAL" ('01','02','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '02' 
	THEN
	SELECT  "Code","U_RML_TERRI","U_RML_NOMTERRI"  FROM "@RML_ZONAS";
	END IF; 	

	
/******************************************************************************************************************/	
	
	--Búsqueda formateada que trae el código de cuenta de acuerdo al motivo de entrada que se seleccionó,
    --se asignó a la entrada de Mercancía de Inventario.
	
	-- CALL "RML_BF_OP_GENERAL" ('01','03','0',$[IGN1.U_IQ_MOTENSAL],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '03' 
	THEN
		SELECT  "U_RML_CTA"  FROM  "@RML_MOTENSAL"  WHERE "Code" = :Param02;
	END IF; 

/******************************************************************************************************************/

    --Búsqueda formateada que el motivo de etrada de la tabla Motivo Entrada / Salida, se asignó a la entrada de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','04','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '04' 
	THEN
		SELECT  "Code","Name"  FROM "@RML_MOTENSAL" WHERE "U_RML_TIPO" = 'Entrada';
	END IF; 
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 1, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','05','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '05' 
	THEN
		SELECT "PrcCode","PrcName" FROM OPRC WHERE  "DimCode" = 1;
	END IF; 
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 2, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','06','0',$[IGE1.OcrCode],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '06' 
	THEN
	SELECT "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02;
	END IF; 
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 4, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','07','0',$[IGE1.OcrCode2],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '07' 
	THEN
	SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02;
	END IF; 
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 5, se asignó en la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','08','0',$[IGE1.OcrCode4],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '08' 
	THEN
	SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02;
	END IF; 					


/******************************************************************************************************************/	
	
	--Búsqueda formateada que trae el código de cuenta de acuerdo al motivo de entrada que se seleccionó,
    --se asignó a la Salida de Mercancía de Inventario.
	
	-- CALL "RML_BF_OP_GENERAL" ('01','09','0',$[IGE1.U_IQ_MOTENSAL],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '09' 
	THEN
	SELECT  "U_RML_CTA"  FROM  "@RML_MOTENSAL"  WHERE "Code" = :Param02;
	END IF; 

/******************************************************************************************************************/

    --Búsqueda formateada que el motivo de etrada de la tabla Motivo Entrada / Salida, se asignó a la salida de Mercancía de Inventario
	
	-- CALL "RML_BF_OP_GENERAL" ('01','10','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '10' 
	THEN
	SELECT  "Code","Name"  FROM "@RML_MOTENSAL" WHERE "U_RML_TIPO" = 'Salida';
	END IF; 


/******************************************************************************************************************/

    --Búsqueda formateada que los datos de Usuarios registrados en sap, se asignó a Transferencia de Stock
	
	-- CALL "RML_BF_OP_GENERAL" ('01','11','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '11' 
	THEN
	SELECT "U_NAME","USER_CODE" FROM OUSR;
	END IF; 
	

		
/******************************************************************************************************************/
/*****************************************COMPRAS NACIONALES Y SERVICIOS*******************************************/
    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
	-- NIVEL 1

	-- CALL "RML_BF_OP_GENERAL" ('01','12',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
/*
     SELECT "U_IQ_Importe" INTO MONTO1 FROM "@IQ_FA_OC"  WHERE "Code"= 01;
     SELECT "U_IQ_Importe" INTO MONTO2 FROM "@IQ_FA_OC"  WHERE "Code"= 02;
	
	 IF :Objeto = '01' AND :NumeroBF = '12' 
	 THEN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  :Param01  <= :MONTO1
       AND    "Code"= 01
       AND    :Param02 IN ('01','03'); 
	 END IF; 
*/
/******************************************************************************************************************/

    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
    -- NIVEL 2
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','13',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
	
	 IF :Objeto = '01' AND :NumeroBF = '13' 
	 THEN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  :Param01 > MONTO1 AND :Param01 <= MONTO2
       AND    "Code"= 02
       AND    :Param02 IN ('01','03'); 
	 END IF; 	 
	 
	 */
/******************************************************************************************************************/

    -- Crear un flujo de autorización para autorizar la creación de la orden de compra en base a los importes
    -- que se traerán de la Tabla  De Parametros. 
    -- NIVEL 3
	
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','14',$[OPOR.DocTotal],$[OPOR.U_IQ_TIPOCOMPRA],'','','','')
	
	 IF :Objeto = '01' AND :NumeroBF = '14' 
	 THEN
	   SELECT 'TRUE' FROM "@IQ_FA_OC" 
       WHERE  :Param01 >= MONTO2
       AND    "Code"= 02
       AND    :Param02 IN ('01','03');	 
	 END IF; 	
*/

	 
/******************************************************************************************************************/

    --Búsqueda formateada donde se muestran todas las Ordenes de Compra Cerradas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','21','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '21' 
	THEN
	SELECT  "DocNum","CardCode","CardName","DocTotal"  FROM "OPOR" WHERE "CANCELED" = 'N';
	END IF; 
	
	 
	 
/******************************************************************************************************************/	


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra los socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','25','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '25' 
	THEN
	SELECT "CardCode", "CardName", "CardType" FROM OCRD WHERE "U_BPP_BPAT"= 'Y';
	END IF; 


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra NOMBRE de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','26','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	IF :Objeto = '01' AND :NumeroBF = '26' 
	THEN
	SELECT "CardName" FROM "OCRD" WHERE "CardCode" = :Param02;
	END IF; 
	 
/******************************************************************************************************************/	

    --Búsqueda formateada que muestra DIRECCION de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','27','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '27' 
	THEN
	SELECT LEFT(IFNULL("Street", '') || ' - ' || /* IFNULL("State", '')|| ' - ' ||*/ IFNULL("City",'') || ' - ' ||IFNULL("Block", '') ,100)
	FROM "CRD1" WHERE "CardCode" =   :Param02 AND "AdresType" = 'B' AND "Country" = 'PE';
	END IF; 
	
	 
/******************************************************************************************************************/	

    --Búsqueda formateada que muestra RUC de socios de negocio que son transportistas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','28','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '28' 
	THEN
	SELECT "LicTradNum" FROM "OCRD" WHERE "CardCode" = :Param02;
	END IF; 		 


/******************************************************************************************************************/	

    --Búsqueda formateada que muestra los choferes
	
	-- CALL "RML_BF_OP_GENERAL" ('01','29','0',$[ODLN."U_BPP_MDCT"],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '29' 
	THEN
	SELECT T0."U_BPP_CHLI", T0."U_BPP_CHNO" FROM "@BPP_CONDUC"  T0 WHERE "U_BPP_NOMCOND" = :Param02;
	END IF; 	
	
/******************************************************************************************************************/	

   --Búsqueda formateada que muestra los choferes
	
	-- CALL "RML_BF_OP_GENERAL" ('01','30','0',$[ODLN."U_IQ_MDFC"],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '30' 
	THEN
	SELECT "U_BPP_CHNO" FROM "@BPP_CONDUC"; --WHERE "U_BPP_CHLI" =  :Param02;
	END IF; 		
			
/******************************************************************************************************************/	

   --Búsqueda formateada que muestra DIRECCION punto de partida 
	
	-- CALL "RML_BF_OP_GENERAL" ('01','31','0',$[ODLN."U_IQ_MDFC"],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '31' 
	THEN
	SELECT LEFT(IFNULL("StreetNo", '') || ' - ' || IFNULL("City",'') || ' - ' ||IFNULL("County", '') ,100)
	FROM ADM1;
	END IF; 			

	
/******************************************************************************************************************/	

--Búsqueda formateada que muestra DIRECCION punto de llegada

	-- CALL "RML_BF_OP_GENERAL" ('01','32','0',$["ODLN"."CardCode"],'','','','')	

 IF :Objeto = '01' AND :NumeroBF = '32' 
  THEN
     SELECT 
     T1."Street"||' - '|| T1."City"||' - '|| T1."Block" as "Dirección Almacén", T1."Address" AS "Almacén"
     FROM "OCRD" t0  INNER JOIN "CRD1" t1 on t1."CardCode" = t0."CardCode" AND  t1."AdresType"  = 'S'                
	 INNER JOIN "OCST" t2  ON  t2."Code" = t1."State"  AND  t2."Country" = t1."Country" 
	 WHERE t0."CardCode" = :Param02
	 ORDER BY "Almacén"  ASC;
	 
 END IF;	
 
 
/*****************************************************************************************************/	
/*
   --Búsqueda formateada que muestra MOTIVOS DE TRASLADO
	
	-- CALL "RML_BF_OP_GENERAL" ('01','33','0','','','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '33' 
	THEN
	SELECT T0."Code", T0."Name", T0."U_IQ_DESC" FROM "@IQ_MOTTRAS"  T0;
	END IF;   
*/	
/**********************************************CENTRO COSTO COMPRAS*************************************************/

    --Búsqueda formateada que trae el Centro de Costo 1, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','34','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '34' 
	THEN
	SELECT "PrcCode","PrcName" FROM OPRC WHERE "U_RML_TIPO"=01 AND "DimCode" = 1;
	END IF; 
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 2, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','35','0',$[$38.2004],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '35' 
	THEN
	SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02 AND "DimCode" = 2 ;
	END IF; 
	
	--CALL "RML_BF_OP_GENERAL" ('01','35','0','04','','','','')
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 4, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','36','0',$[$38.2003],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '36' 
	THEN
	SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02 AND "DimCode" = 4;
	END IF; 
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Costo 5, se asignó a los formularios de Compras
	
	-- CALL "RML_BF_OP_GENERAL" ('01','37','0',$[$38.2001],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '37' 
	THEN
	SELECT  "PrcCode" ,"PrcName" FROM  "OPRC"  WHERE  "U_RML_TIPO" = 01 AND "U_RML_PADRE" = :Param02 AND "DimCode" = 5 ;
	END IF; 					
	
	
			
/*****************************************DOCUMENTO ORIGEN DE VENTAS*******************************************/
	
	--NC PROVEEDORES:	CALL "RML_BF_OP_GENERAL" ('01', '58','0',$[ORPC.U_VS_TDOCORG],$[ORPC.CardCode],'','','')
	IF :Objeto = '01' AND :NumeroBF = '58' 
	THEN 
		--DECLARE @TipoSAPDocumentoOrigen NVARCHAR(3); 
		TipoSAPDocumentoOrigen := :Param02;

			IF :TipoSAPDocumentoOrigen = '14' 
			THEN 
				SELECT	"DocEntry" AS "ID", "DocNum" AS "N° SAP" , "NumAtCard" AS "Referencia de SN", 
						"DocDate" AS "Fecha", "DocCur" AS "Moneda", 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS "Importe", 
						"U_BPP_MDTD" AS "Tipo", "U_BPP_MDSD" AS "Serie", "U_BPP_MDCD" AS "Numero" 
				FROM "OPCH" 
				WHERE "CardCode" = :Param03;
			END IF;
			
			IF :TipoSAPDocumentoOrigen = '204' 
			THEN 
				SELECT	"DocEntry" AS ID, "DocNum" AS "N° SAP","NumAtCard" AS "Referencia de SN", "DocDate" AS Fecha, "DocCur" AS Moneda, 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS Importe, 
						"U_BPP_MDTD" AS Tipo, "U_BPP_MDSD" AS Serie, "U_BPP_MDCD" AS Numero 
				FROM "ODPO" WHERE "CardCode" = :Param03; 
			END IF;
	END IF;	


/******************************************************************************************************************/


--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '59','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '59' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '14') 
			THEN 
				SELECT RTRIM("U_BPP_MDTD") FROM "OPCH" 
				WHERE "DocEntry" = :Param03; 
			END IF;
			
			IF(:Param02 = '204') 
			THEN 
				SELECT RTRIM("U_BPP_MDTD") FROM "ODPO" WHERE "DocEntry" = :Param03; 
			END IF; 
		ELSE 
			SELECT ''  FROM DUMMY;
		END IF;
	END IF;

	
/******************************************************************************************************************/

	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '60','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '60' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '14') 
			THEN 
				SELECT RTRIM("U_BPP_MDSD") FROM "OPCH" WHERE "DocEntry" = :Param03;
			END IF;
			
			IF(:Param02 = '204') 
			THEN 
				SELECT RTRIM("U_BPP_MDSD") FROM "ODPO" WHERE "DocEntry" = :Param03; 
			END IF;
		ELSE 
		SELECT '' FROM DUMMY;
		END IF; 
	END IF;
	
/******************************************************************************************************************/
	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '61','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '61' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '14') 
			THEN 
				SELECT RTRIM("U_BPP_MDCD") FROM "OPCH" WHERE "DocEntry" = :Param03 ;
			END IF;
			
			IF(:Param02 = '204') 
			THEN 
				SELECT RTRIM("U_BPP_MDCD") FROM "ODPO" WHERE "DocEntry" = :Param03 ;
			END IF;		
		ELSE 
		SELECT '' FROM DUMMY;
		END IF;
	END IF;
	
/******************************************************************************************************************/	
	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '62','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','') 
	IF :Objeto = '01' AND :NumeroBF = '62' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '14') 
			THEN 
				SELECT "DocDate" FROM "OPCH" WHERE "DocEntry" = :Param03;
			END IF;
			
			IF(:Param02 = '204') 
			THEN 
				SELECT "DocDate" FROM "ODPO" WHERE "DocEntry" = :Param03;
			END IF;
		ELSE 
		SELECT '' FROM DUMMY;
		END IF;
	END IF;
	
/******************************************************************************************************************/

	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '63','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '63' 
	THEN 
		IF(:Param02 <> '') 
		THEN 		
			IF(:Param02 = '14') 
			THEN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "OPCH" WHERE "DocEntry" = :Param03; 
			END IF;
			IF(:Param02 = '204') 
			THEN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "ODPO" WHERE "DocEntry" = :Param03;			
			END IF; 
		ELSE
			SELECT '' from DUMMY;			
		END IF;		
	END IF;	
/******************************************************************************************************************/
	
/******************************************************************************************************************/


   --Búsqueda formateada que los usuarios de Compras.
	
   --CALL "RML_BF_OP_GENERAL" ('01','64','0','','','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '64' 
	THEN
	SELECT "SlpName" AS "Encargado de Compras"  FROM OSLP T0 WHERE T0."U_TIPO" ='02';
	END IF;   		 
/******************************************************************************************************************/

   
   --Búsqueda formateada que trae el centro de beneficio 1 formularios de Ventas.

   -- CALL "RML_BF_OP_GENERAL" ('01','65','0',$[$38.1],'','','','')	
	/*

	IF :Objeto = '01' AND :NumeroBF = '65' 
	THEN
	SELECT SUBSTR("U_IQ_CEBE",1,2) FROM OITM WHERE "ItemCode" = Param02;
	END IF; 
/******************************************************************************************************************/

	
    --Búsqueda formateada que trae el Centro de Beneficio 2, se asignó a los formularios de Ventas
	/*
	-- CALL "RML_BF_OP_GENERAL" ('01','66','0',$[$38.1],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '66' 
	THEN
	SELECT SUBSTR("U_IQ_CEBE",1,4) FROM OITM WHERE "ItemCode" = Param02;
	END IF;
	
/******************************************************************************************************************/
    --Búsqueda formateada que trae el Centro de Beneficio 4, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','67','0',$[$38.1],'','','','')	
	/*
	IF :Objeto = '01' AND :NumeroBF = '67' 
	THEN
	SELECT SUBSTR("U_IQ_CEBE",1,6) FROM OITM WHERE "ItemCode" = Param02;
	END IF;
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Beneficio 5, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','68','0',$[$38.1],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '68' 
	THEN
	SELECT "PrcCode" FROM OPRC WHERE "DimCode" = '5';
	END IF;


/*****************************************DOCUMENTO ORIGEN DE VENTAS*******************************************/

--CALL "RML_BF_OP_GENERAL" ('01', '71','0',$[ORIN.U_IQ_TDOCORG],$[ORIN.CardCode],'','','')
--CALL "RML_BF_OP_GENERAL" ('01', '71','0','13','C10032132982','','','')

	IF :Objeto = '01' AND :NumeroBF = '71' 
	THEN 
		--DECLARE @TipoSAPDocumentoOrigen NVARCHAR(3); 
		TipoSAPDocumentoOrigen := :Param02;

			IF :TipoSAPDocumentoOrigen = '13' 
			THEN 
				SELECT	"DocEntry" AS "ID", "DocNum" AS "N° SAP" , "NumAtCard" AS "Referencia de SN", 
						"DocDate" AS "Fecha", "DocCur" AS "Moneda", 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS "Importe", 
						"U_BPP_MDTD" AS "Tipo", "U_BPP_MDSD" AS "Serie", "U_BPP_MDCD" AS "Numero" 
				FROM "OINV" 
				WHERE "CardCode"  = :Param03;
			END IF;
			
			IF :TipoSAPDocumentoOrigen = '203' 
			THEN 
				SELECT	"DocEntry" AS ID, "DocNum" AS "N° SAP","NumAtCard" AS "Referencia de SN", "DocDate" AS Fecha, "DocCur" AS Moneda, 
						CASE "DocCur" 
							WHEN 'SOL' THEN "DocTotal" 
							ELSE "DocTotalFC" 
						END AS Importe, 
						"U_BPP_MDTD" AS Tipo, "U_BPP_MDSD" AS Serie, "U_BPP_MDCD" AS Numero 
				FROM "ODPI" WHERE "CardCode" = :Param03; 
			END IF;
	END IF;	

/******************************************************************************************************************/


--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '72','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '72' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '13') 
			THEN 
				SELECT RTRIM("U_BPP_MDTD") FROM "OINV" 
				WHERE "DocEntry" = :Param03; 
			END IF;
			
			IF(:Param02 = '203') 
			THEN 
				SELECT RTRIM("U_BPP_MDTD") FROM "ODPI" WHERE "DocEntry" = :Param03; 
			END IF; 
		ELSE 
			SELECT ''  FROM DUMMY;
		END IF;
	END IF;

	
/******************************************************************************************************************/

	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '73','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '73' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '13') 
			THEN 
				SELECT RTRIM("U_BPP_MDSD") FROM "OINV" WHERE "DocEntry" = :Param03;
			END IF;
			
			IF(:Param02 = '203') 
			THEN 
				SELECT RTRIM("U_BPP_MDSD") FROM "ODPI" WHERE "DocEntry" = :Param03; 
			END IF;
		ELSE 
		SELECT '' FROM DUMMY;
		END IF; 
	END IF;
	
/******************************************************************************************************************/
	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '74','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '74' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '13') 
			THEN 
				SELECT RTRIM("U_BPP_MDCD") FROM "OINV" WHERE "DocEntry" = :Param03 ;
			END IF;
			
			IF(:Param02 = '203') 
			THEN 
				SELECT RTRIM("U_BPP_MDCD") FROM "ODPI" WHERE "DocEntry" = :Param03 ;
			END IF;		
		ELSE 
		SELECT '' FROM DUMMY;
		END IF;
	END IF;
	
/******************************************************************************************************************/	
	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '75','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','') 
	IF :Objeto = '01' AND :NumeroBF = '75' 
	THEN 
		IF(:Param02 <> '') 
		THEN 
			IF(:Param02 = '13') 
			THEN 
				SELECT "DocDate" FROM "OINV" WHERE "DocEntry" = :Param03;
			END IF;
			
			IF(:Param02 = '203') 
			THEN 
				SELECT "DocDate" FROM "ODPI" WHERE "DocEntry" = :Param03;
			END IF;
		ELSE 
		SELECT '' FROM DUMMY;
		END IF;
	END IF;
	
/******************************************************************************************************************/

	
	--NC COMPRAS:	CALL "RML_BF_OP_GENERAL" ('01', '76','0',$[ORPC.U_VS_TDOCORG],$[ORPC.U_VS_DocOrg],'','','')
	IF :Objeto = '01' AND :NumeroBF = '76' 
	THEN 
		IF(:Param02 <> '') 
		THEN 		
			IF(:Param02 = '13') 
			THEN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "OINV" WHERE "DocEntry" = :Param03; 
			END IF;
			IF(:Param02 = '203') 
			THEN 
				SELECT 
					CASE "DocCur" 
						WHEN 'SOL' THEN "DocTotal" 
						ELSE "DocTotalFC" 
					END 
				FROM "ODPI" WHERE "DocEntry" = :Param03;			
			END IF; 
		ELSE
			SELECT '' from DUMMY;			
		END IF;		
	END IF;	
	
		 	
/********************************************************************************************************/
--Tipo de operacion en compras por defecto
--CALL "RML_BF_OP_GENERAL" ('01','83','0','','','','','')

 	IF :Objeto = '01' AND :NumeroBF = '83' 
	THEN
		--SELECT * FROM "@OK1_T12"
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" ;--WHERE ifnull("U_IQ_Compras",0) <> 0 ORDER BY "U_IQ_Compras";
	END	IF;
	
--Tipo de operacion en ventas por defecto
--CALL "RML_BF_OP_GENERAL" ('01','84','0','','','','','')

 	IF :Objeto = '01' AND :NumeroBF = '84' 
	THEN
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" ;--WHERE ifnull("U_IQ_Ventas",0) <> 0 ORDER BY "U_IQ_Ventas" DESC;
	END	IF;	


--Tipo de operacion en ventas por defecto
--CALL "RML_BF_OP_GENERAL" ('01','85','0','','','','','')

 	IF :Objeto = '01' AND :NumeroBF = '85' 
	THEN
		SELECT "U_num", "U_descrp" FROM "@OK1_T12" ;--WHERE ifnull("U_IQ_Almacen",0) <> 0 ORDER BY  "U_IQ_Almacen" DESC;
	END	IF;		
	
/***********************************************************************************************************/

--Búsqueda formateada que los usuarios de Ventas.
	
   --CALL "RML_BF_OP_GENERAL" ('01','86','0','','','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '86' 
	THEN
	SELECT "SlpName" AS "Encargado de Ventas"  FROM OSLP T0 WHERE T0."U_TIPO" ='01' OR T0."U_TIPO" ='03';
	END IF; 
	
	
/************************************************CENTRO DE COSTO **********************************************/

/******************************************************************************************************************/
/*
   
   --Búsqueda formateada que trae el centro de beneficio 1 formularios de Ventas.

   -- CALL "RML_BF_OP_GENERAL" ('01','87','0',$[$13.1],'','','','')	

	IF :Objeto = '01' AND :NumeroBF = '87' 
	THEN
	SELECT SUBSTR("U_IQ_CECO",1,2) FROM OITM WHERE "ItemCode" = Param02;
	END IF; 
/******************************************************************************************************************/
/*
	
    --Búsqueda formateada que trae el Centro de Beneficio 2, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','88','0',$[$13.1],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '88' 
	THEN
	SELECT SUBSTR("U_IQ_CECO",1,4) FROM OITM WHERE "ItemCode" = Param02;
	END IF;
	
/******************************************************************************************************************/
 /*
    --Búsqueda formateada que trae el Centro de Beneficio 4, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','89','0',$[$13.1],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '89' 
	THEN
	SELECT SUBSTR("U_IQ_CECO",1,6) FROM OITM WHERE "ItemCode" = Param02;
	END IF;
	
	
/******************************************************************************************************************/

    --Búsqueda formateada que trae el Centro de Beneficio 5, se asignó a los formularios de Ventas
	
	-- CALL "RML_BF_OP_GENERAL" ('01','90','0',$[$13.1],'','','','')	
	
	IF :Objeto = '01' AND :NumeroBF = '90' 
	THEN
	SELECT "PrcCode" FROM OPRC WHERE "DimCode" = '5';
	END IF;
	
/******************************************************************************************************************/

    --Búsqueda formateada para los tipos de Documento
	
	-- CALL "RML_BF_OP_GENERAL" ('01','91','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '91' 
	THEN
	SELECT "Name","U_BPP_TDDD" FROM "@BPP_TPODOC";
	END IF; 	
	  		 			 
/******************************************************************************************************************/

    --Búsqueda formateada para el tipo de Afectación
	
	-- CALL "RML_BF_OP_GENERAL" ('01','92','0','','','','','')	
	IF :Objeto = '01' AND :NumeroBF = '92' 
	THEN
	SELECT * FROM "@STR_AFECIGV";
	END IF; 	
	
/******************************************************************************************************************/

    --Búsqueda formateada para la concatenación en 
	
	-- CALL "RML_BF_OP_GENERAL" ('01','93','0','tpDoc',':serie','Correlativo','','')	
/*
	Param02	nVarchar(100),
	Param03	nVarchar(100),
	Param04	nVarchar(100),
*/
	IF :Objeto = '01' AND :NumeroBF = '93' 
	THEN
		SELECT :Param02 || '-' ||:Param03 || '-' ||:Param04 FROM "DUMMY";
	END IF; 
	  		 	  		
/***************************************    ADDON PERÚ  ***************************************************************************/

    --Búsqueda formateada para ADDON PERÚ - PAGO MASIVO DE PROVEEDORES
	
	-- CALL "RML_BF_OP_GENERAL" ('01','94','0',$["@BPP_PAGM_CAB"."U_BPP_FILTRO"],'','','','')	
		IF :Objeto = '01' AND :NumeroBF = '94' 
		THEN
			--Param02
			IF :Param02 = '001'
			THEN
				SELECT "GroupCode","GroupName" FROM OCRG WHERE "GroupType" = 'S';
			ELSEIF :Param02 = '002'
			THEN
				SELECT '001','001' FROM "DUMMY";
			END IF;
		END IF; 	
		/************************************   CCHHE  **************************************************************/	
		-- Ver los aperturados 
		-- CALL RML_BF_OP_GENERAL ('01','95','0','','','','','')	
		/*
		IF :Objeto = '01' AND :NumeroBF = '95' 
		THEN
			SELECT T1."DocNum", T0."LineId", 
			T3."DocNum" AS "Solicitud",
			T3."DocDate" AS "Fecha Inicio",
			T3."TaxDate" AS "Fecha Fin",
			T3."DocDueDate" AS "Valido hasta",
			T0."U_ER_EARN", T0."U_ER_DSCP", T0."U_ER_NMER", 
			T3."DocTotal" AS "Monto de solicitud" ,
			T2."DocNum" AS "Pago",
			T3."Comments" AS "Comentario Sol"
			FROM "@STR_EARAPRDET"  T0
			INNER JOIN "@STR_EARAPR" T1 ON T1."DocEntry" = T0."DocEntry" 
			LEFT JOIN OVPM T2 ON T2. "DocEntry" = T0."U_ER_NroPago"
			INNER JOIN OPRQ T3 ON T3."DocEntry"=  T0."U_ER_DESL"
			WHERE T1."DocEntry" <> 6;
		END IF;
		*/ 	
		-- Diferencias entre Solicitado y Pagado
		-- CALL RML_BF_OP_GENERAL ('01','96','0','Param2','Param3','Param4','Param5','')	
		IF :Objeto = '01' AND :NumeroBF = '96' 
		THEN
			SELECT  T0."U_ER_EARN", T0."U_ER_DSCP", T0."U_ER_NMER" ,T2."DocDate" AS "Fecha Solicitado",
			T1."DocDate" AS "Fecha pagado",
			T2."DocTotal" AS "Total Solicitado" ,T1."DocTotal" AS "Total Pagado" , 
			T2."DocTotal" -  T1."DocTotal" AS "Diferencia"
			
			FROM "@STR_EARAPRDET"  T0
			INNER JOIN OVPM T1 ON T1."DocEntry" = T0."U_ER_NroPago" 
			INNER JOIN OPRQ T2 ON T2."DocEntry" = T0."U_ER_DESL"			
			WHERE T2."DocTotal" -  T1."DocTotal" <> 0;
		END IF; 
		-- Estado de Cuenta de Clientes y Proveedores
		-- CALL RML_BF_OP_GENERAL ('01','97','0','[%0]','[%1]',[%3],[%4],'')	
		IF :Objeto = '01' AND :NumeroBF = '97' 
		THEN
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
			
			WHERE T3."CardCode" BETWEEN :Param02 AND :Param03
			AND T1."RefDate" BETWEEN :Param04 AND :Param05;
		END IF;   
		-- Solicitudes de Dinero
		-- CALL RML_BF_OP_GENERAL ('01','98','0','','','','','')	
		IF :Objeto = '01' AND :NumeroBF = '98' 
		THEN
			SELECT 	
			T0."DocNum", 
			T0."CANCELED" ,
			--T2."SEDE" || '-' || T2."TIPO" || '-' || LPAD(T2."NUMEROEAR",8,0) AS "NRO VIATICO",
			T0."ReqName",
			T6."Remarks" AS "Area",
			'VIA', --T0."U_STR_TIPOEAR",
			--T0."U_DEPARTAMENTO",
			--T0."U_PROVINCIA",
			--T0."U_DISTRITO",
			--T0."U_STR_TIPORUTA",
			T0."ReqDate",
			T0."DocDueDate",
			T0."DocTotal" AS "Total",
			T5."DocNum" AS "Apertura"
			--T4."DocEntry" AS "Pago"	
			
			FROM OPRQ T0  
			INNER JOIN OHEM T1 ON T0."Requester" = T1."empID" AND T0."ReqType" = 171 
			LEFT JOIN OUBR T6 ON T6."Code" = T0."Branch"
			--LEFT JOIN OPRQ_NUMEAR T2 ON T2."DOCENTRY" = T0."DocEntry"
			LEFT JOIN "@STR_EARAPRDET" T3 ON T3."U_ER_DESL" = T0."DocEntry"
			LEFT JOIN "@STR_EARAPR" T5 ON T5."DocEntry" = T3."DocEntry";
			--LEFT JOIN OVPM T4 ON T4."DocEntry" = T3."U_ER_NroPago";
		END IF; 
END