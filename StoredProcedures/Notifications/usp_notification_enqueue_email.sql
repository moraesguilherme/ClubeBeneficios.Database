CREATE   PROCEDURE [dbo].[usp_notification_enqueue_email]
    @Module VARCHAR(80),
    @EventType VARCHAR(120),
    @AggregateType VARCHAR(80) = NULL,
    @AggregateId UNIQUEIDENTIFIER = NULL,
    @TemplateKey VARCHAR(120),
    @RecipientType VARCHAR(50),
    @RecipientEmail VARCHAR(320),
    @RecipientName VARCHAR(180) = NULL,
    @CcEmails VARCHAR(1000) = NULL,
    @BccEmails VARCHAR(1000) = NULL,
    @PayloadJson NVARCHAR(MAX),
    @Priority INT = 5,
    @ScheduledAt DATETIME2(7) = NULL,
    @IdempotencyKey VARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NotificationId UNIQUEIDENTIFIER;

    IF @ScheduledAt IS NULL
        SET @ScheduledAt = SYSUTCDATETIME();

    IF @RecipientEmail IS NULL OR LTRIM(RTRIM(@RecipientEmail)) = ''
    BEGIN
        SELECT CAST(NULL AS UNIQUEIDENTIFIER) AS notification_id;
        RETURN;
    END

    IF @IdempotencyKey IS NOT NULL
    BEGIN
        SELECT
            @NotificationId = id
        FROM dbo.notification_outbox
        WHERE idempotency_key = @IdempotencyKey;

        IF @NotificationId IS NOT NULL
        BEGIN
            SELECT @NotificationId AS notification_id;
            RETURN;
        END
    END

    SET @NotificationId = NEWID();

    INSERT INTO dbo.notification_outbox
    (
        id,
        module,
        event_type,
        aggregate_type,
        aggregate_id,
        template_key,
        recipient_type,
        recipient_email,
        recipient_name,
        cc_emails,
        bcc_emails,
        payload_json,
        priority,
        status,
        next_attempt_at,
        idempotency_key,
        created_at,
        updated_at
    )
    VALUES
    (
        @NotificationId,
        @Module,
        @EventType,
        @AggregateType,
        @AggregateId,
        @TemplateKey,
        @RecipientType,
        @RecipientEmail,
        @RecipientName,
        @CcEmails,
        @BccEmails,
        @PayloadJson,
        @Priority,
        'pending',
        @ScheduledAt,
        @IdempotencyKey,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    );

    SELECT @NotificationId AS notification_id;
END
GO

