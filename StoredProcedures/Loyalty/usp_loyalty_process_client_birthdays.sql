CREATE   PROCEDURE [dbo].[usp_loyalty_process_client_birthdays]
    @ReferenceDate date = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ReferenceDate IS NULL
        SET @ReferenceDate = CONVERT(date, SYSUTCDATETIME());

    DECLARE
        @ClientId uniqueidentifier,
        @SourceId varchar(100),
        @SourceReference varchar(150),
        @ProcessedClients int = 0,
        @CreatedEvents int = 0;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT id
        FROM dbo.clients
        WHERE status = 'active'
          AND birth_date IS NOT NULL
          AND MONTH(birth_date) = MONTH(@ReferenceDate)
          AND DAY(birth_date) = DAY(@ReferenceDate);

    OPEN cur;
    FETCH NEXT FROM cur INTO @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SourceId = CONVERT(varchar(100), @ClientId);
        SET @SourceReference = CONCAT('client_birthday:', YEAR(@ReferenceDate));

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
            @SourceType = 'client',
            @ConditionType = 'client_birthday',
            @SourceId = @SourceId,
            @SourceReference = @SourceReference,
            @EventType = 'custom',
            @OccurredAt = NULL,
            @CreatedByUserId = @CreatedByUserId;

        SELECT @CreatedEvents += ISNULL(SUM(created_events), 0)
        FROM #Result;

        DROP TABLE #Result;

        SET @ProcessedClients += 1;

        FETCH NEXT FROM cur INTO @ClientId;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    SELECT
        reference_date = @ReferenceDate,
        processed_clients = @ProcessedClients,
        created_events = @CreatedEvents;
END;

GO

