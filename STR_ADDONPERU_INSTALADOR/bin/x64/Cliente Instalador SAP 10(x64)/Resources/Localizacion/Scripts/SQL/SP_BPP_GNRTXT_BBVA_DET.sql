CREATE PROCEDURE SP_BPP_GNRTXT_BBVA_DET
(
    @DOCENTRY INT
)
AS
BEGIN
    SELECT 
        '002' AS TipoRegistro,
        CASE 
            WHEN T1.U_BPP_BPTD = '1' THEN 'L'
            WHEN T1.U_BPP_BPTD = '6' THEN 'R'
            WHEN T1.U_BPP_BPTD = '4' THEN 'E'
            WHEN T1.U_BPP_BPTD = '7' THEN 'P'
            WHEN T1.U_BPP_BPTD = '0' THEN 'M'
        END AS TipoDocIdentidad,
		
        RIGHT('' + T1.LicTradNum, 12) AS NroDocIdentidad,  -- 12 characters, padded left with spaces

        CASE 
            WHEN T1.BankCtlKey = 'C' THEN 'P'
			WHEN T1.BankCtlKey = 'A' then 'P' 
            WHEN T1.BankCtlKey = 'B' THEN 'I' 
            ELSE 'O'
        END AS TipoAbono,

		CASE 
		WHEN T1.BankCtlKey = 'C' OR T1.BankCtlKey = 'B' OR T1.BankCtlKey = 'A' THEN
		LEFT(LTRIM(RTRIM(substring(REPLACE(DflAccount,'-',''), 1, 4)--+'00'
			+substring(REPLACE(DflAccount,'-',''),5,4)+'00'
			+substring(REPLACE(DflAccount,'-',''), 9, len(REPLACE(T7."U_BPP_CUENBAN",'-',''))))),22)
		ELSE
		REPLICATE('',22) END as 'CuentaAbonar',


        --LEFT(REPLICATE('', 20) + LTRIM(RTRIM(REPLACE(T1.DflAccount, '-', ''))),20) AS CuentaAbonar, -- 20 characters		


		LEFT(LTRIM(RTRIM(T1.CardName)) + REPLICATE(' ', 40), 40) AS NombreBeneficiario, -- 40 characters, padded right with spaces
		
        SUBSTRING(RIGHT('000000000000000' +  
            CAST(FLOOR(T8.U_BPP_MONTOPAG) AS VARCHAR(12)) + 
            RIGHT('0' + CAST(CAST((T8.U_BPP_MONTOPAG * 100) % 100 AS INT) AS VARCHAR(2)), 2), 15),1,15) AS ImportAbonar, -- 15 characters, padded left with zeros
        'F' AS TipoDocumento,
       
	   
		LEFT((SELECT
		CONVERT(NVARCHAR(12),right(rtrim(OP.U_BPP_MDSD),4) + right(rtrim(OP.U_BPP_MDCD),8) --+ REPLICATE (' ',8-LEN(OP.U_BPP_MDCD))
		)
		FROM  OPCH OP WHERE OP.DOCENTRY=T10.DocEntry   ),12)  
		AS 'NroDocumento',

	   /* RIGHT('           ' + ISNULL((SELECT OP.U_BPP_MDSD + OP.U_BPP_MDCD 
                                     FROM OPCH OP 
                                     WHERE OP.DocEntry = T10.DocEntry), ''), 14) AS NroDocumento,*/ -- 12 characters, padded left with spaces
        'N' AS AbonoGrupal,
        LEFT('PAGOPROVEEDORESBBVA' + REPLICATE('', 21), 21) AS Referencia, -- 21 characters
        REPLICATE('', 1) AS IndicadordeAviso,
        REPLICATE('', 50) AS MedioAviso,
        REPLICATE('', 30) AS PersonaContacto,
        --'00' AS IndicadorProceso,
		'' AS IndicadorProceso,
        --REPLICATE('0', 30) AS DescCodRetorno,
		REPLICATE('', 30) AS DescCodRetorno,
        REPLICATE('', 18) AS Filler
INTO #RD

 FROM "@BPP_PAGM_CAB" T7
 INNER JOIN "@BPP_PAGM_DET1" T8 ON T7.DocEntry = T8.DocEntry
 INNER JOIN OPCH T10 ON T10.DocEntry = T8.U_BPP_NUMSAP
 INNER JOIN OCRD T1 ON T1.CardCode = T8.U_BPP_CODPROV
 
 WHERE T7.U_BPP_ESTADO != 'Cancelado' and T8.DocEntry = @DOCENTRY

    SELECT
        TipoRegistro +  
        TipoDocIdentidad + 
        SUBSTRING(NroDocIdentidad,1,12) +  
        Space(1)+TipoAbono +  
        SUBSTRING(CuentaAbonar,1,22) + 
        SUBSTRING(NombreBeneficiario,1,40) +
		--SPACE(1)+
        SUBSTRING(ImportAbonar,1,15) +  
        TipoDocumento + 
        SUBSTRING(NroDocumento,1,14) + 
        AbonoGrupal + 
        Referencia + 
        SUBSTRING(IndicadordeAviso,1,1) + 
        SUBSTRING(MedioAviso,1,50) + 
        SUBSTRING(PersonaContacto,1,30) + 
        IndicadorProceso + 
        SUBSTRING(DescCodRetorno,1,30) + 
        SUBSTRING(Filler,1,18)+ 
        '                                                                                                                                                        @'
		AS PMBBVA_D
    FROM #RD;
END;

