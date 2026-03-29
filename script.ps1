# ==========================
# Sync-PartnersDatabaseProject.ps1
# Execute na raiz do repositório ClubeBeneficios.Database
# ==========================

$ErrorActionPreference = "Stop"

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path .).Path + "\" + $Path, $Content.TrimStart(), $utf8NoBom)
    Write-Host "Atualizado: $Path"
}

# ==========================
# 1) TABLES
# ==========================

$partnerNotesSql = @'
CREATE TABLE dbo.partner_notes
(
    id BIGINT NOT NULL IDENTITY(1,1),
    partner_id UNIQUEIDENTIFIER NOT NULL,
    note_type VARCHAR(30) NOT NULL
        CONSTRAINT DF_partner_notes_type DEFAULT ('general'),
    content VARCHAR(MAX) NOT NULL,
    created_by_user_id UNIQUEIDENTIFIER NULL,
    created_at DATETIME2(7) NOT NULL,

    CONSTRAINT PK_partner_notes
        PRIMARY KEY CLUSTERED (id ASC),

    CONSTRAINT FK_partner_notes_partners
        FOREIGN KEY (partner_id)
        REFERENCES dbo.partners(id),

    CONSTRAINT FK_partner_notes_users
        FOREIGN KEY (created_by_user_id)
        REFERENCES dbo.users(id),

    CONSTRAINT CK_partner_notes_type
        CHECK ([note_type] IN ('general', 'commercial', 'operational', 'approval'))
);
GO

CREATE INDEX IX_partner_notes_partner_created_at
    ON dbo.partner_notes(partner_id, created_at DESC);
GO
'@

$partnerStatusHistorySql = @'
CREATE TABLE dbo.partner_status_history
(
    id BIGINT NOT NULL IDENTITY(1,1),
    partner_id UNIQUEIDENTIFIER NOT NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    reason VARCHAR(800) NULL,
    changed_by_user_id UNIQUEIDENTIFIER NULL,
    changed_at DATETIME2(7) NOT NULL,

    CONSTRAINT PK_partner_status_history
        PRIMARY KEY CLUSTERED (id ASC),

    CONSTRAINT FK_partner_status_history_partners
        FOREIGN KEY (partner_id)
        REFERENCES dbo.partners(id),

    CONSTRAINT FK_partner_status_history_users
        FOREIGN KEY (changed_by_user_id)
        REFERENCES dbo.users(id)
);
GO

CREATE INDEX IX_partner_status_history_partner_changed_at
    ON dbo.partner_status_history(partner_id, changed_at DESC);
GO
'@

Write-Utf8File -Path "Tables\Partners\partner_notes.sql" -Content $partnerNotesSql
Write-Utf8File -Path "Tables\Partners\partner_status_history.sql" -Content $partnerStatusHistorySql

# ==========================
# 2) STORED PROCEDURES
# ==========================

$uspPartnersAdminSearch = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_admin_search
    @Search         VARCHAR(150) = NULL,
    @Status         VARCHAR(30)  = NULL,
    @Level          VARCHAR(30)  = NULL,
    @Category       VARCHAR(120) = NULL,
    @Segment        VARCHAR(120) = NULL,
    @SortBy         VARCHAR(50)  = 'created_at',
    @SortDirection  VARCHAR(4)   = 'desc',
    @Page           INT          = 1,
    @PageSize       INT          = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 SET @PageSize = 20;
    IF @PageSize > 200 SET @PageSize = 200;

    SET @SortBy = LOWER(ISNULL(@SortBy, 'created_at'));
    SET @SortDirection = LOWER(ISNULL(@SortDirection, 'desc'));

    ;WITH filtered AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS total_count
        FROM dbo.vw_partners_admin_list v
        WHERE
            (
                @Search IS NULL
                OR LTRIM(RTRIM(@Search)) = ''
                OR v.trade_name        LIKE '%' + @Search + '%'
                OR v.legal_name        LIKE '%' + @Search + '%'
                OR v.document          LIKE '%' + @Search + '%'
                OR v.email             LIKE '%' + @Search + '%'
                OR v.segment           LIKE '%' + @Search + '%'
                OR v.category          LIKE '%' + @Search + '%'
                OR v.service_region    LIKE '%' + @Search + '%'
                OR v.responsible_name  LIKE '%' + @Search + '%'
                OR v.responsible_email LIKE '%' + @Search + '%'
            )
            AND (@Status IS NULL OR @Status = '' OR v.status = @Status)
            AND (@Level IS NULL OR @Level = '' OR v.level = @Level)
            AND (@Category IS NULL OR @Category = '' OR v.category = @Category)
            AND (@Segment IS NULL OR @Segment = '' OR v.segment = @Segment)
    )
    SELECT
        id,
        trade_name,
        legal_name,
        document,
        email,
        phone,
        status,
        logo_url,
        segment,
        category,
        service_region,
        website,
        instagram,
        description,
        level,
        indication_flow_enabled,
        access_code_flow_enabled,
        origin_type,
        created_at,
        updated_at,
        approved_at,
        rejected_at,
        inactivated_at,
        created_by_user_id,
        approved_by_user_id,
        rejected_by_user_id,
        responsible_name,
        responsible_role,
        responsible_email,
        responsible_phone,
        benefits_count,
        converted_clients_count,
        campaigns_count,
        raffles_count,
        performance_score,
        metrics_refreshed_at,
        total_count
    FROM filtered
    ORDER BY
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'asc' THEN trade_name END ASC,
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'desc' THEN trade_name END DESC,
        CASE WHEN @SortBy = 'status' AND @SortDirection = 'asc' THEN status END ASC,
        CASE WHEN @SortBy = 'status' AND @SortDirection = 'desc' THEN status END DESC,
        CASE WHEN @SortBy = 'level' AND @SortDirection = 'asc' THEN level END ASC,
        CASE WHEN @SortBy = 'level' AND @SortDirection = 'desc' THEN level END DESC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'asc' THEN category END ASC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'desc' THEN category END DESC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'asc' THEN segment END ASC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'desc' THEN segment END DESC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'asc' THEN created_at END ASC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'desc' THEN created_at END DESC,
        CASE WHEN @SortBy = 'updated_at' AND @SortDirection = 'asc' THEN updated_at END ASC,
        CASE WHEN @SortBy = 'updated_at' AND @SortDirection = 'desc' THEN updated_at END DESC,
        CASE WHEN @SortBy = 'performance_score' AND @SortDirection = 'asc' THEN performance_score END ASC,
        CASE WHEN @SortBy = 'performance_score' AND @SortDirection = 'desc' THEN performance_score END DESC,
        created_at DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
'@

$uspPartnersPendingSearch = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_pending_search
    @Search         VARCHAR(150) = NULL,
    @Category       VARCHAR(120) = NULL,
    @Segment        VARCHAR(120) = NULL,
    @SortBy         VARCHAR(50)  = 'created_at',
    @SortDirection  VARCHAR(4)   = 'desc',
    @Page           INT          = 1,
    @PageSize       INT          = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 SET @PageSize = 20;
    IF @PageSize > 200 SET @PageSize = 200;

    SET @SortBy = LOWER(ISNULL(@SortBy, 'created_at'));
    SET @SortDirection = LOWER(ISNULL(@SortDirection, 'desc'));

    ;WITH filtered AS
    (
        SELECT
            v.*,
            COUNT(1) OVER() AS total_count
        FROM dbo.vw_partners_admin_list v
        WHERE
            v.status IN ('pending_review', 'under_review')
            AND (
                @Search IS NULL
                OR LTRIM(RTRIM(@Search)) = ''
                OR v.trade_name        LIKE '%' + @Search + '%'
                OR v.legal_name        LIKE '%' + @Search + '%'
                OR v.document          LIKE '%' + @Search + '%'
                OR v.email             LIKE '%' + @Search + '%'
                OR v.segment           LIKE '%' + @Search + '%'
                OR v.category          LIKE '%' + @Search + '%'
                OR v.service_region    LIKE '%' + @Search + '%'
                OR v.responsible_name  LIKE '%' + @Search + '%'
                OR v.responsible_email LIKE '%' + @Search + '%'
            )
            AND (@Category IS NULL OR @Category = '' OR v.category = @Category)
            AND (@Segment IS NULL OR @Segment = '' OR v.segment = @Segment)
    )
    SELECT
        id,
        trade_name,
        legal_name,
        document,
        email,
        phone,
        status,
        logo_url,
        segment,
        category,
        service_region,
        website,
        instagram,
        description,
        level,
        indication_flow_enabled,
        access_code_flow_enabled,
        origin_type,
        created_at,
        updated_at,
        approved_at,
        rejected_at,
        inactivated_at,
        created_by_user_id,
        approved_by_user_id,
        rejected_by_user_id,
        responsible_name,
        responsible_role,
        responsible_email,
        responsible_phone,
        benefits_count,
        converted_clients_count,
        campaigns_count,
        raffles_count,
        performance_score,
        metrics_refreshed_at,
        total_count
    FROM filtered
    ORDER BY
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'asc' THEN trade_name END ASC,
        CASE WHEN @SortBy = 'trade_name' AND @SortDirection = 'desc' THEN trade_name END DESC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'asc' THEN category END ASC,
        CASE WHEN @SortBy = 'category' AND @SortDirection = 'desc' THEN category END DESC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'asc' THEN segment END ASC,
        CASE WHEN @SortBy = 'segment' AND @SortDirection = 'desc' THEN segment END DESC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'asc' THEN created_at END ASC,
        CASE WHEN @SortBy = 'created_at' AND @SortDirection = 'desc' THEN created_at END DESC,
        created_at DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
'@

$uspPartnersAdminSummary = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_admin_summary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(1) AS total_partners,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_partners,
        SUM(CASE WHEN status = 'pending_review' THEN 1 ELSE 0 END) AS pending_review_partners,
        SUM(CASE WHEN status = 'under_review' THEN 1 ELSE 0 END) AS under_review_partners,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved_partners,
        SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) AS inactive_partners,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected_partners,
        SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END) AS suspended_partners,
        SUM(CASE WHEN status = 'blocked' THEN 1 ELSE 0 END) AS blocked_partners,
        SUM(CASE WHEN level = 'bronze' THEN 1 ELSE 0 END) AS bronze_count,
        SUM(CASE WHEN level = 'silver' THEN 1 ELSE 0 END) AS silver_count,
        SUM(CASE WHEN level = 'gold' THEN 1 ELSE 0 END) AS gold_count,
        SUM(CASE WHEN level = 'diamond' THEN 1 ELSE 0 END) AS diamond_count,
        SUM(CASE WHEN level = 'platinum' THEN 1 ELSE 0 END) AS platinum_count
    FROM dbo.partners;
END
GO
'@

$uspPartnersCreate = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_create
    @TradeName                VARCHAR(150),
    @LegalName                VARCHAR(150) = NULL,
    @Document                 VARCHAR(30) = NULL,
    @Email                    VARCHAR(150) = NULL,
    @Phone                    VARCHAR(30) = NULL,
    @LogoUrl                  VARCHAR(500) = NULL,
    @Segment                  VARCHAR(120) = NULL,
    @Category                 VARCHAR(120) = NULL,
    @ServiceRegion            VARCHAR(180) = NULL,
    @Website                  VARCHAR(250) = NULL,
    @Instagram                VARCHAR(150) = NULL,
    @Description              VARCHAR(1200) = NULL,
    @Level                    VARCHAR(30) = NULL,
    @IndicationFlowEnabled    BIT = 1,
    @AccessCodeFlowEnabled    BIT = 1,
    @OriginType               VARCHAR(30) = 'admin_created',
    @Status                   VARCHAR(30) = 'active',
    @ResponsibleName          VARCHAR(180) = NULL,
    @ResponsibleRole          VARCHAR(120) = NULL,
    @ResponsibleEmail         VARCHAR(150) = NULL,
    @ResponsiblePhone         VARCHAR(30) = NULL,
    @CreatedByUserId          UNIQUEIDENTIFIER = NULL,
    @InitialNote              VARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PartnerId UNIQUEIDENTIFIER = NEWID();
    DECLARE @ContactId UNIQUEIDENTIFIER = NEWID();
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    INSERT INTO dbo.partners
    (
        id,
        trade_name,
        legal_name,
        document,
        email,
        phone,
        status,
        logo_url,
        segment,
        category,
        service_region,
        website,
        instagram,
        description,
        level,
        indication_flow_enabled,
        access_code_flow_enabled,
        origin_type,
        created_by_user_id,
        created_at,
        updated_at
    )
    VALUES
    (
        @PartnerId,
        @TradeName,
        @LegalName,
        @Document,
        @Email,
        @Phone,
        @Status,
        @LogoUrl,
        @Segment,
        @Category,
        @ServiceRegion,
        @Website,
        @Instagram,
        @Description,
        @Level,
        @IndicationFlowEnabled,
        @AccessCodeFlowEnabled,
        @OriginType,
        @CreatedByUserId,
        @Now,
        @Now
    );

    IF COALESCE(@ResponsibleName, @ResponsibleRole, @ResponsibleEmail, @ResponsiblePhone) IS NOT NULL
    BEGIN
        INSERT INTO dbo.partner_contacts
        (
            id,
            partner_id,
            name,
            role_name,
            email,
            phone,
            is_primary,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            @ContactId,
            @PartnerId,
            ISNULL(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), @TradeName),
            @ResponsibleRole,
            @ResponsibleEmail,
            @ResponsiblePhone,
            1,
            1,
            @Now,
            @Now
        );
    END

    INSERT INTO dbo.partner_status_history
    (
        partner_id,
        from_status,
        to_status,
        reason,
        changed_by_user_id,
        changed_at
    )
    VALUES
    (
        @PartnerId,
        NULL,
        @Status,
        'Criação inicial do parceiro.',
        @CreatedByUserId,
        @Now
    );

    IF @InitialNote IS NOT NULL AND LTRIM(RTRIM(@InitialNote)) <> ''
    BEGIN
        INSERT INTO dbo.partner_notes
        (
            partner_id,
            note_type,
            content,
            created_by_user_id,
            created_at
        )
        VALUES
        (
            @PartnerId,
            'general',
            @InitialNote,
            @CreatedByUserId,
            @Now
        );
    END

    SELECT @PartnerId AS id;
END
GO
'@

$uspPartnersUpdate = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_update
    @PartnerId                UNIQUEIDENTIFIER,
    @TradeName                VARCHAR(150) = NULL,
    @LegalName                VARCHAR(150) = NULL,
    @Document                 VARCHAR(30) = NULL,
    @Email                    VARCHAR(150) = NULL,
    @Phone                    VARCHAR(30) = NULL,
    @LogoUrl                  VARCHAR(500) = NULL,
    @Segment                  VARCHAR(120) = NULL,
    @Category                 VARCHAR(120) = NULL,
    @ServiceRegion            VARCHAR(180) = NULL,
    @Website                  VARCHAR(250) = NULL,
    @Instagram                VARCHAR(150) = NULL,
    @Description              VARCHAR(1200) = NULL,
    @Level                    VARCHAR(30) = NULL,
    @ResponsibleName          VARCHAR(180) = NULL,
    @ResponsibleRole          VARCHAR(120) = NULL,
    @ResponsibleEmail         VARCHAR(150) = NULL,
    @ResponsiblePhone         VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.partners
       SET trade_name = @TradeName,
           legal_name = @LegalName,
           document = @Document,
           email = @Email,
           phone = @Phone,
           logo_url = @LogoUrl,
           segment = @Segment,
           category = @Category,
           service_region = @ServiceRegion,
           website = @Website,
           instagram = @Instagram,
           description = @Description,
           level = @Level,
           updated_at = SYSUTCDATETIME()
     WHERE id = @PartnerId;

    IF EXISTS (
        SELECT 1
        FROM dbo.partner_contacts
        WHERE partner_id = @PartnerId
          AND is_primary = 1
    )
    BEGIN
        UPDATE dbo.partner_contacts
           SET name = ISNULL(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), name),
               role_name = @ResponsibleRole,
               email = @ResponsibleEmail,
               phone = @ResponsiblePhone,
               is_active = 1,
               updated_at = SYSUTCDATETIME()
         WHERE partner_id = @PartnerId
           AND is_primary = 1;
    END
    ELSE IF COALESCE(@ResponsibleName, @ResponsibleRole, @ResponsibleEmail, @ResponsiblePhone) IS NOT NULL
    BEGIN
        INSERT INTO dbo.partner_contacts
        (
            id,
            partner_id,
            name,
            role_name,
            email,
            phone,
            is_primary,
            is_active,
            created_at,
            updated_at
        )
        VALUES
        (
            NEWID(),
            @PartnerId,
            ISNULL(NULLIF(LTRIM(RTRIM(@ResponsibleName)), ''), @TradeName),
            @ResponsibleRole,
            @ResponsibleEmail,
            @ResponsiblePhone,
            1,
            1,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        );
    END
END
GO
'@

$uspPartnersChangeStatus = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_change_status
    @PartnerId        UNIQUEIDENTIFIER,
    @NewStatus        VARCHAR(30),
    @Reason           VARCHAR(800) = NULL,
    @ChangedByUserId  UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldStatus VARCHAR(30);
    DECLARE @Now DATETIME2(7) = SYSUTCDATETIME();

    SELECT @OldStatus = status
      FROM dbo.partners
     WHERE id = @PartnerId;

    UPDATE dbo.partners
       SET status = @NewStatus,
           approved_at = CASE WHEN @NewStatus = 'approved' THEN @Now ELSE approved_at END,
           rejected_at = CASE WHEN @NewStatus = 'rejected' THEN @Now ELSE rejected_at END,
           inactivated_at = CASE WHEN @NewStatus = 'inactive' THEN @Now ELSE inactivated_at END,
           approved_by_user_id = CASE WHEN @NewStatus = 'approved' THEN @ChangedByUserId ELSE approved_by_user_id END,
           rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
           updated_at = @Now
     WHERE id = @PartnerId;

    INSERT INTO dbo.partner_status_history
    (
        partner_id,
        from_status,
        to_status,
        reason,
        changed_by_user_id,
        changed_at
    )
    VALUES
    (
        @PartnerId,
        @OldStatus,
        @NewStatus,
        @Reason,
        @ChangedByUserId,
        @Now
    );
END
GO
'@

$uspPartnersAddNote = @'
CREATE OR ALTER PROCEDURE dbo.usp_partners_add_note
    @PartnerId         UNIQUEIDENTIFIER,
    @NoteType          VARCHAR(30) = 'general',
    @Content           VARCHAR(MAX),
    @CreatedByUserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.partner_notes
    (
        partner_id,
        note_type,
        content,
        created_by_user_id,
        created_at
    )
    VALUES
    (
        @PartnerId,
        ISNULL(NULLIF(LTRIM(RTRIM(@NoteType)), ''), 'general'),
        @Content,
        @CreatedByUserId,
        SYSUTCDATETIME()
    );
END
GO
'@

Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_admin_search.sql" -Content $uspPartnersAdminSearch
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_pending_search.sql" -Content $uspPartnersPendingSearch
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_admin_summary.sql" -Content $uspPartnersAdminSummary
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_create.sql" -Content $uspPartnersCreate
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_update.sql" -Content $uspPartnersUpdate
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_change_status.sql" -Content $uspPartnersChangeStatus
Write-Utf8File -Path "StoredProcedures\Partners\usp_partners_add_note.sql" -Content $uspPartnersAddNote

# ==========================
# 3) SCRIPT DE SINCRONIZAÇÃO DO BANCO LOCAL / EXISTENTE
# ==========================

$syncSql = @'
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* =========================================================
       A) ALINHAR STATUS E LEVEL DA TABELA partners
       ========================================================= */

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_partners_status'
          AND parent_object_id = OBJECT_ID('dbo.partners')
    )
    BEGIN
        ALTER TABLE dbo.partners DROP CONSTRAINT CK_partners_status;
    END

    IF EXISTS (
        SELECT 1
        FROM sys.check_constraints
        WHERE name = 'CK_partners_level'
          AND parent_object_id = OBJECT_ID('dbo.partners')
    )
    BEGIN
        ALTER TABLE dbo.partners DROP CONSTRAINT CK_partners_level;
    END

    UPDATE dbo.partners
       SET status = 'pending_review'
     WHERE status = 'pending';

    UPDATE dbo.partners
       SET level = 'silver'
     WHERE level = 'prata';

    UPDATE dbo.partners
       SET level = 'gold'
     WHERE level = 'ouro';

    UPDATE dbo.partners
       SET level = 'diamond'
     WHERE level = 'diamante';

    ALTER TABLE dbo.partners
        ADD CONSTRAINT CK_partners_status
        CHECK ([status] IN (
            'pending_review',
            'under_review',
            'approved',
            'active',
            'inactive',
            'rejected',
            'suspended',
            'blocked'
        ));

    ALTER TABLE dbo.partners
        ADD CONSTRAINT CK_partners_level
        CHECK ([level] IS NULL OR [level] IN (
            'bronze',
            'silver',
            'gold',
            'diamond',
            'platinum'
        ));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
'@

Write-Utf8File -Path "Scripts\Partners\999_sync_local_partner_adjustments.sql" -Content $syncSql

Write-Host ""
Write-Host "Sincronização de arquivos concluída."
Write-Host "Próximos passos sugeridos:"
Write-Host "1) revisar git diff"
Write-Host "2) abrir a solution sqlproj"
Write-Host "3) confirmar se os arquivos entram no build"
Write-Host "4) executar o script Scripts\Partners\999_sync_local_partner_adjustments.sql no banco local/homolog"