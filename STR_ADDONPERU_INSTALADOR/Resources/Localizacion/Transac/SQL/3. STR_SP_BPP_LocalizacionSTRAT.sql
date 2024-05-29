CREATE PROCEDURE STR_SP_BPP_LocalizacionSTRAT
@object_type nvarchar(20),
@transaction_type nchar(1),
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255),
@error  int output,
@error_message nvarchar (200) output

as

select @error = 0
select @error_message = N'Ok'

--|||||||||||||||||||||||||||||||||||||||||||||||||||LOCALIZACION STRAT||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

declare @transid int
declare @monto numeric(19,6)
declare @varInt as int
declare @varChar as Varchar(20)

set @varInt=0
set @varChar=''


-- TN para la funcionalidad de Numeración de Documentos ******************************************************************************************************************
if (@object_type in ('13','14','15','16','18','19','203','204','60','67','BPP_ANULCORR') and(@transaction_type = 'A'))
begin 

declare @cc nvarchar(15)
set @cc = (case when @object_type='13' then (select CardCode from OINV where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='14' then (select CardCode from ORIN where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='15' then (select CardCode from ODLN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='16' then (select CardCode from ORDN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='18' then (select CardCode from OPCH where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='19' then (select CardCode from ORPC where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='203' then (select CardCode from ODPI where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='204' then (select CardCode from ODPO where DocEntry=@list_of_cols_val_tab_del)	  
			  when @object_type='60' then (select CardCode from OIGE where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='67' then (select CardCode from OWTR where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='46' then (select CardCode from OVPM where DocEntry=@list_of_cols_val_tab_del)
		end)

declare @tp nvarchar(15)
set @tp = (case when @object_type='13' then (select U_BPP_MDTD from OINV where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='14' then (select U_BPP_MDTD from ORIN where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='15' then (select U_BPP_MDTD from ODLN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='16' then (select U_BPP_MDTD from ORDN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='18' then (select U_BPP_MDTD from OPCH where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='19' then (select U_BPP_MDTD from ORPC where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='203' then (select U_BPP_MDTD from ODPI where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='204' then (select U_BPP_MDTD from ODPO where DocEntry=@list_of_cols_val_tab_del)	  
			  when @object_type='60' then (select U_BPP_MDTD from OIGE where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='67' then (select U_BPP_MDTD from OWTR where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='46' then (select U_BPP_MDTD from OVPM where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='BPP_ANULCORR' then (select U_BPP_DocSnt from "@BPP_ANULCORR" where DocEntry=@list_of_cols_val_tab_del)
		end)
		
declare @sr nvarchar(15)
set @sr = (case when @object_type='13' then (select U_BPP_MDSD from OINV where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='14' then (select U_BPP_MDSD from ORIN where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='15' then (select U_BPP_MDSD from ODLN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='16' then (select U_BPP_MDSD from ORDN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='18' then (select U_BPP_MDSD from OPCH where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='19' then (select U_BPP_MDSD from ORPC where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='203' then (select U_BPP_MDSD from ODPI where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='204' then (select U_BPP_MDSD from ODPO where DocEntry=@list_of_cols_val_tab_del)	  			  
			  when @object_type='60' then (select U_BPP_MDSD from OIGE where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='67' then (select U_BPP_MDSD from OWTR where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='46' then (select U_BPP_PTSC from OVPM where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='BPP_ANULCORR' then (select U_BPP_Serie from "@BPP_ANULCORR" where DocEntry=@list_of_cols_val_tab_del)
		end)

declare @sNumero nvarchar(15)
set @sNumero = (case when @object_type='13' then (select U_BPP_MDCD from OINV where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='14' then (select U_BPP_MDCD from ORIN where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='15' then (select U_BPP_MDCD from ODLN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='16' then (select U_BPP_MDCD from ORDN where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='18' then (select U_BPP_MDCD from OPCH where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='19' then (select U_BPP_MDCD from ORPC where DocEntry=@list_of_cols_val_tab_del)			  
			  when @object_type='203' then (select U_BPP_MDCD from ODPI where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='204' then (select U_BPP_MDCD from ODPO where DocEntry=@list_of_cols_val_tab_del)	  			  
			  when @object_type='60' then (select U_BPP_MDCD from OIGE where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='67' then (select U_BPP_MDCD from OWTR where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='46' then (select U_BPP_PTCC from OVPM where DocEntry=@list_of_cols_val_tab_del)
			  when @object_type='BPP_ANULCORR' then (select U_BPP_NmCorH from "@BPP_ANULCORR" where DocEntry=@list_of_cols_val_tab_del)
		end)

if @object_type in ('13', '14', '15', '16', '203', '60', '67', '46', 'BPP_ANULCORR')
Begin

declare @iNumero int
set @iNumero = convert(int, @sNumero)
set @iNumero = @iNumero + 1
declare @Numero nvarchar(15)
set @Numero = case when len(@sNumero)>=len(CONVERT(nvarchar(15), @iNumero)) then REPLICATE('0', len(@sNumero)-len(CONVERT(nvarchar(15), @iNumero)))+ CONVERT(nvarchar(15), @iNumero) else CONVERT(nvarchar(15), @iNumero) end
		
declare @sNumExist nvarchar(15)
declare @sTipoExist nvarchar(15)

set @sNumExist = (SELECT TOP 1 [DocNum] from (
					select DocNum as 'DocNum' from OINV where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select DocNum as 'DocNum' from ORIN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select DocNum as 'DocNum' from ODLN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select DocNum as 'DocNum' from ORDN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select DocNum as 'DocNum' from ODPI where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL					
					select DocNum as 'DocNum' from OIGE where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select DocNum as 'DocNum' from OWTR where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL				
					select DocNum as 'DocNum' from OVPM where U_BPP_PTCC=@sNumero and ISNULL(U_BPP_PTCC, '')<>'' and U_BPP_PTSC=@sr and ISNULL(U_BPP_PTSC, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					--select Code as 'DocNum' from [@BPP_NROANUL] where U_BPP_TpoDoc='Venta' and U_BPP_Correlativo=@sNumero and ISNULL(U_BPP_Correlativo, '')<>'' and U_BPP_Serie=@sr and ISNULL(U_BPP_Serie, '')<>'' and U_BPP_TpoSUNAT=@tp and ISNULL(U_BPP_TpoSUNAT, '')<>''
					--UNION ALL
					select DocNum as 'DocNum' from [@BPP_ANULCORR] T1 inner join [@BPP_ANULCORRDET] T2 on T1.DocEntry = T2.DocEntry 
						where U_BPP_TpDoc = 'Venta' and U_BPP_NmCr = @sNumero and ISNULL(U_BPP_NmCr,'')<>'' and U_BPP_DocSnt = @tp 
							and  ISNULL(U_BPP_DocSnt,'')<>'' and U_BPP_Serie = @sr and ISNULL(U_BPP_Serie,'') <>'' and T1.DocEntry <> @list_of_cols_val_tab_del 
					) DE)
					
set @sTipoExist = (select top 1 [Tipo] from (
					select ObjType as 'Tipo' from OINV where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from ORIN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from ODLN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from ORDN where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from ODPI where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from OIGE where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					select ObjType as 'Tipo' from OWTR where U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL					
					select ObjType as 'Tipo' from OVPM where U_BPP_PTCC=@sNumero and ISNULL(U_BPP_PTCC, '')<>'' and U_BPP_PTSC=@sr and ISNULL(U_BPP_PTSC, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del
					UNION ALL
					--select 'Anulacion' as 'Tipo' from [@BPP_NROANUL] where U_BPP_TpoDoc='Venta' and U_BPP_Correlativo=@sNumero and ISNULL(U_BPP_Correlativo, '')<>'' and U_BPP_Serie=@sr and ISNULL(U_BPP_Serie, '')<>'' and U_BPP_TpoSUNAT=@tp and ISNULL(U_BPP_TpoSUNAT, '')<>'') 
					--UNION ALL 
					select 'Anulacion' as 'Tipo' from [@BPP_ANULCORR] T1 inner join [@BPP_ANULCORRDET] T2 on T1.DocEntry = T2.DocEntry 
						where U_BPP_TpDoc = 'Venta' and U_BPP_NmCr = @sNumero and ISNULL(U_BPP_NmCr,'')<>'' and U_BPP_DocSnt = @tp 
							and ISNULL(U_BPP_DocSnt,'')<>'' and U_BPP_Serie = @sr and ISNULL(U_BPP_Serie,'') <>'' and T1.DocEntry <> @list_of_cols_val_tab_del
					)TP)

End

if @object_type in ('18', '19', '204')
Begin

set @sNumExist = (select top 1 [DocNum] from (
					select DocNum as 'DocNum' from OPCH where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL
					select DocNum as 'DocNum' from ORPC where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL					
					select DocNum as 'DocNum' from ODPO where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999') DE)					

set @sTipoExist = (select top 1 [Tipo] from (					
					select ObjType as 'Tipo' from OPCH where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL
					select ObjType as 'Tipo' from ORPC where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999'
					UNION ALL					
					select ObjType as 'Tipo' from ODPO where CardCode=@cc and U_BPP_MDCD=@sNumero and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@sr and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@tp and ISNULL(U_BPP_MDTD, '')<>'' and DocEntry<>@list_of_cols_val_tab_del and ISNULL(U_BPP_MDSD, '')<>'999') TP)

End
				  
if ISNULL(@sNumExist, '') = '' or ISNULL(@sTipoExist, '') = ''
begin
	if @object_type in ('13', '14', '15', '16', '203', '60', '67', '46', 'BPP_ANULCORR') 
		and isnull(@sNumero, '')<>''
		and isnull(@tp, '')<>''
		and isnull(@sr, '')<>''
	Begin
	update [@BPP_NUMDOC] set U_BPP_NDCD=@Numero where U_BPP_NDTD=@tp and U_BPP_NDSD=@sr
	end
end
else
begin
	SET @error=1
	SET @error_message='Ya existe un registro con el mismo número de la serie elegida para este tipo de documento (DocEntry: ' + @sNumExist + ' ObjType: ' + @sTipoExist + ')'
end

end

--***********************************************************************************************************************************************************************

--***********************************************************************************************************************************************************************


--Manejo de Anulación de Documentos *************************************************************************************************************************************

-- Al anular la factura con una NC debe mostrar anulado
IF @object_type = '14' AND (@transaction_type = 'A' or @transaction_type = 'U')
BEGIN
UPDATE OINV 
SET NumAtCArd = '***ANULADO***', Indicator='ZA'
WHERE DocEntry = (Select top 1 T2.DocEntry FROM OINV T2 inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' and T1.BaseType='13' AND
T3.docentry =@list_of_cols_val_tab_del) 

UPDATE ODPI 
SET NumAtCArd = '***ANULADO***', Indicator='ZA'
WHERE DocEntry = (Select top 1 T2.DocEntry FROM ODPI T2 inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' and T1.BaseType='203' AND
T3.docentry =@list_of_cols_val_tab_del) 


UPDATE OJDT 
SET Ref2 = '***ANULADO***'
WHERE TransID = (Select top 1 T2.TransID FROM OINV T2 inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' and T1.BaseType='13' AND
T3.docentry =@list_of_cols_val_tab_del)

UPDATE OJDT 
SET Ref2 = '***ANULADO***'
WHERE TransID = (Select top 1 T2.TransID FROM ODPI T2 inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' and T1.BaseType='203' AND
T3.docentry =@list_of_cols_val_tab_del)

-- Modifica el campo NumAtCArd cuando la NC es anulado
update ORIN 
set NumAtCArd = '***ANULADO***'
where U_BPP_MDSD ='999'and Docentry=@list_of_cols_val_tab_del 

END


IF @object_type = '16' AND (@transaction_type = 'A' or @transaction_type = 'U')
BEGIN
UPDATE ODLN 
SET NumAtCArd = '***ANULADO***'
WHERE DocEntry = (Select top 1 T2.DocEntry FROM ODLN T2 inner join RDN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORDN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' AND
T3.docentry =@list_of_cols_val_tab_del) 


UPDATE OJDT 
SET Ref2 = '***ANULADO***'
WHERE TransID = (Select top 1 T2.TransID FROM ODLN T2 inner join RDN1 T1 ON T2.docentry= T1.BaseEntry 
INNER JOIN ORDN T3 ON T3.DocEntry = T1.DocEntry
where T3.U_BPP_MDSD ='999' AND
T3.docentry =@list_of_cols_val_tab_del)


-- Modifica el campo NumAtCArd cuando la NC es anulado
update ORDN 
set NumAtCArd = '***ANULADO***'
where U_BPP_MDSD ='999'and Docentry=@list_of_cols_val_tab_del 

END

---COMPRAS
--Muestra Anulado cuando a la Fact se genera una Nota de credito 
IF @object_type = '19' AND (@transaction_type = 'A' or @transaction_type = 'U')
BEGIN
      -- Al anular la factura con una NC debe mostrar anulado
            UPDATE OPCH 
            SET   NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator='ZA'
            WHERE DocEntry = (Select top 1 T2.DocEntry FROM OPCH T2 inner join RPC1 T1 ON T2.docentry= T1.BaseEntry 
                 INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
            where T3.U_BPP_MDTD ='NC' AND T1.BaseType='18' AND
            T3.docentry =@list_of_cols_val_tab_del) 
            
            UPDATE ODPO 
            SET   NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator='ZA'
            WHERE DocEntry = (Select top 1 T2.DocEntry FROM ODPO T2 inner join RPC1 T1 ON T2.docentry= T1.BaseEntry 
                 INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
            where T3.U_BPP_MDTD ='NC' AND T1.BaseType='204' AND
            T3.docentry =@list_of_cols_val_tab_del) 
            
            UPDATE OJDT 
            SET Ref2  = '***ANULADO***'
            WHERE TransID = (Select top 1 T2.TransID FROM OPCH T2 inner join RPC1 T1 ON T2.docentry= T1.BaseEntry 
                 INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
            where T3.U_BPP_MDTD ='NC' AND T1.BaseType='18' AND
            T3.docentry =@list_of_cols_val_tab_del)
            
            UPDATE OJDT 
            SET Ref2  = '***ANULADO***'
            WHERE TransID = (Select top 1 T2.TransID FROM ODPO T2 inner join RPC1 T1 ON T2.docentry= T1.BaseEntry 
                 INNER JOIN ORPC T3 ON T3.DocEntry = T1.DocEntry
            where T3.U_BPP_MDTD ='NC' AND T1.BaseType='204' AND
            T3.docentry =@list_of_cols_val_tab_del)

-- Modifica el campo NumAtCArd cuando la NC es anulado
            update ORPC 
            set NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL'
            where U_BPP_MDTD ='NC' and Docentry=@list_of_cols_val_tab_del 

END

--Actualiza campos de documentos de Origen 
IF @object_type = '14' AND (@transaction_type = 'A' or @transaction_type = 'U')
BEGIN
	UPDATE ORIN SET 
	U_BPP_MDCO=
		case (select top 1 BaseType From RIN1 where DocEntry=@list_of_cols_val_tab_del)
			when '13' then
				(SELECT TOP 1 
				 T2.U_BPP_MDCD
				 FROM OINV T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				 where T3.docentry =@list_of_cols_val_tab_del ) 
			when '203' then
				(SELECT TOP 1 
				 T2.U_BPP_MDCD
				 FROM ODPI T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				 where T3.docentry =@list_of_cols_val_tab_del ) 
			end		

	 ,U_BPP_MDSO=
		case (select top 1 BaseType From RIN1 where DocEntry=@list_of_cols_val_tab_del)
			when '13' then
				(SELECT TOP 1 
				T2.U_BPP_MDSD
				FROM OINV T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del ) 
			when '203' then
				(SELECT TOP 1 
				T2.U_BPP_MDSD
				FROM ODPI T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del ) 
			end			
		
	 ,U_BPP_MDTO=
		case (select top 1 BaseType From RIN1 where DocEntry=@list_of_cols_val_tab_del)
			when '13' then
				(	
				SELECT TOP 1 
				T2.U_BPP_MDTD
				FROM OINV T2 
	    				inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del ) 
			when '203' then
				(	
				SELECT TOP 1 
				T2.U_BPP_MDTD
				FROM ODPI T2 
	    				inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del ) 
			end
						
	,U_BPP_SDocDate=
		case (select top 1 BaseType From RIN1 where DocEntry=@list_of_cols_val_tab_del)
			when '13' then
						(	
				SELECT TOP 1 T2.DocDate
				FROM OINV T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del )
			when '203' then
						(	
				SELECT TOP 1 T2.DocDate
				FROM OINV T2 
						inner join RIN1 T1 ON T2.docentry= T1.BaseEntry 
						INNER JOIN ORIN T3 ON T3.DocEntry = T1.DocEntry
				where T3.docentry =@list_of_cols_val_tab_del )
			end		 
	 WHERE docentry =@list_of_cols_val_tab_del AND U_BPP_MDTD='07'
	   and isnull((select top 1 BaseType From RIN1 where DocEntry=@list_of_cols_val_tab_del), '-1')<>'-1'
	 
END

IF @object_type = '13' AND (@transaction_type = 'C')
BEGIN
	UPDATE OINV 
	SET NumAtCArd = '***ANULADO***', Indicator='ZA'
	where DocEntry=@list_of_cols_val_tab_del
	
	UPDATE OJDT 
	SET Ref2 = '***ANULADO***'
	WHERE TransID = (Select top 1 TransID FROM OINV where DocEntry = @list_of_cols_val_tab_del)
END

IF @object_type = '203' AND (@transaction_type = 'C')
BEGIN
	UPDATE ODPI 
	SET NumAtCArd = '***ANULADO***', Indicator='ZA'
	WHERE DocEntry =@list_of_cols_val_tab_del

	UPDATE OJDT 
	SET Ref2 = '***ANULADO***'
	WHERE TransID = (Select top 1 TransID FROM ODPI where DocEntry = @list_of_cols_val_tab_del)
END

IF @object_type = '14' AND (@transaction_type = 'C')
BEGIN
	update ORIN 
	set NumAtCArd = '***ANULADO***'
	where U_BPP_MDSD ='999'and Docentry=@list_of_cols_val_tab_del 
END

IF @object_type = '15' AND (@transaction_type = 'C')
BEGIN
	UPDATE ODLN 
	SET NumAtCArd = '***ANULADO***'
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT 
	SET Ref2 = '***ANULADO***'
	WHERE TransID = (Select top 1 TransID FROM ODLN where DocEntry= @list_of_cols_val_tab_del)
END

IF @object_type = '16' AND (@transaction_type = 'C') 
BEGIN
	update ORDN 
	set NumAtCArd = '***ANULADO***'
	where U_BPP_MDSD ='999'and Docentry=@list_of_cols_val_tab_del
END 

IF @object_type = '18' AND (@transaction_type = 'C') 
BEGIN
	UPDATE OPCH 
	SET   NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator='ZA'
	WHERE DocEntry =@list_of_cols_val_tab_del
	
	 UPDATE OJDT 
     SET Ref2  = '***ANULADO***'
     WHERE TransID = (Select top 1 TransID FROM OPCH where docentry =@list_of_cols_val_tab_del)
END	

IF @object_type = '204' AND (@transaction_type = 'C') 
BEGIN            
	UPDATE ODPO 
	SET   NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL', Indicator='ZA'
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	 UPDATE OJDT 
     SET Ref2  = '***ANULADO***'
     WHERE TransID = (Select top 1 TransID FROM ODPO where docentry= @list_of_cols_val_tab_del)
END

IF @object_type = '19' AND (@transaction_type = 'C')
BEGIN
	   update ORPC 
       set NumAtCArd = '***ANULADO***', U_BPP_MDSD = 'ANL'
       where U_BPP_MDTD ='NC' and Docentry=@list_of_cols_val_tab_del 
END





--=========================================
-- DOCUMENTO REFERENCIA 01.04.16
--=========================================
--FACTURA VENTA
IF @object_type = '13' and (@transaction_type = 'A' OR @transaction_type = 'U')
BEGIN
	UPDATE OINV SET NumAtCard = ISNULL(U_BPP_MDTD,'') + '-' + ISNULL( U_BPP_MDSD,'') + '-' + ISNULL( U_BPP_MDCD,''),
	FolioNum = ''
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT SET Ref2 = ISNULL(B.U_BPP_MDTD,'') + '-' + ISNULL(B.U_BPP_MDSD,'') + '-' + ISNULL(B.U_BPP_MDCD,'')
	FROM OJDT A INNER JOIN OINV B ON A.TransId = B.TransId
	WHERE B.DocEntry = @list_of_cols_val_tab_del
	
END
--NOTA CREDITO VENTA
IF @object_type = '14' and (@transaction_type = 'A' OR @transaction_type = 'U')
BEGIN
	UPDATE ORIN SET NumAtCard = ISNULL(U_BPP_MDTD,'') + '-' + ISNULL(U_BPP_MDSD,'') + '-' + ISNULL(U_BPP_MDCD,''),
	FolioNum = ''
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT SET Ref2 = ISNULL(B.U_BPP_MDTD,'') + '-' + ISNULL(B.U_BPP_MDSD,'') + '-' + ISNULL(B.U_BPP_MDCD,'')
	FROM OJDT A INNER JOIN ORIN B ON A.TransId = B.TransId
	WHERE B.DocEntry = @list_of_cols_val_tab_del
	
END
--GUIA DE REMISION VENTA
IF @object_type = '15' and (@transaction_type = 'A' OR @transaction_type = 'U')
BEGIN
	UPDATE ODLN SET NumAtCard = ISNULL( U_BPP_MDTD,'') + '-' + ISNULL( U_BPP_MDSD,'') + '-' + ISNULL( U_BPP_MDCD,'')
	,FolioNum = ''
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT SET Ref2 = ISNULL( B.U_BPP_MDTD,'') + '-' + ISNULL( B.U_BPP_MDSD,'') + '-' + ISNULL( B.U_BPP_MDCD,'')
	FROM OJDT A INNER JOIN ODLN B ON A.TransId = B.TransId
	WHERE B.DocEntry = @list_of_cols_val_tab_del
	
END
--FACTURA PROVEEDORES
IF @object_type = '18' and (@transaction_type = 'A' OR @transaction_type = 'U')
BEGIN
	UPDATE OPCH SET NumAtCard = ISNULL( U_BPP_MDTD,'') + '-' + ISNULL(U_BPP_MDSD,'') + '-' + ISNULL(U_BPP_MDCD,'')
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT SET Ref2 = ISNULL( B.U_BPP_MDTD,'') + '-' + ISNULL(B.U_BPP_MDSD,'') + '-' + ISNULL(B.U_BPP_MDCD,'')
	FROM OJDT A INNER JOIN OPCH B ON A.TransId = B.TransId
	WHERE B.DocEntry = @list_of_cols_val_tab_del
END
--NOTA CREDITO PROVEEDORES
IF @object_type = '19' and (@transaction_type = 'A' OR @transaction_type = 'U')
BEGIN
	UPDATE ORPC SET NumAtCard = ISNULL( U_BPP_MDTD,'') + '-' + ISNULL( U_BPP_MDSD,'') + '-' + ISNULL( U_BPP_MDCD,'')
	WHERE DocEntry = @list_of_cols_val_tab_del
	
	UPDATE OJDT SET Ref2 = ISNULL( B.U_BPP_MDTD,'') + '-' + ISNULL( B.U_BPP_MDSD,'') + '-' + ISNULL( B.U_BPP_MDCD,'')
	FROM OJDT A INNER JOIN ORPC B ON A.TransId = B.TransId
	WHERE B.DocEntry = @list_of_cols_val_tab_del
	
END


--=========================================
-- FIN DOCUMENTO REFERENCIA
--=========================================

--***********************************************************************************************************************************************************************
--- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
--Validacion para el ingreso de documentos por socio de negocio

IF @object_type in ('18') AND @transaction_type = 'A'
begin
	SELECT @varChar=T0.CardCode FROM OPCH T0 WHERE T0.DocEntry=@list_of_cols_val_tab_del	
	
	SELECT @varInt= COUNT(*)from opch T0 
	WHERE T0.DocEntry=@list_of_cols_val_tab_del 
		and (CAST(T0.CardCode AS VARCHAR(20))+T0.U_BPP_MDTD+RIGHT(REPLICATE('0',5)+CAST(T0.U_BPP_MDSD AS VARCHAR(5)),5)+RIGHT(REPLICATE('0',15)+CAST(T0.U_BPP_MDCD AS VARCHAR(15)),15)) 
				IN (SELECT CAST(T1.CardCode AS VARCHAR(20))+T1.U_BPP_MDTD+RIGHT(REPLICATE('0',5)+CAST(T1.U_BPP_MDSD AS VARCHAR(5)),5)+RIGHT(REPLICATE('0',15)+CAST(T1.U_BPP_MDCD AS VARCHAR(15)),15) 
				    FROM OPCH T1 
				    WHERE T1.DocEntry!=@list_of_cols_val_tab_del and T1.CardCode=@varChar)
				    
				    
	IF (@varInt>0)
	BEGIN
		SET @error=1
		SET @error_message='Este Nro de Documento ya fue registrado'+cast(@varInt as varchar(5))+@varChar
	END
end

--* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
--***********************************************************************************************************************************************************************

--Detraccion *************************************************************************************************************************************

if @object_type in ('19') AND @transaction_type = 'A'
begin

declare @astDetracTransId as nvarchar(15)
declare @cardCode as nvarchar(50)

set @astDetracTransId = (select top 1 U_BPP_AstDetrac 
						 from OPCH 
						 where DocEntry = (select top 1 BaseEntry 
										   from RPC1 
										   where DocEntry=@list_of_cols_val_tab_del))
										   
set @cardCode = (select CardCode from ORPC where DocEntry=@list_of_cols_val_tab_del)

if (select sum(BalDueDeb + BalDueCred) from JDT1 where TransId=@astDetracTransId and ShortName=@cardCode) <> 
	(select sum(Debit + Credit) from JDT1 where TransId=@astDetracTransId and ShortName=@cardCode)
	begin
	SET @error=1
	SET @error_message='Debe anular el pago efectuado al asiento de detracción de la factura que se desea anular'
	end

end

if @object_type in ('18, 19, 204') AND @transaction_type = 'A'
begin

declare @crdCode as nvarchar(50)
set @crdCode = (case @object_type when '18' then (select top 1 CardCode from OPCH where DocEntry=@list_of_cols_val_tab_del)
								  when '19' then (select top 1 CardCode from ORPC where DocEntry=@list_of_cols_val_tab_del)
								  when '204' then (select top 1 CardCode from ODPO where DocEntry=@list_of_cols_val_tab_del) end)

declare @ctaDetrac as nvarchar(50)

declare @Detrac as int
set @Detrac = (case @object_type when '18' then (select top 1 Count(WTCode) from PCH5 where WTCode like 'DT%' and AbsEntry=@list_of_cols_val_tab_del)
								 when '19' then (select top 1 Count(WTCode) from RPC5 where WTCode like 'DT%' and AbsEntry=@list_of_cols_val_tab_del)
								 when '204' then (select top 1 Count(WTCode) from DPO5 where WTCode like 'DT%' and AbsEntry=@list_of_cols_val_tab_del) end)

if @Detrac> 0
	begin
	set @ctaDetrac = (select top 1 isnull(U_BPP_CtaDetrac, '') from OCRD where CardCode=@crdCode)
	
	if isnull(@ctaDetrac, '')=''
		begin
			SET @error=1
			SET @error_message='No se ha definido la cuenta asociada de Detracciones para el socio de negocio.'
		end	
	end
	
	if (select top 1 LocManTran from OACT where FormatCode=@ctaDetrac) = 'N'
		begin
			SET @error=1
			SET @error_message='La cuenta del socio de negocio definida para el asiento de detracción no es una cuenta asociada.'
		end

end

--if @object_type in ('30') AND (@transaction_type = 'A' or @transaction_type = 'U')
--begin

--	declare @JrnlRef1 nvarchar(50)
--	declare @JrnlRef2 nvarchar(50)
	
--	set @JrnlRef1 = (select top 1 ref1 from OJDT where TransId=@list_of_cols_val_tab_del)
--	set @JrnlRef2 = (select top 1 Ref2 from OJDT where TransId=@list_of_cols_val_tab_del)
	
--	if exists (select 'DTR' from OJDT where TransCode='DTR' and Ref1=@JrnlRef1 and Ref2=@JrnlRef2 and TransId<>@list_of_cols_val_tab_del)
--	begin
--		SET @error=1
--		SET @error_message='Ya ha sido creado un asiento de detracción con las mismas referencias.'
--	end

--end

--************************************************************************************************************************************************
--Pagos *************************************************************************************************************************************
	
	declare @trsfr as nvarchar(10)
	declare @check as nvarchar(10)
	declare @idNum as nvarchar(20)
	
	set @idNum=''
	
	--Medios de Pago SUNAT para el asistente de pago * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	IF @object_type = '46' AND (@transaction_type = 'A' or @transaction_type = 'U')
	begin
		
		--if exists (select 'E' from OPWZ T0, OVPM T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)

		if (select COUNT('Z') from OVPM T0 where T0.Status='N' and DocEntry=@list_of_cols_val_tab_del)=0
		begin
		  set @idNum= (select top 1 t1.PaymWizCod from OVPM t0 inner join OPEX t1 on t0.DocEntry=T1.PaymDocNum where t0.DocEntry=@list_of_cols_val_tab_del)
						--(select T0.IdNumber from OPWZ T0, OVPM T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)
		  set @trsfr = (select top 1 T0.U_BPP_TRAN from OPWZ T0 where T0.IdNumber=@idNum)
		  set @check = (select top 1 T0.U_BPP_CHEQ from OPWZ T0 where T0.IdNumber=@idNum)
		  UPDATE OVPM set U_BPP_MPPG=CASE when TrsfrSum >0 then @trsfr when CheckSum > 0 then @check else '000' end where DocEntry=@list_of_cols_val_tab_del
				  
		end	
		
	end 	
	
	IF @object_type = '24' AND (@transaction_type = 'A' or @transaction_type = 'U')
	begin
	
		if exists (select 'E' from OPWZ T0, ORCT T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)
		begin
		  set @idNum=(select T0.IdNumber from OPWZ T0, OVPM T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)
		  set @trsfr = (select top 1 T0.U_BPP_TRAN from OPWZ T0 where T0.IdNumber=@idNum)
		  set @check = (select top 1 T0.U_BPP_CHEQ from OPWZ T0 where T0.IdNumber=@idNum)
		  UPDATE ORCT set U_BPP_MPPG=CASE when TrsfrSum >0 then @trsfr when CheckSum > 0 then @check else '000' end where DocEntry=@list_of_cols_val_tab_del
		  
		end	
	
	end 	
	
	DECLARE @R1 VARCHAR(30)
	
	IF @object_type = '46' AND (@transaction_type = 'A' or @transaction_type = 'U')
	begin
		
		--if not exists (select 'E' from OPWZ T0, OVPM T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)
		if (select Count('Z') from OVPM where Status='Y' and DocEntry=@list_of_cols_val_tab_del)=0
		begin
		  
		  SET @R1 = (SELECT count(*) FROM OVPM T0 
			WHERE T0.U_BPP_MPPG ='000' and t0.datasource <> 'O'/*OR T0.Indicator <>'01'*/ AND T0.DocEntry = @list_of_cols_val_tab_del)
			
			  IF @R1 > 0 		  
			  BEGIN 
			  SET @error=1
			  SET @error_message='STR_A: Ingrese el Medio de Pago SUNAT.'
			  END
		  
		end	
		
	end 	
	
	IF @object_type = '24' AND (@transaction_type = 'A' or @transaction_type = 'U')
	begin
	
		if not exists (select 'E' from OPWZ T0, ORCT T1 where T1.JrnlMemo like ('%' + T0.WizardName) and T1.DocEntry=@list_of_cols_val_tab_del)
		begin
		  
		  SET @R1 = (SELECT count(*) FROM ORCT T0 
			WHERE T0.U_BPP_MPPG ='000'  and t0.datasource<> 'O'/*OR T0.Indicator <>'01'*/ AND T0.DocEntry = @list_of_cols_val_tab_del)
			 IF @R1 > 0 
			 BEGIN 
			 SET @error=1
			 SET @error_message='STR_A: Ingrese el Medio de Pago SUNAT'		 
			 END
		  
		end	
	
	end 	
	
	-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * Medios de Pago SUNAT para el asistente de pago
	
--************************************************************************************************************************************* Pagos 


-- Pago Masivo de Detracciones * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	-- 21052013 - 1129 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	declare @fecDP varchar(10)
	--IF @object_type = 'BPP_PAYDTR' AND(@transaction_type='A')
	--begin
	--	set @fecDP  = (select TOP 1 U_BPP_FcDp from [@BPP_PAYDTR] where DocEntry=@list_of_cols_val_tab_del) 
	--	if ISNULL(@fecDP ,'')=''
	--	begin
	--		set @error = 1
	--		set @error_message = 'Ingrese fecha de deposito'
	--	end
	--end 
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	declare @codprov varchar(10)	
	--IF @object_type = 'BPP_PAYDTR' AND(@transaction_type='A' )
	--begin
	--	set @codprov = (select TOP 1 U_BPP_CgPv from [@BPP_PAYDTRDET] where DocEntry=@list_of_cols_val_tab_del) 
	--	if ISNULL(@codprov,'')=''
	--	begin
	--		set @error = 1
	--		set @error_message = 'No se ha generado ningun pago. No se puede registrar la ejecucion'
	--	end		
	--end 	
	
	-- 21052013 - 1050 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
	declare @FecDeps datetime
	declare @NumDeps Nvarchar(20)
	declare @CdgPvdr varchar(40)
	declare @nmatcar varchar(40)
	IF @object_type = 'BPP_PAYDTR' AND(@transaction_type='U' )
	begin	
		if (select top 1 Status from [@BPP_PAYDTR] where DocEntry=@list_of_cols_val_tab_del)='C'
		begin
			set @FecDeps = (select top 1 U_BPP_FcDp from [@BPP_PAYDTR] where DocEntry=@list_of_cols_val_tab_del)
			--set @NumDeps = (select top 1 U_BPP_NmPg from [@BPP_PAYDTRDET] where DocEntry=@list_of_cols_val_tab_del)
			declare CUR_UpdateOPCHNmCnst cursor
			for	select distinct U_BPP_CgPv,U_BPP_NmDc,U_BPP_Cnst from [@BPP_PAYDTRDET] where DocEntry=@list_of_cols_val_tab_del
			open CUR_UpdateOPCHNmCnst
			fetch next from CUR_UpdateOPCHNmCnst into @CdgPvdr,@nmatcar,@NumDeps
			while @@FETCH_STATUS = 0
			begin 
			update OPCH set
				U_BPP_DPFC=@FecDeps,
				U_BPP_DPNM=@NumDeps--(SELECT top 1 U_BPP_Cnst FROM [@BPP_PAYDTRDET] WHERE U_BPP_NmDc=OPCH.NumAtCard and U_BPP_CgPv=OPCH.CardCode)
				where DocEntry in (select T1.U_BPP_DocKeyDest From [@BPP_PAYDTRDET] T0 inner join OJDT T1 on T0.U_BPP_DEAs=T1.TransId where T0.DocEntry=@list_of_cols_val_tab_del and T1.U_BPP_CtaTdoc='18')
				and OPCH.CardCode = @CdgPvdr and OPCH.NumAtCard = @nmatcar
				fetch next from CUR_UpdateOPCHNmCnst into @CdgPvdr,@nmatcar,@NumDeps
			end
			close CUR_UpdateOPCHNmCnst
			deallocate CUR_UpdateOPCHNmCnst
			update ORPC set U_BPP_DPFC=@FecDeps, U_BPP_DPNM=@NumDeps where DocEntry in (select T1.U_BPP_DocKeyDest From [@BPP_PAYDTRDET] T0 inner join OJDT T1 on T0.U_BPP_DEAs=T1.TransId where T0.DocEntry=@list_of_cols_val_tab_del and T1.U_BPP_CtaTdoc='19')
			update ODPO set U_BPP_DPFC=@FecDeps, U_BPP_DPNM=@NumDeps where DocEntry in (select T1.U_BPP_DocKeyDest From [@BPP_PAYDTRDET] T0 inner join OJDT T1 on T0.U_BPP_DEAs=T1.TransId where T0.DocEntry=@list_of_cols_val_tab_del and T1.U_BPP_CtaTdoc='204')
		end
	end
	
	-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 	
	
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 



-- * *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- Validaciones Anulacion de Correlativos SUNAT
declare @docsunat varchar(20)
declare @seriesunat varchar(20)
declare @fechanul datetime

	IF @object_type = 'BPP_ANULCORR' AND(@transaction_type='A' or @transaction_type='U')
	begin 
		set @docsunat = (select top 1 U_BPP_DocSnt from [@BPP_ANULCORR] where DocEntry = @list_of_cols_val_tab_del) 
		set @seriesunat = (select top 1 U_BPP_Serie from [@BPP_ANULCORR] where DocEntry = @list_of_cols_val_tab_del)
		set @fechanul = (select TOP 1 U_BPP_FchAnl from [@BPP_ANULCORR] where DocEntry=@list_of_cols_val_tab_del)
		if ISNULL(@fechanul,'')=''
			begin
				set @error = 1
			set @error_message = 'Debe ingresar la fecha de anulacion'
			end
	end 
	
declare @ufchanl datetime
	IF @object_type = 'BPP_ANULCORR' AND(@transaction_type='A' or @transaction_type='U')
	begin 
		set @ufchanl = (select top 1 U_BPP_FchAnl  from [@BPP_ANULCORR] where DocEntry <>@list_of_cols_val_tab_del order by U_BPP_FchAnl desc)
		if (@fechanul < @ufchanl)
		begin
			set @error = 1
			set @error_message = 'La fecha de anulación no puede ser menor a la última fecha de anulación registrada para este tipo y serie de documento'
		end 
	end
	
declare @numcorD varchar(10)
declare @numcorH varchar(10)
declare @ultcorr varchar(10)
	IF @object_type = 'BPP_ANULCORR' AND(@transaction_type='A' or @transaction_type='U')
	begin
		set @numcorD = (select TOP 1 U_BPP_NmCorD from [@BPP_ANULCORR] where DocEntry=@list_of_cols_val_tab_del) 
		set @numcorH = (select Top 1 U_BPP_NmCorH from [@BPP_ANULCORR] where DocEntry=@list_of_cols_val_tab_del)
		set @ultcorr = (select  U_BPP_NDCD from [@BPP_NUMDOC] where U_BPP_NDTD = @docsunat and U_BPP_NDSD = @seriesunat)
		if @numcorH < @numcorD 
		begin
			set @error = 1
			set @error_message = 'El número correlativo Desde no puede ser mayor al número correlativo Hasta'
		end
		else if((ISNULL(@numcorD,'')='') or (ISNULL(@numcorH,'')=''))
		begin
			set @error = 1
			set @error_message = 'Debe ingresar el numero correlativo SUNAT' 
		end
		else if ((LEN(@numcorD)<LEN(@ultcorr))or (LEN(@numcorH)<LEN(@ultcorr)))
		begin
			set @error = 1
			set @error_message = 'La longitud de los números correlativos no puede ser menor a la longitud de los números correlativos usados por esta serie y por este tipo de documento'
		end
	end 
declare @serie varchar(10)
	IF @object_type = 'BPP_ANULCORR' AND(@transaction_type='A' or @transaction_type='U')
	begin 
		set @serie = (select TOP 1 U_BPP_Serie from [@BPP_ANULCORR] where DocEntry=@list_of_cols_val_tab_del)
		if ISNULL(@serie,'')=''
			begin
				set @error = 1
				set @error_message = 'Debe ingresar la serie SUNAT'
			end
	end
declare @tpodocSUNAT varchar(10)
	IF @object_type = 'BPP_ANULCORR' AND(@transaction_type='A' or @transaction_type='U')
	begin 
		set @tpodocSUNAT = (select TOP 1 U_BPP_DocSnt from [@BPP_ANULCORR] where DocEntry=@list_of_cols_val_tab_del)
		if ISNULL(@tpodocSUNAT,'')=''
			begin
				set @error = 1
			set @error_message = 'Debe ingresar el tipo de documento SUNAT'
			end
	end 

declare @corrD varchar(20)
declare @corrH varchar(20)
declare @numcorr varchar(20)
declare @docnum varchar(20)
declare @numcif int
if @object_type = 'BPP_ANULCORR' AND (@transaction_type='A' or @transaction_type='U')
begin
	select @corrD = U_BPP_NmCorD ,@corrH=U_BPP_NmCorH from [@BPP_ANULCORR] where DocEntry = @list_of_cols_val_tab_del
	set @numcif = LEN(@corrD)
	while  CONVERT(int,@corrD) <= CONVERT(int,@corrH)
	begin
		set @numcorr = right('0000000000'+ltrim(cast(@corrD as int)),@numcif)
		set @docnum = (select top 1 [DocNum] from (
					select DocNum as 'DocNum' from OINV where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from ORIN where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from ODLN where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from ORDN where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from ODPI where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL					
					select DocNum as 'DocNum' from OIGE where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from OWTR where U_BPP_MDCD=@numcorr and ISNULL(U_BPP_MDCD, '')<>'' and U_BPP_MDSD=@seriesunat and ISNULL(U_BPP_MDSD, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL				
					select DocNum as 'DocNum' from OVPM where U_BPP_PTCC=@numcorr and ISNULL(U_BPP_PTCC, '')<>'' and U_BPP_PTSC=@seriesunat and ISNULL(U_BPP_PTSC, '')<>'' and U_BPP_MDTD=@docsunat and ISNULL(U_BPP_MDTD, '')<>''
					UNION ALL
					select Code as 'DocNum' from [@BPP_NROANUL] where U_BPP_TpoDoc='Venta' and U_BPP_Correlativo=@numcorr and ISNULL(U_BPP_Correlativo, '')<>'' and U_BPP_Serie=@seriesunat and ISNULL(U_BPP_Serie, '')<>'' and U_BPP_TpoSUNAT=@docsunat and ISNULL(U_BPP_TpoSUNAT, '')<>''
					UNION ALL
					select DocNum as 'DocNum' from [@BPP_ANULCORR] T1 inner join [@BPP_ANULCORRDET] T2 on
					T1.DocEntry = T2.DocEntry where U_BPP_TpDoc = 'Venta' and U_BPP_NmCr = @numcorr and ISNULL(U_BPP_NmCr,'')<>'' and U_BPP_DocSnt = @docsunat and 
					ISNULL(U_BPP_DocSnt,'')<>'' and U_BPP_Serie = @seriesunat and ISNULL(U_BPP_Serie,'') <>'' and T1.DocEntry <> @list_of_cols_val_tab_del) DC)
		if (ISNULL(@docnum,'')<>'')
		begin
			break
		end
	set @corrD +=1
	end 
	if (ISNULL(@docnum,'')<>'')
	begin
		set @error = 1
		set @error_message = 'No es posible anular el número '+@docsunat+' - '+@serie+' - '+@numcorr+' porque este ya se encuentra registrado en un documento del sistema o ya está anulado'
	end
end


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

-- Percepcion - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

--if @object_type = '24' and (@transaction_type ='C') 
--begin

--	if (select isnull(U_BPP_AsPc, '') from ORCT where DocEntry=@list_of_cols_val_tab_del)<>''
--	begin

--		if (select count('C') from OJDT where StornoToTr=(select isnull(U_BPP_AsPc, '') from ORCT where DocEntry=@list_of_cols_val_tab_del))=0
--		begin
			
--			SET @error_message = 'Antes de cancelar el pago, debe anular el asiento de percepcion'
--			SET @error = 1

--		end

--	end

--end

-- Fin de Percepcion - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
--//= == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == = 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - -PICKING - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
--Actualiza las cantidades de un picking abierto o liberado si se realiza una entrada de mercancias
--IF @object_type = 'BPP_DOCPKNG' and ( @transaction_type = 'U')
--BEGIN
--	update T1 set T1.U_PKN_DSLB = T0.OnHand from OITW T0 inner join [@BPP_DOCPKNGDET] T1
--	on T0.ItemCode = T1.U_PKN_NMAR and T0.WhsCode = T1.U_PKN_ALMC inner join [@BPP_DOCPKNG] T2
--	on T1.DocEntry = T2.DocEntry where T2.U_PKN_ESTD ='AB' or T2.U_PKN_ESTD = 'LB' and T2.DocEntry = @list_of_cols_val_tab_del
------ actualiza la variacion de stock de articulos que  son de produccion 
--	update [@BPP_DOCPKNGDET] set U_PKN_DSLB = (select MIN(TX2.OnHand/Quantity) FROM OITT TX0 inner join ITT1 TX1 ON TX0.Code = TX1.Father
--					 inner join OITW TX2 on TX1.Code = TX2.itemcode where TX0.Code = T2.Code   and TX2.WhsCode = T0.U_PKN_ALMC
--					 ) from  [@BPP_DOCPKNGDET] T0
--					  inner join [@BPP_DOCPKNG] T1 on T0.DocEntry = T1.DocEntry
--					  inner join [OITT] T2 on T2.Code  =  T0.U_PKN_NMAR
--					  inner join [ITT1] T3 on T2.Code = T3.Father
--					  inner join [OITW] T4 on T3.Code = T4.ItemCode and T0.U_PKN_ALMC = T4.WhsCode
-- 					  where T1.DocEntry = @list_of_cols_val_tab_del
--END
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
--= == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
fin:
--|||||||||||||||||||||||||||||||||||||||||||||||||||FIN LOCALIZACION STRAT||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

select @error, @error_message