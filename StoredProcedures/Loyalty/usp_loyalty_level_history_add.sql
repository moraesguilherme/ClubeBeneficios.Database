CREATE   PROCEDURE [dbo].[usp_loyalty_level_history_add]
    @HistoryId uniqueidentifier,
    @ClientId uniqueidentifier,
    @FromLevelCode varchar(30) = NULL,
    @ToLevelCode varchar(30),
    @ChangeReason varchar(1500) = NULL,
    @SourceType varchar(50) = NULL,
    @SourceId uniqueidentifier = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_level_history
    (
        id,
        client_id,
        from_level_code,
        to_level_code,
        change_reason,
        source_type,
        source_id,
        changed_at,
        created_at,
        created_by_user_id
    )
    VALUES
    (
        @HistoryId,
        @ClientId,
        @FromLevelCode,
        @ToLevelCode,
        @ChangeReason,
        @SourceType,
        @SourceId,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        @CreatedByUserId
    );

    SELECT *
    FROM dbo.loyalty_level_history
    WHERE id = @HistoryId;
END
GO


