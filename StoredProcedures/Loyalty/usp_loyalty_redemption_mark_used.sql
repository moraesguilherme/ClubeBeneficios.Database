CREATE PROCEDURE [dbo].[usp_loyalty_redemption_mark_used]
    @RedemptionId uniqueidentifier,
    @DecisionNotes varchar(1500) = NULL,
    @DecidedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @CurrentStatus varchar(30),
        @ScheduledFor datetime2(7);

    SELECT 
        @CurrentStatus = status,
        @ScheduledFor = scheduled_for
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Resgate nao encontrado.', 16, 1);
        RETURN;
    END

    IF @CurrentStatus <> 'approved'
    BEGIN
        RAISERROR('Somente resgates approved podem ser marcados como used.', 16, 1);
        RETURN;
    END

    IF @ScheduledFor IS NOT NULL
       AND @ScheduledFor > SYSUTCDATETIME()
    BEGIN
        RAISERROR('A recompensa ainda nao pode ser marcada como utilizada antes da data agendada.', 16, 1);
        RETURN;
    END

    UPDATE dbo.loyalty_redemptions
    SET
        status = 'used',
        used_at = SYSUTCDATETIME(),
        internal_notes = @DecisionNotes,
        decided_by_user_id = @DecidedByUserId,
        updated_at = SYSUTCDATETIME()
    WHERE id = @RedemptionId;

    SELECT *
    FROM dbo.loyalty_redemptions
    WHERE id = @RedemptionId;
END
GO

