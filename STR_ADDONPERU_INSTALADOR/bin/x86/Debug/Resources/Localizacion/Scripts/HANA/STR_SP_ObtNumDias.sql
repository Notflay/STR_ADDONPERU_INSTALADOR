﻿CREATE PROCEDURE STR_SP_ObtNumDias
AS
BEGIN
	SELECT COALESCE("U_BPP_NDiasDtrac", 0) AS "NDiasDetrac" FROM "@BPP_CONFIG";
END;
