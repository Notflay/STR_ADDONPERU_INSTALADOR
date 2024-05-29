CREATE PROCEDURE STR_SP_InfoAsientoDestino
(
	IN fIni NVARCHAR(50),
	IN fFin NVARCHAR(50)
)
AS
	
BEGIN
	DECLARE SEGMENTADO CHAR(1);
	DECLARE OCRCODE CHAR(1);
	SELECT "EnbSgmnAct" INTO SEGMENTADO FROM CINF;
	SELECT "U_STR_OcrCode" INTO OCRCODE FROM "@BPP_PARAMS";

	select 
	"Codigo",
	"Cuenta",
	"Descripcion",
	CASE when "Saldo">=0.0 then ABS("Saldo") else 0.0 end as "Debito",
	CASE when "Saldo"<0.0 then ABS("Saldo") else 0.0 end as "Credito"
	from
	(
		select 
		
		
(select top 1 "U_BPP_CdgCuenta" from "@BPP_CONFIG") as "Codigo", 
(select top 1 "U_BPP_FmtCuenta" from "@BPP_CONFIG") as "Cuenta", 
(select top 1 "U_BPP_NmbCuenta" from "@BPP_CONFIG") as "Descripcion", 

		--SELECT "EnbSgmnAct" FROM CINF

		SUM("Credito") as "Debito", 
		SUM("Debito") as "Credito",
		(SUM("Credito") - SUM("Debito")) as "Saldo"
		from (			
			select 
			/*T1.AcctCode*/'' as "Codigo", /*T0.OcrCode3*/'' as "Cuenta", /*T1.AcctName*/'' as "Descripcion", SUM(T0."Debit") as "Debito", SUM(T0."Credit") as "Credito" 
			from 
			 /*
				24/05/2024:
				Se vuelve adaptable el CECO según cuenta destino 
				de la tabla @BPP_PARAMS
			 */
			JDT1 T0 INNER JOIN OACT T1 				
				ON 
				(
					(:SEGMENTADO = 'N' AND (
								(:OCRCODE = '2' AND T0."OcrCode2" = T1."AcctCode") OR 
								(:OCRCODE = '3' AND T0."OcrCode3" = T1."AcctCode") OR 
								(:OCRCODE = '4' AND T0."OcrCode4" = T1."AcctCode") OR 
								(:OCRCODE = '5' AND T0."OcrCode5" = T1."AcctCode") 
							)
						) OR
					(:SEGMENTADO = 'Y' AND (
								(:OCRCODE = '2' AND T0."OcrCode2" = T1."Segment_0") OR 
								(:OCRCODE = '3' AND T0."OcrCode3" = T1."Segment_0") OR 
								(:OCRCODE = '4' AND T0."OcrCode4" = T1."Segment_0") OR 
								(:OCRCODE = '5' AND T0."OcrCode5" = T1."Segment_0") 
							)
						) 
				)
				INNER JOIN OJDT T2 on T0."TransId" = T2."TransId"	--AND IFNULL(T2."U_STR_ADP",'N') = 'N'
				LEFT JOIN OOCR T3 ON 
				(
					(:OCRCODE = '2' AND T3."OcrCode" = T0."OcrCode2") OR
					(:OCRCODE = '3' AND T3."OcrCode" = T0."OcrCode3") OR
					(:OCRCODE = '4' AND T3."OcrCode" = T0."OcrCode4") OR
					(:OCRCODE = '5' AND T3."OcrCode" = T0."OcrCode5") 
				)
				-- LA CONDICIÓN VALIDA Y PARA GENERA DESTINO
		        INNER JOIN OACT T4 ON 
		        (
		            (:OCRCODE = '2' AND T4."AcctCode" = T0."OcrCode2") OR
		            (:OCRCODE = '3' AND T4."AcctCode" = T0."OcrCode3") OR
		            (:OCRCODE = '4' AND T4."AcctCode" = T0."OcrCode4") OR
		            (:OCRCODE = '5' AND T4."AcctCode" = T0."OcrCode5") 
		        )
		        /*
					24/05/2024:
					Se configura la condicional de generar Cuentas para el uso repititivo si en caso se equivoca 
					-- AND IFNULL(T2."U_STR_ADP",'N') = 'N' 	
				*/
				-- inner join OPCH T3 on T2."CreatedBy" = T3."DocEntry" and t3."DocType" = 'S' and t3."U_STR_ADP" = 'N'
			where 
			IFNULL(
				CASE 
					WHEN :OCRCODE = '2' THEN T0."OcrCode2" 
					WHEN :OCRCODE = '3' THEN T0."OcrCode3" 
					WHEN :OCRCODE = '4' THEN T0."OcrCode4" 
					ELSE T0."OcrCode5" 
				END, ''
			) != ''
			AND TO_DATE(T0."RefDate") BETWEEN case when :fIni = '' then '19000101' else TO_DATE(:fIni) end AND case when :fFin = '' then CURRENT_DATE else TO_DATE(:fFin) end
			AND T4."U_STR_DESTINO" = 'Y'
			Group By "OcrCode3", T1."AcctName", T1."AcctCode"
			) CD
	
		UNION ALL
	
		select 
		T1."AcctCode" as "Codigo", 
		-- 
		T0."OcrCode3" as "Cuenta", 
		T1."AcctName" as "Descripcion", 
		SUM(T0."Debit") as "Debito", 
		SUM(T0."Credit") as "Credito",
		(SUM(T0."Debit") - SUM(T0."Credit")) as "Saldo"
		from 	
		JDT1 T0 INNER JOIN OACT T1 
			/*
				24/05/2024:
				Se vuelve adaptable el CECO según cuenta destino 
				de la tabla @BPP_PARAMS
			 */
				ON 
				(
					(:SEGMENTADO = 'N' AND (
								(:OCRCODE = '2' AND T0."OcrCode2" = T1."AcctCode") OR 
								(:OCRCODE = '3' AND T0."OcrCode3" = T1."AcctCode") OR 
								(:OCRCODE = '4' AND T0."OcrCode4" = T1."AcctCode") OR 
								(:OCRCODE = '5' AND T0."OcrCode5" = T1."AcctCode") 
							)
					) OR
					(:SEGMENTADO = 'Y' AND (
								(:OCRCODE = '2' AND T0."OcrCode2" = T1."Segment_0") OR 
								(:OCRCODE = '3' AND T0."OcrCode3" = T1."Segment_0") OR 
								(:OCRCODE = '4' AND T0."OcrCode4" = T1."Segment_0") OR 
								(:OCRCODE = '5' AND T0."OcrCode5" = T1."Segment_0") 
							)
					) 
				) 
		/*
		24/05/2024:
			Se configura la condicional de generar Cuentas para el uso repititivo si en caso se equivoca 
			-- AND IFNULL(T2."U_STR_ADP",'N') = 'N' 	
		*/		
		INNER JOIN OJDT T2 on T0."TransId" = T2."TransId" -- AND IFNULL(T2."U_STR_ADP",'N') = 'N' 	
		--inner join OPCH T3 on T2."CreatedBy" = T3."DocEntry" and t3."DocType" = 'S' and t3."U_STR_ADP" = 'N'
		-- LA CONDICIÓN VALIDA Y PARA GENERA DESTINO
		        INNER JOIN OACT T4 ON 
		        (
		            (:OCRCODE = '2' AND T4."AcctCode" = T0."OcrCode2") OR
		            (:OCRCODE = '3' AND T4."AcctCode" = T0."OcrCode3") OR
		            (:OCRCODE = '4' AND T4."AcctCode" = T0."OcrCode4") OR
		            (:OCRCODE = '5' AND T4."AcctCode" = T0."OcrCode5") 
		        )
		where 
		IFNULL(
				CASE 
					WHEN :OCRCODE = '2' THEN T0."OcrCode2" 
					WHEN :OCRCODE = '3' THEN T0."OcrCode3" 
					WHEN :OCRCODE = '4' THEN T0."OcrCode4" 
					ELSE T0."OcrCode5" 
				END, ''
			) != ''
		And  TO_DATE(T0."RefDate") BETWEEN case when :fIni = '' then '19000101' else TO_DATE(:fIni) end AND case when :fFin = '' then CURRENT_DATE else TO_DATE(:fFin) end
		AND T4."U_STR_DESTINO" = 'Y'
		Group By "OcrCode3", T1."AcctName", T1."AcctCode" 
	) CtaDst;
END;