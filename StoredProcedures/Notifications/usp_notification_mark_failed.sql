CREATE   PROCEDURE [dbo].[usp_notification_mark_failed]
    @NotificationId UNIQUEIDENTIFIER,
    @LockId UNIQUEIDENTIFIER,
    @ErrorMessage VARCHAR(MAX),
    @RetryDelayMinutes INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();
    DECLARE @AttemptNumber INT;
    DECLARE @Attempts INT;
    DECLARE @MaxAttempts INT;
    DECLARE @NextStatus VARCHAR(30);
    DECLARE @NextAttemptAt DATETIME2(7);

    SELECT
        @AttemptNumber = attempts,
        @Attempts = attempts,
        @MaxAttempts = max_attempts
    FROM dbo.notification_outbox
    WHERE id = @NotificationId
      AND lock_id = @LockId
      AND status = 'processing';

    IF @AttemptNumber IS NULL
    BEGIN
        RAISERROR('Notificação não encontrada ou lock inválido para marcação como falha.', 16, 1);
        RETURN;
    END

    IF @RetryDelayMinutes IS NULL OR @RetryDelayMinutes <= 0
    BEGIN
        SET @RetryDelayMinutes =
            CASE
                WHEN @Attempts <= 1 THEN 5
                WHEN @Attempts = 2 THEN 15
                WHEN @Attempts = 3 THEN 60
                ELSE 180
            END;
    END

    IF @Attempts >= @MaxAttempts
    BEGIN
        SET @NextStatus = 'dead';
        SET @NextAttemptAt = @Now;
    END
    ELSE
    BEGIN
        SET @NextStatus = 'failed';
        SET @NextAttemptAt = DATEADD(MINUTE, @RetryDelayMinutes, @Now);
    END

    BEGIN TRANSACTION;

    UPDATE dbo.notification_outbox
    SET
        status = @NextStatus,
        next_attempt_at = @NextAttemptAt,
        failed_at =
            CASE
                WHEN @NextStatus = 'dead' THEN @Now
                ELSE failed_at
            END,
        last_error = @ErrorMessage,
        locked_until = NULL,
        lock_id = NULL,
        updated_at = @Now
    WHERE id = @NotificationId
      AND lock_id = @LockId
      AND status = 'processing';

    UPDATE dbo.notification_delivery_attempts
    SET
        status = 'failed',
        error_message = @ErrorMessage,
        finished_at = @Now
    WHERE notification_id = @NotificationId
      AND attempt_number = @AttemptNumber
      AND status = 'processing';

    COMMIT TRANSACTION;
END
GO

