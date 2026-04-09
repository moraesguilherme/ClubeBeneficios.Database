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

    DECLARE @BenefitId UNIQUEIDENTIFIER;

    SELECT @BenefitId = benefit_id
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
       AND @ApprovalStatus NOT IN ('pending_review', 'under_review', 'approved', 'rejected', 'cancelled', 'expired')
    BEGIN
        RAISERROR('ApprovalStatus inválido.', 16, 1);
        RETURN;
    END

    UPDATE dbo.benefit_requests
    SET
        request_status = @NewStatus,
        reviewed_at = SYSUTCDATETIME(),
        reviewed_by_user_id = @ReviewedByUserId,
        review_notes = @ReviewNotes,
        approval_status = COALESCE(@ApprovalStatus, approval_status),
        approval_decided_at = CASE WHEN @ApprovalStatus IS NOT NULL THEN SYSUTCDATETIME() ELSE approval_decided_at END,
        approval_decided_by_user_id = CASE WHEN @ApprovalStatus IS NOT NULL THEN @ReviewedByUserId ELSE approval_decided_by_user_id END,
        approval_reason = COALESCE(@ApprovalReason, approval_reason),
        updated_at = SYSUTCDATETIME()
    WHERE id = @BenefitRequestId;

    IF @ApprovalStatus IS NOT NULL
    BEGIN
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
            NEWID(),
            @BenefitRequestId,
            @ApprovalStatus,
            'request_status_change',
            COALESCE(@ApprovalReason, @ReviewNotes),
            @ReviewedByUserId,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END

    IF @NewStatus = 'approved'
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
            refreshed_at = SYSUTCDATETIME()
        WHERE benefit_id = @BenefitId;
    END
END
GO


