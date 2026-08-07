CREATE   PROCEDURE [dbo].[usp_notification_mark_sent]
    @NotificationId UNIQUEIDENTIFIER,
    @LockId UNIQUEIDENTIFIER,
    @SmtpMessageId VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();
    DECLARE @AttemptNumber INT;

    SELECT
        @AttemptNumber = attempts
    FROM dbo.notification_outbox
    WHERE id = @NotificationId
      AND lock_id = @LockId
      AND status = 'processing';

    IF @AttemptNumber IS NULL
    BEGIN
        RAISERROR('Notificação não encontrada ou lock inválido para marcação como enviada.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    UPDATE dbo.notification_outbox
    SET
        status = 'sent',
        smtp_message_id = @SmtpMessageId,
        sent_at = @Now,
        failed_at = NULL,
        last_error = NULL,
        locked_until = NULL,
        lock_id = NULL,
        updated_at = @Now
    WHERE id = @NotificationId
      AND lock_id = @LockId
      AND status = 'processing';

    UPDATE dbo.notification_delivery_attempts
    SET
        status = 'sent',
        smtp_message_id = @SmtpMessageId,
        finished_at = @Now
    WHERE notification_id = @NotificationId
      AND attempt_number = @AttemptNumber
      AND status = 'processing';

    COMMIT TRANSACTION;
END
GO

