CREATE PROCEDURE SP_BPP_GENERAR_ASIENTO
(
    @Docentry INT,
    @ObjType NVARCHAR(20)
)
AS
BEGIN

    IF (@ObjType = '18')
    BEGIN
	SELECT 
			T0.TransId AS AsientoOrigen,
			T0.Line_ID + 1 AS linOrigen,
			T3.DocEntry AS NumeroSAP,
			T5.Account AS CuentaDebit,
			(SELECT U_BPP_CNTDETASC FROM "@BPP_PARAMS") AS CuentaCredit,
			T3.NumAtCard AS NumeroDocumento,
			(
				SELECT a1.ShortName 
				FROM JDT1 a1 
				INNER JOIN OACT a2 ON a2.AcctCode = a1.Account 
				WHERE a2.LocManTran = 'Y' AND a1.TransId = T2.TransId
			) AS Proveedor,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.Credit, 0) 
				ELSE ISNULL(T0.Debit, 0) 
			END AS MontoLocal,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.FCCredit, 0) 
				ELSE ISNULL(T0.FCDebit, 0) 
			END AS MontoExtranjero,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.SYSCred, 0) 
				ELSE ISNULL(T0.SYSDeb, 0) 
			END AS MontoSistema,
			ISNULL(T0.FCCurrency, 'SOL') AS Moneda,
			T0.RefDate AS FechaContabilizacion,
			T0.TaxDate AS FechaDocumento,
			T0.DueDate AS FechaVencimiento,
			T0.LineMemo AS glosa,
			ISNULL(T0.ProfitCode, '') AS CC1,
			ISNULL(T0.OcrCode2, '') AS CC2,
			ISNULL(T0.OcrCode3, '') AS CC3,
			ISNULL(T0.OcrCode4, '') AS CC4,
			ISNULL(T0.OcrCode5, '') AS CC5
		FROM 
			JDT1 T0 
		INNER JOIN 
			OACT T1 ON T1.AcctCode = T0.Account 
		INNER JOIN 
			OJDT T2 ON T0.TransId = T2.TransId
		INNER JOIN 
			OPCH T3 ON T2.TransId = T3.TransId
		INNER JOIN 
			PCH5 T4 ON T3.DocEntry = T4.AbsEntry
		INNER JOIN 
			OWHT T5 ON T4.WTCode = T5.WTCode AND T0.Account = T5.Account
		WHERE  
			(
				(ISNULL(T0.Debit, 0) - ISNULL(T0.Credit, 0)) <> 0 
				OR (ISNULL(T0.FCDebit, 0) - ISNULL(T0.FCCredit, 0)) <> 0 
				OR (ISNULL(T0.SYSDeb, 0) - ISNULL(T0.SYSCred, 0)) <> 0
			)
			AND T2.TransType = @ObjType 
			AND T3.DocEntry = @Docentry
			AND T3.CANCELED = 'N';
    END;

	--*********************
    IF (@ObjType = '19')
    BEGIN
	SELECT 
			T0.TransId AS AsientoOrigen,
			T0.Line_ID + 1 AS linOrigen,
			T3.DocEntry AS NumeroSAP,
			T5.Account AS CuentaDebit,
			(SELECT "U_BPP_CNTDETASC" FROM "@BPP_PARAMS"  )"CuentaCredit" , --( select "Account" from JDT1 where LEFT("ShortName",1) ='P' and "TransId" = T2."TransId" ) 
			T3.NumAtCard AS NumeroDocumento,
			(
				SELECT a1.ShortName 
				FROM JDT1 A1 
				INNER JOIN OACT A2 ON A2.AcctCode = A1.Account 
				WHERE A2.LocManTran = 'Y' AND A1.TransId = T2.TransId
			) AS Proveedor,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.Credit, 0) 
				ELSE ISNULL(T0.Debit, 0) 
			END AS MontoLocal,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.FCCredit, 0) 
				ELSE ISNULL(T0.FCDebit, 0) 
			END AS MontoExtranjero,
			CASE T0.DebCred 
				WHEN 'C' THEN -ISNULL(T0.SYSCred, 0) 
				ELSE ISNULL(T0.SYSDeb, 0) 
			END AS MontoSistema,
			ISNULL(T0.FCCurrency, 'SOL') AS Moneda,
			T0.RefDate AS FechaContabilizacion,
			T0.TaxDate AS FechaDocumento,
			T0.DueDate AS FechaVencimiento,
			T0.LineMemo AS glosa,
			ISNULL(T0.ProfitCode, '') AS CC1,
			ISNULL(T0.OcrCode2, '') AS CC2,
			ISNULL(T0.OcrCode3, '') AS CC3,
			ISNULL(T0.OcrCode4, '') AS CC4,
			ISNULL(T0.OcrCode5, '') AS CC5
		FROM 
			JDT1 T0 
		INNER JOIN 
			OACT T1 ON T1.AcctCode = T0.Account 
		INNER JOIN 
			OJDT T2 ON T0.TransId = T2.TransId
		INNER JOIN 
			ORPC T3 ON T2.TransId = T3.TransId
		INNER JOIN 
			RPC5 T4 ON T3.DocEntry = T4.AbsEntry
		INNER JOIN 
			OWHT T5 ON T4.WTCode = T5.WTCode AND T0.Account = T5.Account
		WHERE  
			(
				(ISNULL(T0.Debit, 0) - ISNULL(T0.Credit, 0)) <> 0 
				OR (ISNULL(T0.FCDebit, 0) - ISNULL(T0.FCCredit, 0)) <> 0 
				OR (ISNULL(T0.SYSDeb, 0) - ISNULL(T0.SYSCred, 0)) <> 0
			)
			AND T2.TransType = @ObjType 
			AND T3.DocEntry = @Docentry
			AND T3.CANCELED = 'N';
    END;

END;