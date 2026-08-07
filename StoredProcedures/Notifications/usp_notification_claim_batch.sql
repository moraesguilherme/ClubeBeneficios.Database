CREATE   PROCEDURE [dbo].[usp_notification_claim_batch]
    @BatchSize INT = 20,
    @LockMinutes INT = 5,
    @LockId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    IF @BatchSize IS NULL OR @BatchSize <= 0
        SET @BatchSize = 20;

    IF @LockMinutes IS NULL OR @LockMinutes <= 0
        SET @LockMinutes = 5;

    IF @LockId IS NULL
        SET @LockId = NEWID();

    DECLARE @Claimed TABLE
    (
        id UNIQUEIDENTIFIER NOT NULL,
        attempt_number INT NOT NULL
    );

    BEGIN TRANSACTION;

    ;WITH Candidates AS
    (
        SELECT TOP (@BatchSize)
            n.id
        FROM dbo.notification_outbox n WITH (UPDLOCK, READPAST, ROWLOCK)
        WHERE n.status IN ('pending', 'failed')
          AND n.next_attempt_at <= @Now
          AND n.attempts < n.max_attempts
          AND (
                n.locked_until IS NULL
                OR n.locked_until < @Now
              )
        ORDER BY
            n.priority ASC,
            n.created_at ASC
    )
    UPDATE n
    SET
        status = 'processing',
        attempts = n.attempts + 1,
        lock_id = @LockId,
        locked_until = DATEADD(MINUTE, @LockMinutes, @Now),
        updated_at = @Now
    OUTPUT
        inserted.id,
        inserted.attempts
    INTO @Claimed
    FROM dbo.notification_outbox n
    INNER JOIN Candidates c
        ON c.id = n.id;

    INSERT INTO dbo.notification_delivery_attempts
    (
        notification_id,
        attempt_number,
        status,
        started_at
    )
    SELECT
        c.id,
        c.attempt_number,
        'processing',
        @Now
    FROM @Claimed c;

    COMMIT TRANSACTION;

    SELECT
        n.id,
        n.module,
        n.event_type,
        n.aggregate_type,
        n.aggregate_id,
        n.template_key,

        n.recipient_type,
        n.recipient_email,
        n.recipient_name,
        n.cc_emails,
        n.bcc_emails,

        n.payload_json,

        n.priority,
        n.status,
        n.attempts,
        n.max_attempts,

        n.lock_id,
        n.locked_until,

        t.id AS template_id,
        tv.id AS template_version_id,
        tv.version_number,
        tv.subject_template,
        tv.body_html_template,
        tv.body_text_template,

        n.created_at,
        n.updated_at
    FROM @Claimed c
    INNER JOIN dbo.notification_outbox n
        ON n.id = c.id
    INNER JOIN dbo.notification_templates t
        ON t.template_key = n.template_key
       AND t.is_active = 1
    INNER JOIN dbo.notification_template_versions tv
        ON tv.template_id = t.id
       AND tv.status = 'active'
    ORDER BY
        n.priority ASC,
        n.created_at ASC;
END
GO

