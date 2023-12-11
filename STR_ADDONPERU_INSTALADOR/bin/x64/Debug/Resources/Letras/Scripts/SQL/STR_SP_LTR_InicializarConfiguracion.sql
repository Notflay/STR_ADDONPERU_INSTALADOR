CREATE PROCEDURE STR_SP_LTR_InicializarConfiguracion
as
insert into [@ST_LT_CONFG] values ('00000001','00000001','Emisi�n', NULL, NULL,NULL)
insert into [@ST_LT_CONFG] values ('00000002','00000002','Cod. Tran. CC', NULL, NULL,NULL)
insert into [@ST_LT_CONFG] values ('00000003','00000003','Cod. Tran. CP', NULL, NULL,NULL)
