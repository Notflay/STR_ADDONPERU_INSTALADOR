CREATE PROCEDURE RML_PT_APP_PMD_001_UDO
(
    @id NVARCHAR(50),
    @transaction_type NVARCHAR(1)
)
AS
BEGIN
    DECLARE @vv_CodComp INT;
    DECLARE @vd_FecDeps DATETIME2;
    DECLARE @vv_NumDeps NVARCHAR(20);
    DECLARE @vv_CdgPvdr NVARCHAR(40);
    DECLARE @vv_Nmatcar NVARCHAR(40);
    DECLARE @vv_Status NVARCHAR(1);

    IF @transaction_type = 'U'
    BEGIN
        SELECT TOP 1 @vv_Status = Status 
        FROM "@BPP_PAYDTR" 
        WHERE DocEntry = @id;

        SELECT TOP 1 @vd_FecDeps = U_BPP_FcDp 
        FROM "@BPP_PAYDTR" 
        WHERE DocEntry = @id;

        IF ISNULL(@vv_Status, '') = 'C'
        BEGIN
            DECLARE CUR_UpdateOPCHNmCnst CURSOR FOR
            SELECT T1.U_BPP_DocKeyDest, T0.U_BPP_CgPv, T0.U_BPP_Cnst
            FROM "@BPP_PAYDTRDET" T0 
            INNER JOIN OJDT T1 ON T0.U_BPP_DEAs = T1.TransId 
            WHERE T0.DocEntry = @id;

            OPEN CUR_UpdateOPCHNmCnst;

            FETCH NEXT FROM CUR_UpdateOPCHNmCnst INTO @vv_CodComp, @vv_CdgPvdr, @vv_NumDeps;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE OPCH 
                SET U_BPP_DPFC = @vd_FecDeps, U_BPP_DPNM = @vv_NumDeps 
                WHERE DocEntry = @vv_CodComp AND CardCode = @vv_CdgPvdr;

                FETCH NEXT FROM CUR_UpdateOPCHNmCnst INTO @vv_CodComp, @vv_CdgPvdr, @vv_NumDeps;
            END

            CLOSE CUR_UpdateOPCHNmCnst;
            DEALLOCATE CUR_UpdateOPCHNmCnst;

            UPDATE ORPC 
            SET U_BPP_DPFC = @vd_FecDeps, U_BPP_DPNM = @vv_NumDeps 
            WHERE DocEntry IN (
                SELECT T1.U_BPP_DocKeyDest 
                FROM "@BPP_PAYDTRDET" T0 
                INNER JOIN OJDT T1 ON T0.U_BPP_DEAs = T1.TransId 
                WHERE T0.DocEntry = @id AND T1.U_BPP_CtaTdoc = '19'
            );

            UPDATE ODPO 
            SET U_BPP_DPFC = @vd_FecDeps, U_BPP_DPNM = @vv_NumDeps 
            WHERE DocEntry IN (
                SELECT T1.U_BPP_DocKeyDest 
                FROM "@BPP_PAYDTRDET" T0 
                INNER JOIN OJDT T1 ON T0.U_BPP_DEAs = T1.TransId 
                WHERE T0.DocEntry = @id AND T1.U_BPP_CtaTdoc = '204'
            );
        END
    END
END;