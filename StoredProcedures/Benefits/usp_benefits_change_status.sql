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
    DECLARE @EffectiveNewStatus VARCHAR(30);
    DECLARE @AutoActivateWhenApproved BIT;
    DECLARE @NotificationEventReferenceId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

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

    SET @EffectiveNewStatus = @NewStatus;

    IF @EffectiveNewStatus = 'approved' AND @AutoActivateWhenApproved = 1
        SET @EffectiveNewStatus = 'active';

    IF @CurrentStatus = @EffectiveNewStatus
    BEGIN
        SELECT
            @BenefitId AS benefit_id,
            @CurrentStatus AS previous_status,
            @EffectiveNewStatus AS current_status,
            CAST(0 AS BIT) AS status_changed;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.benefits
        SET
            status = @EffectiveNewStatus,
            approval_notes = CASE 
                WHEN @EffectiveNewStatus IN ('approved', 'active') 
                    THEN @Reason 
                ELSE approval_notes 
            END,
            rejection_reason = CASE 
                WHEN @EffectiveNewStatus = 'rejected' 
                    THEN @Reason 
                ELSE rejection_reason 
            END,
            approved_by_user_id = CASE 
                WHEN @EffectiveNewStatus IN ('approved', 'active') 
                    THEN @ChangedByUserId 
                ELSE approved_by_user_id 
            END,
            rejected_by_user_id = CASE 
                WHEN @EffectiveNewStatus = 'rejected' 
                    THEN @ChangedByUserId 
                ELSE rejected_by_user_id 
            END,
            approved_at = CASE 
                WHEN @EffectiveNewStatus IN ('approved', 'active') 
                    THEN @Now 
                ELSE approved_at 
            END,
            rejected_at = CASE 
                WHEN @EffectiveNewStatus = 'rejected' 
                    THEN @Now 
                ELSE rejected_at 
            END,
            inactivated_at = CASE 
                WHEN @EffectiveNewStatus IN ('inactive', 'archived', 'expired') 
                    THEN @Now 
                ELSE inactivated_at 
            END,
            updated_by_user_id = @ChangedByUserId,
            updated_at = @Now
        WHERE id = @BenefitId;

        INSERT INTO dbo.benefit_status_history
        (
            benefit_id,
            from_status,
            to_status,
            reason,
            changed_by_user_id,
            changed_at
        )
        VALUES
        (
            @BenefitId,
            @CurrentStatus,
            @EffectiveNewStatus,
            @Reason,
            @ChangedByUserId,
            @Now
        );

        EXEC dbo.usp_benefit_notification_enqueue
            @BenefitId = @BenefitId,
            @EventType = 'benefits.benefit.status_changed',
            @PreviousStatus = @CurrentStatus,
            @Reason = @Reason,
            @EventReferenceId = @NotificationEventReferenceId;

        COMMIT TRANSACTION;

        SELECT
            @BenefitId AS benefit_id,
            @CurrentStatus AS previous_status,
            @EffectiveNewStatus AS current_status,
            CAST(1 AS BIT) AS status_changed;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

