CREATE   PROCEDURE [dbo].[usp_benefit_requests_change_status]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @NewStatus VARCHAR(30),
    @ReviewNotes VARCHAR(1500) = NULL,
    @ReviewedByUserId UNIQUEIDENTIFIER = NULL,
    @ApprovalStatus VARCHAR(30) = NULL,
    @ApprovalReason VARCHAR(1500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    DECLARE @BenefitId UNIQUEIDENTIFIER;
    DECLARE @CurrentRequestStatus VARCHAR(30);
    DECLARE @CurrentApprovalStatus VARCHAR(30);
    DECLARE @IsFinalDecision BIT = 0;
    DECLARE @StartedTransaction BIT = 0;

    SELECT
        @BenefitId = benefit_id,
        @CurrentRequestStatus = request_status,
        @CurrentApprovalStatus = approval_status
    FROM dbo.benefit_requests
    WHERE id = @BenefitRequestId;

    IF @BenefitId IS NULL
    BEGIN
        RAISERROR('Solicitação não encontrada.', 16, 1);
        RETURN;
    END

    IF @NewStatus NOT IN (
        'requested',
        'pending_review',
        'under_review',
        'approved',
        'declined',
        'cancelled',
        'expired',
        'scheduled',
        'no_show',
        'converted_to_usage'
    )
    BEGIN
        RAISERROR('NewStatus inválido.', 16, 1);
        RETURN;
    END

    IF @ApprovalStatus IS NOT NULL
       AND @ApprovalStatus NOT IN (
            'pending_review',
            'under_review',
            'approved',
            'rejected',
            'cancelled',
            'expired'
       )
    BEGIN
        RAISERROR('ApprovalStatus inválido.', 16, 1);
        RETURN;
    END

    IF @ApprovalStatus IN ('approved', 'rejected', 'cancelled', 'expired')
    BEGIN
        SET @IsFinalDecision = 1;
    END

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            SET @StartedTransaction = 1;
            BEGIN TRANSACTION;
        END

        UPDATE dbo.benefit_requests
        SET
            request_status = @NewStatus,

            reviewed_at = @Now,
            reviewed_by_user_id = @ReviewedByUserId,
            review_notes = COALESCE(@ReviewNotes, review_notes),

            approval_status = COALESCE(@ApprovalStatus, approval_status),

            approval_requested_at =
                CASE
                    WHEN @ApprovalStatus IN ('pending_review', 'under_review')
                         AND approval_requested_at IS NULL
                        THEN @Now
                    ELSE approval_requested_at
                END,

            approval_decided_at =
                CASE
                    WHEN @IsFinalDecision = 1 THEN @Now
                    ELSE approval_decided_at
                END,

            approval_decided_by_user_id =
                CASE
                    WHEN @IsFinalDecision = 1 THEN @ReviewedByUserId
                    ELSE approval_decided_by_user_id
                END,

            approval_reason = COALESCE(@ApprovalReason, @ReviewNotes, approval_reason),

            updated_at = @Now
        WHERE id = @BenefitRequestId;

        /*
            Importante:
            Esta procedure NÃO grava mais em benefit_request_reviews.
            O histórico deve ser gravado apenas por usp_benefit_request_add_review.
        */

        IF @NewStatus = 'approved'
           AND @CurrentRequestStatus <> 'approved'
        BEGIN
            UPDATE dbo.benefit_metrics_snapshot
            SET
                approved_requests_count = approved_requests_count + 1,
                conversion_rate =
                    CASE
                        WHEN requests_count > 0
                            THEN CAST(((approved_requests_count + 1) * 100.0) / requests_count AS DECIMAL(9,2))
                        ELSE 0
                    END,
                refreshed_at = @Now
            WHERE benefit_id = @BenefitId;

            IF @@ROWCOUNT = 0
            BEGIN
                INSERT INTO dbo.benefit_metrics_snapshot
                (
                    benefit_id,
                    requests_count,
                    approved_requests_count,
                    usages_count,
                    conversion_rate,
                    refreshed_at
                )
                SELECT
                    @BenefitId,
                    COUNT(1) AS requests_count,
                    SUM(CASE WHEN request_status = 'approved' THEN 1 ELSE 0 END) AS approved_requests_count,
                    0 AS usages_count,
                    CASE
                        WHEN COUNT(1) > 0
                            THEN CAST((SUM(CASE WHEN request_status = 'approved' THEN 1 ELSE 0 END) * 100.0) / COUNT(1) AS DECIMAL(9,2))
                        ELSE 0
                    END AS conversion_rate,
                    @Now
                FROM dbo.benefit_requests
                WHERE benefit_id = @BenefitId;
            END
        END

        IF @StartedTransaction = 1
            COMMIT TRANSACTION;

        SELECT
            @BenefitRequestId AS benefit_request_id,
            @NewStatus AS request_status,
            @ApprovalStatus AS approval_status;
    END TRY
    BEGIN CATCH
        IF @StartedTransaction = 1
           AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END
GO

