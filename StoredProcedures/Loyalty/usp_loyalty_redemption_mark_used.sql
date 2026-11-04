CREATE PROCEDURE [dbo].[usp_loyalty_redemption_mark_used]
    @RedemptionId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now datetime2(7) = SYSUTCDATETIME();

    BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------------
        -- 1. Registrar utilizacao
        --------------------------------------------------
        UPDATE dbo.loyalty_redemptions
        SET
            status = 'used',
            used_at = @Now,
            internal_notes = @DecisionNotes,
            decided_by_user_id = @DecidedByUserId,
            updated_at = @Now
        WHERE id = @RedemptionId
          AND status = 'approved'
          AND (
              scheduled_for IS NULL
              OR scheduled_for <= @Now
          );

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(
                'Resgate nao encontrado, nao aprovado ou com data agendada futura.',
                16,
                1
            );
        END;

        --------------------------------------------------
        -- 2. Enfileirar notificacao
        --------------------------------------------------
        EXEC dbo.usp_loyalty_redemption_notification_enqueue
            @RedemptionId = @RedemptionId,
            @EventType = 'loyalty.redemption.used';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(2048);
        SET @ErrorMessage = ERROR_MESSAGE();

        RAISERROR('%s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH;

    --------------------------------------------------
    -- 3. Retornar registro atualizado
    --------------------------------------------------
    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO