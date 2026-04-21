CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefit_update]
    @LevelBenefitId uniqueidentifier,
    @LevelCode varchar(30),
    @Title varchar(150),
    @Description varchar(1500) = NULL,
    @DisplayOrder int,
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL,
    @UpdatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.loyalty_level_benefits
    SET
        level_code = @LevelCode,
        title = @Title,
        description = @Description,
        display_order = @DisplayOrder,
        valid_from = @ValidFrom,
        valid_to = @ValidTo,
        updated_at = SYSUTCDATETIME(),
        updated_by_user_id = @UpdatedByUserId
    WHERE id = @LevelBenefitId;

    SELECT *
    FROM dbo.loyalty_level_benefits
    WHERE id = @LevelBenefitId;
END
GO


