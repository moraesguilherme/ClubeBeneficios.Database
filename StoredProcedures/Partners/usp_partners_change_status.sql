CREATE PROCEDURE dbo.usp_partners_change_status
    @PartnerId UNIQUEIDENTIFIER,
    @NewStatus VARCHAR(30),
    @Reason VARCHAR(800) = NULL,
    @ChangedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentStatus VARCHAR(30);

    SELECT @CurrentStatus = status
    FROM dbo.partners
    WHERE id = @PartnerId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Parceiro nÃ£o encontrado.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

        UPDATE dbo.partners
           SET status = @NewStatus,
               approved_at = CASE WHEN @NewStatus = 'active' THEN ISNULL(approved_at, SYSUTCDATETIME()) ELSE approved_at END,
               approved_by_user_id = CASE WHEN @NewStatus = 'active' THEN ISNULL(approved_by_user_id, @ChangedByUserId) ELSE approved_by_user_id END,
               rejected_at = CASE WHEN @NewStatus = 'rejected' THEN SYSUTCDATETIME() ELSE rejected_at END,
               rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
               inactivated_at = CASE WHEN @NewStatus = 'inactive' THEN SYSUTCDATETIME() ELSE inactivated_at END,
               updated_at = SYSUTCDATETIME()
         WHERE id = @PartnerId;

        INSERT INTO dbo.partner_status_history
        (
            partner_id, from_status, to_status, reason, changed_by_user_id, changed_at
        )
        VALUES
        (
            @PartnerId, @CurrentStatus, @NewStatus, @Reason, @ChangedByUserId, SYSUTCDATETIME()
        );

    COMMIT TRANSACTION;
END
GO
