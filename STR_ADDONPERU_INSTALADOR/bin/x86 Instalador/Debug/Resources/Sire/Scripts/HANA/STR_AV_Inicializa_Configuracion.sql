CREATE PROCEDURE STR_SIRE_InicializarConfiguracion()
AS
BEGIN

	DELETE FROM "@STR_CF_SIRE";
	
	INSERT INTO "@STR_CF_SIRE" VALUES ('1','Contraseña del Servicio','grant_type','password');
	INSERT INTO "@STR_CF_SIRE" VALUES ('2','Url Del Servicio','scope','https://api-sire.sunat.gob.pe');
	INSERT INTO "@STR_CF_SIRE" VALUES ('3','Cliente ID Sunat','client_id','');
	INSERT INTO "@STR_CF_SIRE" VALUES ('4','Cliente Secret Sunat','client_secret','');
	INSERT INTO "@STR_CF_SIRE" VALUES ('5','Ruc y Usuario SOL','username','');
	INSERT INTO "@STR_CF_SIRE" VALUES ('6','Contraseña SOL','password','');
	INSERT INTO "@STR_CF_SIRE" VALUES ('7','Ruta de los Archivos','ArchivosSire','');
END;