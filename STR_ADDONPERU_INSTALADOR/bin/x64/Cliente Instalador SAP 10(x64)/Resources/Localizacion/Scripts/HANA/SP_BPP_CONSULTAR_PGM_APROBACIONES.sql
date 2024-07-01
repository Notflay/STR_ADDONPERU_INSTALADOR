CREATE PROCEDURE SP_BPP_CONSULTAR_PGM_APROBACIONES(
IN FECHAINI DATE,
IN FECHAFIN DATE
)
AS
BEGIN
	
SELECT 

'N' "Checkbox",
T0."WizardName" "Planilla",
T0."PmntDate" "FechaEjecucion",
T1."PymCurr" "Moneda",
SUM(T1."PayAmount") "MontoPago",
T1."IdEntry" "Idnumber"
FROM OPWZ T0 
INNER JOIN PWZ3 T1 ON T1."IdEntry"=T0."IdNumber" 
WHERE T1."PymNum"=0  --AND T1."U_PLUS_H2H_APROBACION"=2 AND T1."U_PLUS_H2H_ENVIAR"='Y' 
AND T0."Canceled"='N' AND T0."IdNumber" NOT IN (SELECT U_BPP_IDNUMBER FROM "@BPP_PGM_DET1") AND T0."PmntDate" BETWEEN FECHAINI AND  FECHAFIN
GROUP BY 
T0."WizardName",
T0."PmntDate",
T1."PymCurr",
T1."IdEntry";

END