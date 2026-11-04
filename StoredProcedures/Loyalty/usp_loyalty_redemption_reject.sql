
CREATE PROCEDURE [dbo].[usp_loyalty_redemption_reject]
    @RedemptionId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------------
        -- 1. Rejeitar somente solicitacoes elegiveis
        --------------------------------------------------
        UPDATE dbo.loyalty_redemptions
        SET
            status = 'rejected',
            rejected_at = SYSUTCDATETIME(),
            internal_notes = @DecisionNotes,
            decided_by_user_id = @DecidedByUserId,
            updated_at = SYSUTCDATETIME()
        WHERE id = @RedemptionId
          AND status IN ('requested', 'under_review');

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(
                'Resgate nao encontrado ou nao disponivel para rejeicao.',
                16,
                1
            );
        END;

        --------------------------------------------------
        -- 2. Registrar a notificacao
        --------------------------------------------------
        EXEC dbo.usp_loyalty_redemption_notification_enqueue
            @RedemptionId = @RedemptionId,
            @EventType = 'loyalty.redemption.rejected';

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
    -- 3. Retornar o resgate atualizado
    --------------------------------------------------
    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO