CREATE   PROCEDURE [dbo].[usp_loyalty_processing_log_add]
    @LogId uniqueidentifier,
    @ImportRowId bigint = NULL,
    @ClientId uniqueidentifier = NULL,
    @ProcessingStage varchar(30),
    @ProcessingStatus varchar(30),
    @Message varchar(1500) = NULL,
    @LoyaltyEventId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_processing_log
    (
        id,
        import_row_id,
        client_id,
        processing_stage,
        processing_status,
        message,
        loyalty_event_id,
        created_at
    )
    VALUES
    (
        @LogId,
        ISNULL(@ImportRowId, 0),
        @ClientId,
        @ProcessingStage,
        @ProcessingStatus,
        @Message,
        @LoyaltyEventId,
        SYSUTCDATETIME()
    );

    SELECT *
    FROM dbo.loyalty_processing_log
    WHERE id = @LogId;
END
GO

