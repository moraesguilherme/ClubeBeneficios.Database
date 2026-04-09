CREATE   PROCEDURE [dbo].[usp_benefit_request_add_review]
    @BenefitRequestId UNIQUEIDENTIFIER,
    @ReviewStatus VARCHAR(30),
    @ReviewPoint VARCHAR(200) = NULL,
    @ReviewRecommendation VARCHAR(1500) = NULL,
    @ReviewedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentRequestStatus VARCHAR(30);
    DECLARE @MappedRequestStatus VARCHAR(30);

    SELECT
        @CurrentRequestStatus = request_status
    FROM dbo.benefit_requests
    WHERE id = @BenefitRequestId;

    IF @CurrentRequestStatus IS NULL
    BEGIN
        RAISERROR('Solicitação não encontrada.', 16, 1);
        RETURN;
    END

    IF @ReviewStatus NOT IN ('pending_review', 'under_review', 'approved', 'rejected', 'cancelled', 'expired')
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
        @ReviewStatus,
        @ReviewPoint,
        @ReviewRecommendation,
        @ReviewedByUserId,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    EXEC dbo.usp_benefit_requests_change_status
        @BenefitRequestId = @BenefitRequestId,
        @NewStatus = @MappedRequestStatus,
        @ReviewNotes = @ReviewRecommendation,
        @ReviewedByUserId = @ReviewedByUserId,
        @ApprovalStatus = @ReviewStatus,
        @ApprovalReason = @ReviewRecommendation;
END
GO


