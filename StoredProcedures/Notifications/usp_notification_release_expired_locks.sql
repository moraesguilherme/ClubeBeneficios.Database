CREATE   PROCEDURE [dbo].[usp_notification_release_expired_locks]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    UPDATE dbo.notification_outbox
    SET
        status =
            CASE
                WHEN attempts >= max_attempts THEN 'dead'
                ELSE 'pending'
            END,
        locked_until = NULL,
        lock_id = NULL,
        updated_at = @Now,
        failed_at =
            CASE
                WHEN attempts >= max_attempts THEN @Now
                ELSE failed_at
            END,
        last_error =
            CASE
                WHEN attempts >= max_attempts THEN
                    COALESCE(last_error, 'Lock expirado e limite de tentativas atingido.')
                ELSE
                    COALESCE(last_error, 'Lock expirado. Notificação liberada para nova tentativa.')
            END
    WHERE status = 'processing'
      AND locked_until IS NOT NULL
      AND locked_until < @Now;
END
GO

