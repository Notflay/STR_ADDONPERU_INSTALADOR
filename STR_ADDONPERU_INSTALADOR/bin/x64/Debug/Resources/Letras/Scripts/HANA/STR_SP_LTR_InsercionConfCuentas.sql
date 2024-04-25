CREATE PROCEDURE STR_SP_LTR_InsercionConfCuentas()
AS
	/*********************************** 
		1ra migracion hana:
		==================
		por: Nilton condori
		Fecha: 11/08/2014
		Comentarios: Este SP fue crado basandose del SP de la version SQL
		
		Datos de Actualizacion:
		======================
		Autor:
		Fecha:
		Comentarios:
	*************************************/
	
	/*********************************** 
	Declaracion de variables
	*************************************/
	V1 INTEGER;
	V2 INTEGER;
	V3 INTEGER;
	V4 INTEGER;
	V5 INTEGER;
	V6 INTEGER;
	V7 INTEGER;
	V8 INTEGER;
	V9 INTEGER;
	V10 INTEGER;
	V11 INTEGER;
	V12 INTEGER;
	V13 INTEGER;
	V14 INTEGER;
	V15 INTEGER;
	V16 INTEGER;
	V17 INTEGER;
	V18 INTEGER;
	V19 INTEGER;
	V20 INTEGER;
	V21 INTEGER;
	V22 INTEGER;
	
BEGIN
	DELETE FROM "@ST_LT_CONF";
	/****************************************************** 
	se cargan las variable con los valores correspondientes
	*******************************************************/
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000001')INTO V1 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000002')INTO V2 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000003')INTO V3 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000004')INTO V4 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000005')INTO V5 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000006')INTO V6 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000007')INTO V7 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000008')INTO V8 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000009')INTO V9 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000010')INTO V10 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000011')INTO V11 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000012')INTO V12 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000013')INTO V13 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000014')INTO V14 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000015')INTO V15 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000016')INTO V16 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000017')INTO V17 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000018')INTO V18 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000019')INTO V19 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000020')INTO V20 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000021')INTO V21 FROM DUMMY;
	SELECT(select COUNT('e') from "@ST_LT_CONF" where "Code"='00000022')INTO V22 FROM DUMMY; 
	

	/**************************************************************************************** 
	Se hace una evaluación simple, si no existe ningun resgistro, entonces hace la inserción.
	*****************************************************************************************/
	IF :V1 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000001',	'00000001',	'Porte', NULL, NULL, NULL);
	END IF;
	
	IF :V2 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000002',	'00000002',	'Comision', NULL, NULL, NULL);
	END IF;

	IF :V3 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000003',	'00000003',	'Interes', NULL, NULL, NULL);
	END IF;

	IF :V4 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000004',	'00000004',	'Garantia', NULL, NULL, NULL);
	END IF;

	IF :V5 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000005',	'00000005',	'Cta Pte Emision-CXC', NULL, NULL, NULL);
	END IF;

	IF :V6 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000006',	'00000006',	'Cta Pte Deposito-CXC', NULL, NULL, NULL);
	END IF;

	IF :V7 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000007',	'00000007',	'Porte Protesto', NULL, NULL, NULL);
	END IF;

	IF :V8 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000008',	'00000008',	'Comision Protesto', NULL, NULL, NULL);
	END IF;

	IF :V9 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000009',	'00000009',	'Interes CXP', NULL, NULL, NULL);
	END IF;

	IF :V10 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000010',	'00000010',	'Comision CXP', NULL, NULL, NULL);
	END IF;

	IF :V11 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000011',	'00000011',	'Porte Descuento', NULL, NULL, NULL);
	END IF;

	IF :V12 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000012',	'00000012',	'Comision Descuento', NULL, NULL, NULL);
	END IF;

	IF :V13 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000013',	'00000013',	'Interes Descuento', NULL, NULL, NULL);
	END IF;

	IF :V14 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000014',	'00000014',	'Garantia Descuento', NULL, NULL, NULL);
	END IF;

	IF :V15 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000015',	'00000015',	'Porte Cobranza', NULL, NULL, NULL);
	END IF;

	IF :V16 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000016',	'00000016',	'Comision Cobranza', NULL, NULL, NULL);
	END IF;

	IF :V17 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000017',	'00000017',	'Interes  Cobranza', NULL, NULL, NULL);
	END IF;

	IF :V18 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000018',	'00000018',	'Garantia Cobranza', NULL, NULL, NULL);
	END IF;

	IF :V19 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000019',	'00000019',	'Cta Pte Emision-CXP', NULL, NULL, NULL);
	END IF;
	
	IF :V20 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000020',	'00000020',	'Cta Pte Deposito-CXP', NULL, NULL, NULL);
	END IF;

	IF :V21 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000021',	'00000021',	'Cta Pte Retenc', NULL, NULL, NULL);
	END IF;

	IF :V22 = 0
	THEN
		INSERT INTO "@ST_LT_CONF" values ('00000022',	'00000022',	'Cta Retenc SAP', NULL, NULL, NULL);
	END IF;

END;