CREATE   PROCEDURE [dbo].[usp_loyalty_adjustment_reject]
    @AdjustmentId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStatus varchar(30);

    SELECT @CurrentStatus = status
    FROM dbo.loyalty_adjustments
    WHERE id = @AdjustmentId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Ajuste nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus <> 'pending'
    BEGIN
        RAISERROR('Somente ajustes pending podem ser rejeitados.', 16, 1);
        RETURN;
    END

    UPDATE dbo.loyalty_adjustments
    SET
        status = 'rejected',
        decision_notes = @DecisionNotes,
        decided_at = SYSUTCDATETIME(),
        decided_by_user_id = @DecidedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @AdjustmentId;

    SELECT *
    FROM dbo.loyalty_adjustments
    WHERE id = @AdjustmentId;
END
GO


