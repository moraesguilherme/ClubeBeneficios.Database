CREATE   PROCEDURE [dbo].[usp_loyalty_process_new_pet_events]
    @CreatedFrom datetime2(7) = NULL,
    @CreatedTo datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CreatedTo IS NULL
        SET @CreatedTo = SYSUTCDATETIME();

    IF @CreatedFrom IS NULL
        SET @CreatedFrom = DATEADD(DAY, -1, @CreatedTo);

    DECLARE
        @PetId uniqueidentifier,
        @ClientId uniqueidentifier,
        @SourceId varchar(100),
        @ProcessedPets int = 0,
        @CreatedEvents int = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            p.id,
            p.client_id
        FROM dbo.client_pets p
        INNER JOIN dbo.clients c
            ON c.id = p.client_id
        WHERE p.status = 'active'
          AND c.status = 'active'
          AND p.created_at >= @CreatedFrom
          AND p.created_at < @CreatedTo;

    OPEN cur;
    FETCH NEXT FROM cur INTO @PetId, @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SourceId = CONVERT(varchar(100), @PetId);

        CREATE TABLE #Result
        (
            client_id uniqueidentifier,
            source_type varchar(50),
            source_id varchar(100),
            source_reference varchar(150),
            created_events int,
            ignored_rules int,
            failed_rules int
        );

        INSERT INTO #Result
        EXEC dbo.usp_loyalty_process_source_event
            @ClientId = @ClientId,
            @SourceType = 'client_pet',
            @ConditionType = 'pet_created',
            @SourceId = @SourceId,
            @SourceReference = 'pet_created',
            @EventType = 'custom',
            @OccurredAt = NULL,
            @CreatedByUserId = @CreatedByUserId;

        SELECT @CreatedEvents += ISNULL(SUM(created_events), 0)
        FROM #Result;

        DROP TABLE #Result;

        SET @ProcessedPets += 1;

        FETCH NEXT FROM cur INTO @PetId, @ClientId;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    SELECT
        created_from = @CreatedFrom,
        created_to = @CreatedTo,
        processed_pets = @ProcessedPets,
        created_events = @CreatedEvents;
END;
GO

