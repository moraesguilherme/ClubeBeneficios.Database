CREATE   PROCEDURE [dbo].[usp_loyalty_reclassify_client_by_latest_score]
    @ClientId uniqueidentifier,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @LatestLevelCode varchar(30),
        @CurrentLevelCode varchar(30),
        @HistoryId uniqueidentifier;

    SELECT TOP 1
        @LatestLevelCode = s.level_code
    FROM dbo.loyalty_score_snapshots s
    WHERE s.client_id = @ClientId
    ORDER BY s.calculated_at DESC, s.created_at DESC;

    IF @LatestLevelCode IS NULL
    BEGIN
        RAISERROR('Cliente sem score calculado.', 16, 1);
        RETURN;
    END

    SELECT TOP 1
        @CurrentLevelCode = h.to_level_code
    FROM dbo.loyalty_level_history h
    WHERE h.client_id = @ClientId
    ORDER BY h.changed_at DESC, h.created_at DESC;

    IF @CurrentLevelCode IS NULL
    BEGIN
        SET @HistoryId = NEWID();

        EXEC dbo.usp_loyalty_level_history_add
            @HistoryId = @HistoryId,
            @ClientId = @ClientId,
            @FromLevelCode = NULL,
            @ToLevelCode = @LatestLevelCode,
            @ChangeReason = 'Primeira classificacao automatica com base no score.',
            @SourceType = 'score_reclassification',
            @SourceId = NULL,
            @CreatedByUserId = @CreatedByUserId;

        SELECT CAST(1 AS bit) AS reclassified, @LatestLevelCode AS new_level_code;
        RETURN;
    END

    IF @CurrentLevelCode <> @LatestLevelCode
    BEGIN
        SET @HistoryId = NEWID();

        EXEC dbo.usp_loyalty_level_history_add
            @HistoryId = @HistoryId,
            @ClientId = @ClientId,
            @FromLevelCode = @CurrentLevelCode,
            @ToLevelCode = @LatestLevelCode,
            @ChangeReason = 'Reclassificacao automatica com base no score mais recente.',
            @SourceType = 'score_reclassification',
            @SourceId = NULL,
            @CreatedByUserId = @CreatedByUserId;

        SELECT CAST(1 AS bit) AS reclassified, @LatestLevelCode AS new_level_code;
        RETURN;
    END

    SELECT CAST(0 AS bit) AS reclassified, @LatestLevelCode AS new_level_code;
END
GO

