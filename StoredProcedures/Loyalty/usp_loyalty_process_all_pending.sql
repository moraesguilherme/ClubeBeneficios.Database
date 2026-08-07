CREATE   PROCEDURE [dbo].[usp_loyalty_process_all_pending]
    @BatchSize int = 200,
    @ReferenceDate date = NULL,
    @NewPetCreatedFrom datetime2(7) = NULL,
    @NewPetCreatedTo datetime2(7) = NULL,
    @CreatedByUserId uniqueidentifier = NULL,
    @RunType varchar(30) = 'manual'
AS
BEGIN
    SET NOCOUNT ON;

    IF @BatchSize IS NULL OR @BatchSize < 1
        SET @BatchSize = 200;

    IF @ReferenceDate IS NULL
        SET @ReferenceDate = CONVERT(date, SYSUTCDATETIME());

    IF @NewPetCreatedTo IS NULL
        SET @NewPetCreatedTo = SYSUTCDATETIME();

    IF @NewPetCreatedFrom IS NULL
        SET @NewPetCreatedFrom = DATEADD(DAY, -1, @NewPetCreatedTo);

    DECLARE
        @StartedAt datetime2(7) = SYSUTCDATETIME(),
        @FinishedAt datetime2(7),

        @EtlProcessedRows int = 0,
        @EtlCreatedEvents int = 0,
        @EtlIgnoredRows int = 0,
        @EtlFailedRows int = 0,

        @BirthdayProcessedClients int = 0,
        @BirthdayCreatedEvents int = 0,

        @PetBirthdayProcessedPets int = 0,
        @PetBirthdayCreatedEvents int = 0,

        @NewPetProcessedPets int = 0,
        @NewPetCreatedEvents int = 0,

        @MetricsProcessedClients int = 0,
        @ReclassificationProcessedClients int = 0;

    CREATE TABLE #EtlResult
    (
        run_type varchar(30),
        processed_rows int,
        created_events int,
        ignored_rows int,
        failed_rows int,
        started_at datetime2(7),
        finished_at datetime2(7)
    );

    BEGIN TRY
        INSERT INTO #EtlResult
        EXEC dbo.usp_loyalty_process_pending_etl_rows
            @BatchSize = @BatchSize,
            @CreatedByUserId = @CreatedByUserId,
            @RunType = @RunType;

        SELECT
            @EtlProcessedRows = ISNULL(processed_rows, 0),
            @EtlCreatedEvents = ISNULL(created_events, 0),
            @EtlIgnoredRows = ISNULL(ignored_rows, 0),
            @EtlFailedRows = ISNULL(failed_rows, 0)
        FROM #EtlResult;
    END TRY
    BEGIN CATCH
        SET @EtlFailedRows += 1;

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
            NEWID(),
            NULL,
            NULL,
            'finalization',
            'failed',
            CONCAT('Falha no processamento ETL: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    DROP TABLE #EtlResult;

    CREATE TABLE #ClientBirthdayResult
    (
        reference_date date,
        processed_clients int,
        created_events int
    );

    BEGIN TRY
        INSERT INTO #ClientBirthdayResult
        EXEC dbo.usp_loyalty_process_client_birthdays
            @ReferenceDate = @ReferenceDate,
            @CreatedByUserId = @CreatedByUserId;

        SELECT
            @BirthdayProcessedClients = ISNULL(processed_clients, 0),
            @BirthdayCreatedEvents = ISNULL(created_events, 0)
        FROM #ClientBirthdayResult;
    END TRY
    BEGIN CATCH
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
            NEWID(),
            NULL,
            NULL,
            'finalization',
            'failed',
            CONCAT('Falha no processamento de aniversario do tutor: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    DROP TABLE #ClientBirthdayResult;

    CREATE TABLE #PetBirthdayResult
    (
        reference_date date,
        processed_pets int,
        created_events int
    );

    BEGIN TRY
        INSERT INTO #PetBirthdayResult
        EXEC dbo.usp_loyalty_process_pet_birthdays
            @ReferenceDate = @ReferenceDate,
            @CreatedByUserId = @CreatedByUserId;

        SELECT
            @PetBirthdayProcessedPets = ISNULL(processed_pets, 0),
            @PetBirthdayCreatedEvents = ISNULL(created_events, 0)
        FROM #PetBirthdayResult;
    END TRY
    BEGIN CATCH
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
            NEWID(),
            NULL,
            NULL,
            'finalization',
            'failed',
            CONCAT('Falha no processamento de aniversario do cao: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    DROP TABLE #PetBirthdayResult;

    CREATE TABLE #NewPetResult
    (
        created_from datetime2(7),
        created_to datetime2(7),
        processed_pets int,
        created_events int
    );

    BEGIN TRY
        INSERT INTO #NewPetResult
        EXEC dbo.usp_loyalty_process_new_pet_events
            @CreatedFrom = @NewPetCreatedFrom,
            @CreatedTo = @NewPetCreatedTo,
            @CreatedByUserId = @CreatedByUserId;

        SELECT
            @NewPetProcessedPets = ISNULL(processed_pets, 0),
            @NewPetCreatedEvents = ISNULL(created_events, 0)
        FROM #NewPetResult;
    END TRY
    BEGIN CATCH
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
            NEWID(),
            NULL,
            NULL,
            'finalization',
            'failed',
            CONCAT('Falha no processamento de novo cao cadastrado: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    DROP TABLE #NewPetResult;

    BEGIN TRY
        CREATE TABLE #MetricsResult
        (
            processed_clients int
        );

        INSERT INTO #MetricsResult
        EXEC dbo.usp_loyalty_metrics_rebuild_batch;

        SELECT
            @MetricsProcessedClients = ISNULL(processed_clients, 0)
        FROM #MetricsResult;

        DROP TABLE #MetricsResult;
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#MetricsResult') IS NOT NULL
            DROP TABLE #MetricsResult;

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
            NEWID(),
            NULL,
            NULL,
            'metrics_rebuild',
            'failed',
            CONCAT('Falha no rebuild geral de metrics: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    BEGIN TRY
        CREATE TABLE #ReclassifyResult
        (
            processed_clients int
        );

        INSERT INTO #ReclassifyResult
        EXEC dbo.usp_loyalty_reclassify_batch_by_latest_metrics
            @CreatedByUserId = @CreatedByUserId;

        SELECT
            @ReclassificationProcessedClients = ISNULL(processed_clients, 0)
        FROM #ReclassifyResult;

        DROP TABLE #ReclassifyResult;
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#ReclassifyResult') IS NOT NULL
            DROP TABLE #ReclassifyResult;

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
            NEWID(),
            NULL,
            NULL,
            'level_reclassification',
            'failed',
            CONCAT('Falha na reclassificacao geral: ', ERROR_MESSAGE()),
            NULL,
            SYSUTCDATETIME()
        );
    END CATCH;

    SET @FinishedAt = SYSUTCDATETIME();

    SELECT
        run_type = @RunType,
        reference_date = @ReferenceDate,

        etl_processed_rows = @EtlProcessedRows,
        etl_created_events = @EtlCreatedEvents,
        etl_ignored_rows = @EtlIgnoredRows,
        etl_failed_rows = @EtlFailedRows,

        client_birthday_processed_clients = @BirthdayProcessedClients,
        client_birthday_created_events = @BirthdayCreatedEvents,

        pet_birthday_processed_pets = @PetBirthdayProcessedPets,
        pet_birthday_created_events = @PetBirthdayCreatedEvents,

        new_pet_processed_pets = @NewPetProcessedPets,
        new_pet_created_events = @NewPetCreatedEvents,

        metrics_processed_clients = @MetricsProcessedClients,
        reclassification_processed_clients = @ReclassificationProcessedClients,

        total_created_events =
            ISNULL(@EtlCreatedEvents, 0)
            + ISNULL(@BirthdayCreatedEvents, 0)
            + ISNULL(@PetBirthdayCreatedEvents, 0)
            + ISNULL(@NewPetCreatedEvents, 0),

        started_at = @StartedAt,
        finished_at = @FinishedAt;
END;
GO

