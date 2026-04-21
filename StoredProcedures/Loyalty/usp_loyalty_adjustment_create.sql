CREATE   PROCEDURE [dbo].[usp_loyalty_adjustment_create]
    @AdjustmentId uniqueidentifier,
    @ClientId uniqueidentifier,
    @AdjustmentType varchar(50),
    @ImpactType varchar(30),
    @PointsDelta int = NULL,
    @TargetEntityType varchar(50) = NULL,
    @TargetEntityId uniqueidentifier = NULL,
    @Reason varchar(1500),
    @RequestedByType varchar(30),
    @RequestedByUserId uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Reason IS NULL OR LTRIM(RTRIM(@Reason)) = ''
    BEGIN
        RAISERROR('Reason e obrigatorio.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.loyalty_adjustments
    (
        id,
        client_id,
        adjustment_type,
        impact_type,
        points_delta,
        target_entity_type,
        target_entity_id,
        reason,
        requested_by_type,
        requested_by_user_id,
        status,
        decision_notes,
        requested_at,
        decided_at,
        created_at,
        updated_at,
        decided_by_user_id
    )
    VALUES
    (
        @AdjustmentId,
        @ClientId,
        @AdjustmentType,
        @ImpactType,
        @PointsDelta,
        @TargetEntityType,
        @TargetEntityId,
        @Reason,
        @RequestedByType,
        @RequestedByUserId,
        'pending',
        NULL,
        SYSUTCDATETIME(),
        NULL,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        NULL
    );

    SELECT *
    FROM dbo.loyalty_adjustments
    WHERE id = @AdjustmentId;
END
GO


