CREATE   PROCEDURE [dbo].[usp_loyalty_process_pet_birthdays]
    @ReferenceDate date = NULL,
    @CreatedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ReferenceDate IS NULL
        SET @ReferenceDate = CONVERT(date, SYSUTCDATETIME());

    DECLARE
        @PetId uniqueidentifier,
        @ClientId uniqueidentifier,
        @SourceId varchar(100),
        @SourceReference varchar(150),
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
          AND p.birth_date IS NOT NULL
          AND MONTH(p.birth_date) = MONTH(@ReferenceDate)
          AND DAY(p.birth_date) = DAY(@ReferenceDate);

    OPEN cur;
    FETCH NEXT FROM cur INTO @PetId, @ClientId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SourceId = CONVERT(varchar(100), @PetId);
        SET @SourceReference = CONCAT('pet_birthday:', YEAR(@ReferenceDate));

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
            @ConditionType = 'pet_birthday',
            @SourceId = @SourceId,
            @SourceReference = @SourceReference,
            @EventType = 'pet_birthday_bonus',
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
        reference_date = @ReferenceDate,
        processed_pets = @ProcessedPets,
        created_events = @CreatedEvents;
END;
GO

