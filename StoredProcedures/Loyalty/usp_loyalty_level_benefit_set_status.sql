CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefit_set_status]
    @LevelBenefitId uniqueidentifier,
    @Status varchar(30),
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_level_benefits
    SET
        status = @Status,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @LevelBenefitId;

    SELECT *
    FROM dbo.loyalty_level_benefits
    WHERE id = @LevelBenefitId;
END
GO

