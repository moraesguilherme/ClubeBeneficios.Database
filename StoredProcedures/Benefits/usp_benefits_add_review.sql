CREATE   PROCEDURE [dbo].[usp_benefits_add_review]
    @BenefitId UNIQUEIDENTIFIER,
    @ReviewStatus VARCHAR(30),
    @ReviewPoint VARCHAR(200) = NULL,
    @ReviewRecommendation VARCHAR(1500) = NULL,
    @ReviewedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.benefit_reviews
    (
        id, benefit_id, review_status, review_point, review_recommendation, reviewed_by_user_id, reviewed_at, created_at
    )
    VALUES
    (
        NEWID(), @BenefitId, @ReviewStatus, @ReviewPoint, @ReviewRecommendation, @ReviewedByUserId, SYSUTCDATETIME(), SYSUTCDATETIME()
    );

    IF @ReviewStatus = 'changes_requested'
        EXEC dbo.usp_benefits_change_status @BenefitId = @BenefitId, @NewStatus = 'under_review', @Reason = @ReviewRecommendation, @ChangedByUserId = @ReviewedByUserId;
    ELSE IF @ReviewStatus = 'approved'
        EXEC dbo.usp_benefits_change_status @BenefitId = @BenefitId, @NewStatus = 'approved', @Reason = @ReviewRecommendation, @ChangedByUserId = @ReviewedByUserId;
    ELSE IF @ReviewStatus = 'rejected'
        EXEC dbo.usp_benefits_change_status @BenefitId = @BenefitId, @NewStatus = 'rejected', @Reason = @ReviewRecommendation, @ChangedByUserId = @ReviewedByUserId;
END

GO


