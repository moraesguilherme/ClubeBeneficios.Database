CREATE PROCEDURE [dbo].[usp_partner_metrics_upsert_snapshot]
    @PartnerId UNIQUEIDENTIFIER,
    @BenefitsCount INT = 0,
    @ConvertedClientsCount INT = 0,
    @CampaignsCount INT = 0,
    @RafflesCount INT = 0,
    @PerformanceScore DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.partner_metrics_snapshot AS target
    USING (
        SELECT
            @PartnerId AS partner_id,
            @BenefitsCount AS benefits_count,
            @ConvertedClientsCount AS converted_clients_count,
            @CampaignsCount AS campaigns_count,
            @RafflesCount AS raffles_count,
            @PerformanceScore AS performance_score
    ) AS source
    ON target.partner_id = source.partner_id
    WHEN MATCHED THEN
        UPDATE SET
            benefits_count = source.benefits_count,
            converted_clients_count = source.converted_clients_count,
            campaigns_count = source.campaigns_count,
            raffles_count = source.raffles_count,
            performance_score = source.performance_score,
            refreshed_at = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT
        (
            partner_id, benefits_count, converted_clients_count, campaigns_count, raffles_count, performance_score, refreshed_at
        )
        VALUES
        (
            source.partner_id, source.benefits_count, source.converted_clients_count, source.campaigns_count, source.raffles_count, source.performance_score, SYSUTCDATETIME()
        );
END
GO


