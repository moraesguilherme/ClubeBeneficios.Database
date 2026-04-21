
CREATE PROCEDURE [dbo].[usp_loyalty_event_create_from_etl_row_and_rebuild_balance]
    @EventId uniqueidentifier,
    @ImportRowId bigint,
    @ClientId uniqueidentifier,
    @EventType varchar(50),
    @MovementType varchar(30),
    @PointsDelta int,
    @RuleId uniqueidentifier = NULL,
    @CampaignId uniqueidentifier = NULL,
    @PaymentReference varchar(150) = NULL,
    @Description varchar(1500) = NULL,
    @OccurredAt datetime2(7) = NULL,
    @EffectiveAt datetime2(7) = NULL,
    @ExpiresAt datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        EXEC dbo.usp_loyalty_event_create_from_etl_row
            @EventId = @EventId,
            @ImportRowId = @ImportRowId,
            @ClientId = @ClientId,
            @EventType = @EventType,
            @MovementType = @MovementType,
            @PointsDelta = @PointsDelta,
            @RuleId = @RuleId,
            @CampaignId = @CampaignId,
            @PaymentReference = @PaymentReference,
            @Description = @Description,
            @OccurredAt = @OccurredAt,
            @EffectiveAt = @EffectiveAt,
            @ExpiresAt = @ExpiresAt,
            @CreatedByUserId = @CreatedByUserId;

        EXEC dbo.usp_customer_loyalty_balance_rebuild
            @ClientId = @ClientId;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH;

    SELECT *
    FROM dbo.customer_loyalty_events
    WHERE id = @EventId;
END

GO


