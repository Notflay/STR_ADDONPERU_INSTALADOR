CREATE PROCEDURE STR_SP_LTR_InsercionConfCuentas
AS
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000001')
begin
insert into [@ST_LT_CONF] values ('00000001',	'00000001',	'Porte', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000002')
begin
insert into [@ST_LT_CONF] values ('00000002',	'00000002',	'Comision', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000003')
begin
insert into [@ST_LT_CONF] values ('00000003',	'00000003',	'Interes', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000004')
begin
insert into [@ST_LT_CONF] values ('00000004',	'00000004',	'Garantia', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000005')
begin
insert into [@ST_LT_CONF] values ('00000005',	'00000005',	'Cta Pte Emisión-CXC', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000006')
begin
insert into [@ST_LT_CONF] values ('00000006',	'00000006',	'Cta Pte Deposito-CXC', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000007')
begin
insert into [@ST_LT_CONF] values ('00000007',	'00000007',	'Porte Protesto', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000008')
begin
insert into [@ST_LT_CONF] values ('00000008',	'00000008',	'Comisión Protesto', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000009')
begin
insert into [@ST_LT_CONF] values ('00000009',	'00000009',	'Interes CXP', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000010')
begin
insert into [@ST_LT_CONF] values ('00000010',	'00000010',	'Comision CXP', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000011')
begin
insert into [@ST_LT_CONF] values ('00000011',	'00000011',	'Porte Descuento', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000012')
begin
insert into [@ST_LT_CONF] values ('00000012',	'00000012',	'Comision Descuento', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000013')
begin
insert into [@ST_LT_CONF] values ('00000013',	'00000013',	'Interes Descuento', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000014')
begin
insert into [@ST_LT_CONF] values ('00000014',	'00000014',	'Garantia Descuento', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000015')
begin
insert into [@ST_LT_CONF] values ('00000015',	'00000015',	'Porte Cobranza', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000016')
begin
insert into [@ST_LT_CONF] values ('00000016',	'00000016',	'Comision Cobranza', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000017')
begin
insert into [@ST_LT_CONF] values ('00000017',	'00000017',	'Interes  Cobranza', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000018')
begin
insert into [@ST_LT_CONF] values ('00000018',	'00000018',	'Garantia Cobranza', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000019')
begin
insert into [@ST_LT_CONF] values ('00000019',	'00000019',	'Cta Pte Emision-CXP', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000020')
begin
insert into [@ST_LT_CONF] values ('00000020',	'00000020',	'Cta Pte Deposito-CXP', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000021')
begin
insert into [@ST_LT_CONF] values ('00000021',	'00000021',	'Cta Pte Retenc', NULL, NULL, NULL)
end
if not exists (select 'e' from [@ST_LT_CONF] where Code='00000022')
begin
insert into [@ST_LT_CONF] values ('00000022',	'00000022',	'Cta Retenc SAP', NULL, NULL, NULL)
end