CREATE PROCEDURE STR_SP_BPP_LOCDETRACCIONES
(
	IN object_type nvarchar(20),
	IN transaction_type nchar(1),
	IN list_of_cols_val_tab_del nvarchar(255),
	OUT error INTEGER,
 	OUT error_message NVARCHAR(200)
)
AS
astDetracTransId nvarchar(15);
cardCode nvarchar(50);
crdCode nvarchar(50);
ctaDetrac nvarchar(50);
Detrac integer;
Suma1 double;
Suma2 double;

v_BaseEntry nvarchar(50);
v_LocManTran nvarchar(10);
BEGIN
	IF :object_type = '19' AND :transaction_type = 'A' THEN
	
	 	SELECT(select top 1 "BaseEntry" from RPC1 
				where "DocEntry"=:list_of_cols_val_tab_del) INTO v_BaseEntry FROM DUMMY;	
												   
		SELECT (select top 1 "U_BPP_AstDetrac" from OPCH 
		where "DocEntry" = :v_BaseEntry)INTO astDetracTransId FROM DUMMY;  		
		
		SELECT(select "CardCode" from ORPC where "DocEntry"=:list_of_cols_val_tab_del) INTO cardCode FROM DUMMY;
	
		SELECT(select sum("BalDueDeb" + "BalDueCred") from JDT1 where "TransId"=:astDetracTransId and "ShortName"=:cardCode)INTO Suma1 FROM DUMMY;
		SELECT(select sum("Debit" + "Credit") from JDT1 where "TransId"=:astDetracTransId and "ShortName"=:cardCode)INTO Suma2 FROM DUMMY;
		
		IF :Suma1 <> :Suma2	THEN
			error :=1;
			error_message := 'Debe anular el pago efectuado al asiento de detracción de la factura que se desea anular';
		END IF;
	   
	END IF;
	
	-------2DA PARTE

	IF (:object_type = '18' OR
		:object_type = '19' OR
		:object_type = '204') AND 
		:transaction_type = 'A'
	THEN
	
		SELECT(case :object_type when '18' then (select top 1 "CardCode" from OPCH where "DocEntry"=:list_of_cols_val_tab_del)
										  when '19' then (select top 1 "CardCode" from ORPC where "DocEntry"=:list_of_cols_val_tab_del)
										  when '204' then (select top 1 "CardCode" from ODPO where "DocEntry"=:list_of_cols_val_tab_del) 
			   end
		)INTO crdCode FROM DUMMY;
		
		
		SELECT(case :object_type when '18' then (select top 1 Count("WTCode") from PCH5 where "WTCode" like 'DT%' and "AbsEntry"=:list_of_cols_val_tab_del)
										 when '19' then (select top 1 Count("WTCode") from RPC5 where "WTCode" like 'DT%' and "AbsEntry"=:list_of_cols_val_tab_del)
										 when '204' then (select top 1 Count("WTCode") from DPO5 where "WTCode" like 'DT%' and "AbsEntry"=:list_of_cols_val_tab_del) 
			   end
		)INTO Detrac FROM DUMMY;
		
	
		IF :Detrac > 0 THEN
			 SELECT(select top 1 COALESCE("U_BPP_CtaDetrac", '') from OCRD where "CardCode"=:crdCode)INTO ctaDetrac FROM DUMMY;
			IF IFNULL(:ctaDetrac, '')='' THEN
					error :=1;
					error_message := 'No se ha definido la cuenta asociada de Detracciones para el socio de negocio.';
			END IF;	
		END IF;
		
		SELECT (select top 1 "LocManTran" from OACT where "FormatCode"=:ctaDetrac) INTO v_LocManTran FROM DUMMY;
		
		IF :v_LocManTran = 'N' THEN
				error :=1;
				error_message :='La cuenta del socio de negocio definida para el asiento de detracción no es una cuenta asociada.';
		END IF;
	
	END IF;

END;




