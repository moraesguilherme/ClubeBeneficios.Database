CREATE   PROCEDURE [dbo].[usp_loyalty_level_benefit_delete]
    @LevelBenefitId uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.loyalty_level_benefits
    WHERE id = @LevelBenefitId;

    SELECT CAST(1 AS bit) AS success;
END
GO

