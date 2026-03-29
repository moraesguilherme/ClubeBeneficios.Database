CREATE OR ALTER PROCEDURE dbo.usp_partners_change_status
    @PartnerId        UNIQUEIDENTIFIER,
    @NewStatus        VARCHAR(30),
    @Reason           VARCHAR(800) = NULL,
    @ChangedByUserId  UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldStatus VARCHAR(30);
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    SELECT @OldStatus = status
      FROM dbo.partners
     WHERE id = @PartnerId;

    UPDATE dbo.partners
       SET status = @NewStatus,
           approved_at = CASE WHEN @NewStatus = 'approved' THEN @Now ELSE approved_at END,
           rejected_at = CASE WHEN @NewStatus = 'rejected' THEN @Now ELSE rejected_at END,
           inactivated_at = CASE WHEN @NewStatus = 'inactive' THEN @Now ELSE inactivated_at END,
           approved_by_user_id = CASE WHEN @NewStatus = 'approved' THEN @ChangedByUserId ELSE approved_by_user_id END,
           rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
           updated_at = @Now
     WHERE id = @PartnerId;

    INSERT INTO dbo.partner_status_history
    (
        partner_id,
        from_status,
        to_status,
        reason,
        changed_by_user_id,
        changed_at
    )
    VALUES
    (
        @PartnerId,
        @OldStatus,
        @NewStatus,
        @Reason,
        @ChangedByUserId,
        @Now
    );
END
GO