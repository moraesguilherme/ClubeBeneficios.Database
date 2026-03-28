CREATE PROCEDURE dbo.usp_partners_create
    @TradeName VARCHAR(150),
    @LegalName VARCHAR(150) = NULL,
    @Document VARCHAR(30) = NULL,
    @Email VARCHAR(150) = NULL,
    @Phone VARCHAR(30) = NULL,
    @LogoUrl VARCHAR(500) = NULL,
    @Segment VARCHAR(120) = NULL,
    @Category VARCHAR(120) = NULL,
    @ServiceRegion VARCHAR(180) = NULL,
    @Website VARCHAR(250) = NULL,
    @Instagram VARCHAR(150) = NULL,
    @Description VARCHAR(1200) = NULL,
    @Level VARCHAR(30) = NULL,
    @IndicationFlowEnabled BIT = 1,
    @AccessCodeFlowEnabled BIT = 1,
    @OriginType VARCHAR(30) = 'admin_created',
    @Status VARCHAR(30) = 'active',

    @ResponsibleName VARCHAR(180) = NULL,
    @ResponsibleRole VARCHAR(120) = NULL,
    @ResponsibleEmail VARCHAR(150) = NULL,
    @ResponsiblePhone VARCHAR(30) = NULL,

    @CreatedByUserId UNIQUEIDENTIFIER = NULL,
    @InitialNote VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PartnerId UNIQUEIDENTIFIER = NEWID();

    BEGIN TRANSACTION;

        INSERT INTO dbo.partners
        (
            id, trade_name, legal_name, document, email, phone, status, logo_url,
            segment, category, service_region, website, instagram, description, level,
            indication_flow_enabled, access_code_flow_enabled, origin_type,
            created_by_user_id, approved_at, approved_by_user_id, created_at, updated_at
        )
        VALUES
        (
            @PartnerId, @TradeName, @LegalName, @Document, @Email, @Phone, @Status, @LogoUrl,
            @Segment, @Category, @ServiceRegion, @Website, @Instagram, @Description, @Level,
            @IndicationFlowEnabled, @AccessCodeFlowEnabled, @OriginType,
            @CreatedByUserId,
            CASE WHEN @Status = 'active' THEN SYSUTCDATETIME() ELSE NULL END,
            CASE WHEN @Status = 'active' THEN @CreatedByUserId ELSE NULL END,
            SYSUTCDATETIME(), SYSUTCDATETIME()
        );

        IF @ResponsibleName IS NOT NULL
        BEGIN
            INSERT INTO dbo.partner_contacts
            (
                id, partner_id, name, role_name, email, phone, is_primary, is_active, created_at, updated_at
            )
            VALUES
            (
                NEWID(), @PartnerId, @ResponsibleName, @ResponsibleRole, @ResponsibleEmail, @ResponsiblePhone, 1, 1, SYSUTCDATETIME(), SYSUTCDATETIME()
            );
        END

        INSERT INTO dbo.partner_status_history
        (
            partner_id, from_status, to_status, reason, changed_by_user_id, changed_at
        )
        VALUES
        (
            @PartnerId, NULL, @Status, 'Cadastro inicial do parceiro.', @CreatedByUserId, SYSUTCDATETIME()
        );

        IF @InitialNote IS NOT NULL
        BEGIN
            INSERT INTO dbo.partner_notes
            (
                partner_id, note_type, content, created_by_user_id, created_at
            )
            VALUES
            (
                @PartnerId, 'general', @InitialNote, @CreatedByUserId, SYSUTCDATETIME()
            );
        END

        INSERT INTO dbo.partner_metrics_snapshot
        (
            partner_id, benefits_count, converted_clients_count, campaigns_count, raffles_count, performance_score, refreshed_at
        )
        VALUES
        (
            @PartnerId, 0, 0, 0, 0, NULL, SYSUTCDATETIME()
        );

    COMMIT TRANSACTION;

    SELECT @PartnerId AS partner_id;
END
GO
