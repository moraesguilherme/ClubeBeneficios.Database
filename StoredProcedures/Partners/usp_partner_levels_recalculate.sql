CREATE PROCEDURE dbo.usp_partner_levels_recalculate
    @PartnerId UNIQUEIDENTIFIER,
    @ChangedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActiveEachDirection INT;
    DECLARE @NewLevel VARCHAR(30);
    DECLARE @CurrentLevel VARCHAR(30);

    SELECT @CurrentLevel = level
    FROM dbo.partners
    WHERE id = @PartnerId;

    SELECT
        @ActiveEachDirection =
            CASE
                WHEN ISNULL(SUM(CASE WHEN direction = 'partner_to_matilha' AND status = 'active' THEN 1 ELSE 0 END), 0)
                     < ISNULL(SUM(CASE WHEN direction = 'matilha_to_partner' AND status = 'active' THEN 1 ELSE 0 END), 0)
                    THEN ISNULL(SUM(CASE WHEN direction = 'partner_to_matilha' AND status = 'active' THEN 1 ELSE 0 END), 0)
                ELSE ISNULL(SUM(CASE WHEN direction = 'matilha_to_partner' AND status = 'active' THEN 1 ELSE 0 END), 0)
            END
    FROM dbo.benefits
    WHERE partner_id = @PartnerId;

    SELECT TOP (1)
        @NewLevel = level_code
    FROM dbo.partner_level_rules
    WHERE @ActiveEachDirection >= min_active_benefits_each_direction
      AND (max_active_benefits_each_direction IS NULL OR @ActiveEachDirection <= max_active_benefits_each_direction)
    ORDER BY min_active_benefits_each_direction DESC;

    IF @NewLevel IS NOT NULL
       AND ISNULL(@CurrentLevel, '') <> ISNULL(@NewLevel, '')
    BEGIN
        UPDATE dbo.partners
        SET level = @NewLevel,
            updated_at = SYSUTCDATETIME()
        WHERE id = @PartnerId;

        INSERT INTO dbo.partner_level_history
        (
            partner_id, level_code, calculation_reference_date, assigned_at, changed_reason, changed_by_user_id
        )
        VALUES
        (
            @PartnerId,
            @NewLevel,
            CAST(SYSUTCDATETIME() AS DATE),
            SYSUTCDATETIME(),
            'Recalculo automático por quantidade de benefícios ativos em cada direção.',
            @ChangedByUserId
        );
    END

    SELECT
        @PartnerId AS partner_id,
        @CurrentLevel AS old_level,
        @NewLevel AS new_level,
        @ActiveEachDirection AS active_benefits_each_direction;
    END
GO