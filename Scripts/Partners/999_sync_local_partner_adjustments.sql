SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =========================================================
       A) ALINHAR STATUS E LEVEL DA TABELA partners
       ========================================================= */

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_partners_status'
          AND parent_object_id = OBJECT_ID('dbo.partners')
    )
    BEGIN
        ALTER TABLE dbo.partners DROP CONSTRAINT CK_partners_status;
    END

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_partners_level'
          AND parent_object_id = OBJECT_ID('dbo.partners')
    )
    BEGIN
        ALTER TABLE dbo.partners DROP CONSTRAINT CK_partners_level;
    END

    UPDATE dbo.partners
       SET status = 'pending_review'
     WHERE status = 'pending';

    UPDATE dbo.partners
       SET level = 'silver'
     WHERE level = 'prata';

    UPDATE dbo.partners
       SET level = 'gold'
     WHERE level = 'ouro';

    UPDATE dbo.partners
       SET level = 'diamond'
     WHERE level = 'diamante';

    ALTER TABLE dbo.partners
        ADD CONSTRAINT CK_partners_status
        CHECK ([status] IN (
            'pending_review',
            'under_review',
            'approved',
            'active',
            'inactive',
            'rejected',
            'suspended',
            'blocked'
        ));

    ALTER TABLE dbo.partners
        ADD CONSTRAINT CK_partners_level
        CHECK ([level] IS NULL OR [level] IN (
            'bronze',
            'silver',
            'gold',
            'diamond',
            'platinum'
        ));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO