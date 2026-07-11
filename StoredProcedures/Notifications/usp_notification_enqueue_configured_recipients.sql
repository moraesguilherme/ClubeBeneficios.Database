CREATE   PROCEDURE [dbo].[usp_notification_enqueue_configured_recipients]
    @Module VARCHAR(80),
    @EventType VARCHAR(120),
    @AggregateType VARCHAR(80) = NULL,
    @AggregateId UNIQUEIDENTIFIER = NULL,
    @TemplateKey VARCHAR(120),
    @PayloadJson NVARCHAR(MAX),
    @Priority INT = 5,
    @IdempotencyPrefix VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RecipientType VARCHAR(50),
        @RecipientEmail VARCHAR(320),
        @RecipientName VARCHAR(180),
        @IdempotencyKey VARCHAR(250);

    DECLARE @NotificationResult TABLE
    (
        notification_id UNIQUEIDENTIFIER NULL
    );

    DECLARE recipient_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            recipient_type,
            recipient_email,
            recipient_name
        FROM dbo.notification_recipients
        WHERE module = @Module
          AND event_type = @EventType
          AND is_active = 1;

    OPEN recipient_cursor;

    FETCH NEXT FROM recipient_cursor
    INTO @RecipientType, @RecipientEmail, @RecipientName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM @NotificationResult;

        SET @IdempotencyKey =
            CASE
                WHEN @IdempotencyPrefix IS NULL THEN NULL
                ELSE CONCAT(@IdempotencyPrefix, ':', @RecipientEmail)
            END;

        INSERT INTO @NotificationResult
        EXEC dbo.usp_notification_enqueue_email
            @Module = @Module,
            @EventType = @EventType,
            @AggregateType = @AggregateType,
            @AggregateId = @AggregateId,
            @TemplateKey = @TemplateKey,
            @RecipientType = @RecipientType,
            @RecipientEmail = @RecipientEmail,
            @RecipientName = @RecipientName,
            @PayloadJson = @PayloadJson,
            @Priority = @Priority,
            @IdempotencyKey = @IdempotencyKey;

        FETCH NEXT FROM recipient_cursor
        INTO @RecipientType, @RecipientEmail, @RecipientName;
    END

    CLOSE recipient_cursor;
    DEALLOCATE recipient_cursor;
END
GO

