CREATE PROCEDURE [dbo].[usp_benefit_request_add_review]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @ReviewStatus VARCHAR(30),
    @ReviewPoint VARCHAR(200) = NULL,
    @ReviewRecommendation VARCHAR(1500) = NULL,
    @ReviewedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE @ReviewId UNIQUEIDENTIFIER = NEWID();

    DECLARE @CurrentRequestStatus VARCHAR(30);
    DECLARE @MappedRequestStatus VARCHAR(30);
    DECLARE @StartedTransaction BIT = 0;

    SELECT
        @CurrentRequestStatus = request_status
    FROM dbo.benefit_requests
    WHERE id = @BenefitRequestId;

    IF @CurrentRequestStatus IS NULL
    BEGIN
        RAISERROR('Solicitação não encontrada.', 16, 1);
        RETURN;
    END

    IF @ReviewStatus NOT IN (
        'pending_review',
        'under_review',
        'approved',
        'rejected',
        'cancelled',
        'expired'
    )
    BEGIN
        RAISERROR('ReviewStatus inválido.', 16, 1);
        RETURN;
    END

    SET @MappedRequestStatus =
        CASE
            WHEN @ReviewStatus = 'approved' THEN 'approved'
            WHEN @ReviewStatus = 'rejected' THEN 'declined'
            WHEN @ReviewStatus = 'pending_review' THEN 'pending_review'
            WHEN @ReviewStatus = 'under_review' THEN 'under_review'
            WHEN @ReviewStatus = 'cancelled' THEN 'cancelled'
            WHEN @ReviewStatus = 'expired' THEN 'expired'
            ELSE @CurrentRequestStatus
        END;

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            SET @StartedTransaction = 1;
            BEGIN TRANSACTION;
        END

        INSERT INTO dbo.benefit_request_reviews
        (
            id,
            benefit_request_id,
            review_status,
            review_point,
            review_recommendation,
            reviewed_by_user_id,
            reviewed_at,
            created_at
        )
        VALUES
        (
            @ReviewId,
            @BenefitRequestId,
            @ReviewStatus,
            @ReviewPoint,
            @ReviewRecommendation,
            @ReviewedByUserId,
            @Now,
            @Now
        );

        EXEC dbo.usp_benefit_requests_change_status
            @BenefitRequestId = @BenefitRequestId,
            @NewStatus = @MappedRequestStatus,
            @ReviewNotes = @ReviewRecommendation,
            @ReviewedByUserId = @ReviewedByUserId,
            @ApprovalStatus = @ReviewStatus,
            @ApprovalReason = @ReviewRecommendation;

        DECLARE @TimelineEventType VARCHAR(50);

        SET @TimelineEventType =
            CASE
                WHEN @ReviewStatus = 'approved' THEN 'approved'
                WHEN @ReviewStatus = 'rejected' THEN 'rejected'
                WHEN @ReviewStatus = 'under_review' THEN 'changes_requested'
                WHEN @ReviewStatus = 'cancelled' THEN 'cancelled'
                WHEN @ReviewStatus = 'expired' THEN 'expired'
                ELSE 'review_added'
            END;

        EXEC dbo.usp_benefit_request_timeline_event_add
            @BenefitRequestId = @BenefitRequestId,
            @EventType = @TimelineEventType,
            @EventStatus = @MappedRequestStatus,
            @EventPoint = @ReviewPoint,
            @EventDescription = @ReviewRecommendation,
            @ActorUserId = @ReviewedByUserId,
            @OccurredAt = @Now;

        DECLARE @NotificationEventType VARCHAR(120);

        SET @NotificationEventType =
            CASE
                WHEN @ReviewStatus = 'approved'
                    THEN 'benefits.request.approved'

                WHEN @ReviewStatus = 'under_review'
                    THEN 'benefits.request.changes_requested'

                WHEN @ReviewStatus = 'rejected'
                    THEN 'benefits.request.rejected'

                ELSE NULL
            END;

        IF @NotificationEventType IS NOT NULL
        BEGIN
            EXEC dbo.usp_benefit_request_notification_enqueue
                @BenefitRequestId = @BenefitRequestId,
                @EventType = @NotificationEventType,
                @ReviewPoint = @ReviewPoint,
                @ReviewRecommendation = @ReviewRecommendation,
                @EventReferenceId = @ReviewId;
        END

        IF @StartedTransaction = 1
            COMMIT TRANSACTION;

        SELECT
            @BenefitRequestId AS benefit_request_id,
            @ReviewId AS review_id,
            @ReviewStatus AS review_status,
            @MappedRequestStatus AS request_status;
    END TRY
    BEGIN CATCH
        IF @StartedTransaction = 1
           AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

