CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefit_create]
    @LevelBenefitId uniqueidentifier,
    @LevelCode varchar(30),
    @Title varchar(150),
    @Description varchar(1500) = NULL,
    @DisplayOrder int,
    @Status varchar(30),
    @ValidFrom datetime2(7) = NULL,
    @ValidTo datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_level_benefits
    (
        id,
        level_code,
        title,
        description,
        display_order,
        status,
        valid_from,
        valid_to,
        created_at,
        updated_at,
        created_by_user_id,
        updated_by_user_id
    )
    VALUES
    (
        @LevelBenefitId,
        @LevelCode,
        @Title,
        @Description,
        @DisplayOrder,
        @Status,
        @ValidFrom,
        @ValidTo,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId,
        @CreatedByUserId
    );

    SELECT *
    FROM dbo.loyalty_level_benefits
    WHERE id = @LevelBenefitId;
END
GO


