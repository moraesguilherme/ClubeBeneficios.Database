CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefit_admin_get]
    @LevelBenefitId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        lb.id,
        lb.level_code,
        lb.title,
        lb.description,
        lb.display_order,
        lb.status,
        lb.valid_from,
        lb.valid_to,
        lb.created_at,
        lb.updated_at,
        lb.created_by_user_id,
        lb.updated_by_user_id
    FROM dbo.loyalty_level_benefits lb
    WHERE lb.id = @LevelBenefitId;
END
GO


