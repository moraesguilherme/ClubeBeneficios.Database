CREATE   PROCEDURE [dbo].[usp_benefits_change_status]
    @BenefitId UNIQUEIDENTIFIER,
    @NewStatus VARCHAR(30),
    @Reason VARCHAR(1500) = NULL,
    @ChangedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentStatus VARCHAR(30);
    DECLARE @AutoActivateWhenApproved BIT;

    SELECT
        @CurrentStatus = status,
        @AutoActivateWhenApproved = auto_activate_when_approved
    FROM dbo.benefits
    WHERE id = @BenefitId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Benefício não encontrado.', 16, 1);
        RETURN;
    END

    IF @NewStatus = 'approved' AND @AutoActivateWhenApproved = 1
        SET @NewStatus = 'active';

    BEGIN TRANSACTION;

    UPDATE dbo.benefits
    SET
        status = @NewStatus,
        approval_notes = CASE WHEN @NewStatus IN ('approved', 'active') THEN @Reason ELSE approval_notes END,
        rejection_reason = CASE WHEN @NewStatus = 'rejected' THEN @Reason ELSE rejection_reason END,
        approved_by_user_id = CASE WHEN @NewStatus IN ('approved', 'active') THEN @ChangedByUserId ELSE approved_by_user_id END,
        rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
        approved_at = CASE WHEN @NewStatus IN ('approved', 'active') THEN SYSUTCDATETIME() ELSE approved_at END,
        rejected_at = CASE WHEN @NewStatus = 'rejected' THEN SYSUTCDATETIME() ELSE rejected_at END,
        inactivated_at = CASE WHEN @NewStatus IN ('inactive', 'archived', 'expired') THEN SYSUTCDATETIME() ELSE inactivated_at END,
        updated_by_user_id = @ChangedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @BenefitId;

    INSERT INTO dbo.benefit_status_history
    (
        benefit_id, from_status, to_status, reason, changed_by_user_id, changed_at
    )
    VALUES
    (
        @BenefitId, @CurrentStatus, @NewStatus, @Reason, @ChangedByUserId, SYSUTCDATETIME()
    );

    COMMIT TRANSACTION;
END

GO


