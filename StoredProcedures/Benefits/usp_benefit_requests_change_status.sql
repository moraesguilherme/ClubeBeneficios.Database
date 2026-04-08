CREATE PROCEDURE dbo.usp_benefit_requests_change_status
    @BenefitRequestId UNIQUEIDENTIFIER,
    @NewStatus VARCHAR(30),
    @ReviewNotes VARCHAR(1500) = NULL,
    @ReviewedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BenefitId UNIQUEIDENTIFIER;

    SELECT @BenefitId = benefit_id
    FROM dbo.benefit_requests
    WHERE id = @BenefitRequestId;

    IF @BenefitId IS NULL
    BEGIN
        RAISERROR('SolicitaÃ§Ã£o nÃ£o encontrada.', 16, 1);
        RETURN;
    END

    UPDATE dbo.benefit_requests
    SET
        request_status = @NewStatus,
        reviewed_at = SYSUTCDATETIME(),
        reviewed_by_user_id = @ReviewedByUserId,
        review_notes = @ReviewNotes,
        updated_at = SYSUTCDATETIME()
    WHERE id = @BenefitRequestId;

    IF @NewStatus = 'approved'
    BEGIN
        UPDATE dbo.benefit_metrics_snapshot
        SET
            approved_requests_count = approved_requests_count + 1,
            conversion_rate = CASE WHEN requests_count > 0 THEN CAST(((approved_requests_count + 1) * 100.0) / requests_count AS DECIMAL(9,2)) ELSE 0 END,
            refreshed_at = SYSUTCDATETIME()
        WHERE benefit_id = @BenefitId;
    END
END
GO