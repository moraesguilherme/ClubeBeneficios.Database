
CREATE PROCEDURE [dbo].[usp_loyalty_redemptions_expire_due]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();
    DECLARE @RedemptionId uniqueidentifier;
    DECLARE @ExpiredCount int = 0;

    DECLARE @ExpiredRedemptions TABLE
    (
        redemption_id uniqueidentifier NOT NULL PRIMARY KEY
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------------
        -- 1. Expirar recompensas vencidas
        --------------------------------------------------
        UPDATE dbo.loyalty_redemptions
        SET
            status = 'expired',
            updated_at = @Now

        OUTPUT inserted.id
        INTO @ExpiredRedemptions (redemption_id)

        WHERE status = 'approved'
          AND expires_at IS NOT NULL
          AND expires_at <= @Now;

        SELECT
            @ExpiredCount = COUNT(*)
        FROM @ExpiredRedemptions;

        --------------------------------------------------
        -- 2. Enfileirar notificacoes individuais
        --------------------------------------------------
        DECLARE redemption_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT redemption_id
            FROM @ExpiredRedemptions;

        OPEN redemption_cursor;

        FETCH NEXT FROM redemption_cursor
        INTO @RedemptionId;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.usp_loyalty_redemption_notification_enqueue
                @RedemptionId = @RedemptionId,
                @EventType = 'loyalty.redemption.expired';

            FETCH NEXT FROM redemption_cursor
            INTO @RedemptionId;
        END;

        CLOSE redemption_cursor;
        DEALLOCATE redemption_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'redemption_cursor') >= 0
            CLOSE redemption_cursor;

        IF CURSOR_STATUS('local', 'redemption_cursor') >= -1
            DEALLOCATE redemption_cursor;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(2048);
        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR('%s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH;

    --------------------------------------------------
    -- 3. Preservar retorno existente do Loyalty Worker
    --------------------------------------------------
    SELECT
        @ExpiredCount AS expired_redemptions;
END
GO
