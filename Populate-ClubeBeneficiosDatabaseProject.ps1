param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $dir = Split-Path -Parent $Path
    Ensure-Directory -Path $dir
    Set-Content -Path $Path -Value $Content -Encoding UTF8
    Write-Host "OK  $Path" -ForegroundColor Green
}

# =========================================================
# Estrutura
# =========================================================
$folders = @(
    "$ProjectPath\Publish",
    "$ProjectPath\Security",
    "$ProjectPath\Tables\Auth",
    "$ProjectPath\Tables\Partners",
    "$ProjectPath\Views\Partners",
    "$ProjectPath\StoredProcedures\Partners",
    "$ProjectPath\Seeds",
    "$ProjectPath\Scripts"
)

foreach ($folder in $folders) {
    Ensure-Directory -Path $folder
}

# =========================================================
# .sqlproj
# =========================================================
$sqlproj = @'
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Name>ClubeBeneficios.Database</Name>
    <DSP>Microsoft.Data.Tools.Schema.Sql.SqlAzureV12DatabaseSchemaProvider</DSP>
    <ModelCollation>1033, CI</ModelCollation>
    <ProjectVersion>4.1</ProjectVersion>
    <SchemaVersion>2.0</SchemaVersion>
    <OutputType>Database</OutputType>
    <RootPath>.</RootPath>
    <RootNamespace>ClubeBeneficios.Database</RootNamespace>
    <AssemblyName>ClubeBeneficios.Database</AssemblyName>
    <DefaultFileStructure>BySchemaAndType</DefaultFileStructure>
    <DeployToDatabase>True</DeployToDatabase>
    <TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>
    <TargetLanguage>CS</TargetLanguage>
    <SqlServerVerification>False</SqlServerVerification>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseSet>True</TargetDatabaseSet>
    <TargetDatabaseName>ClubeBeneficiosDb</TargetDatabaseName>
  </PropertyGroup>

  <ItemGroup>
    <Folder Include="Publish" />
    <Folder Include="Security" />
    <Folder Include="Tables" />
    <Folder Include="Tables\Auth" />
    <Folder Include="Tables\Partners" />
    <Folder Include="Views" />
    <Folder Include="Views\Partners" />
    <Folder Include="StoredProcedures" />
    <Folder Include="StoredProcedures\Partners" />
    <Folder Include="Seeds" />
    <Folder Include="Scripts" />
  </ItemGroup>

  <ItemGroup>
    <Build Include="Tables\Auth\users.sql" />
    <Build Include="Tables\Auth\roles.sql" />
    <Build Include="Tables\Auth\user_roles.sql" />
    <Build Include="Tables\Auth\password_reset_tokens.sql" />
    <Build Include="Tables\Auth\sessions.sql" />
    <Build Include="Tables\Auth\refresh_tokens.sql" />
    <Build Include="Tables\Auth\access_logs.sql" />

    <Build Include="Tables\Partners\partners.sql" />
    <Build Include="Tables\Partners\partner_contacts.sql" />
    <Build Include="Tables\Partners\partner_notes.sql" />
    <Build Include="Tables\Partners\partner_status_history.sql" />
    <Build Include="Tables\Partners\partner_metrics_snapshot.sql" />
    <Build Include="Tables\Partners\partner_access_codes.sql" />
    <Build Include="Tables\Partners\partner_customers.sql" />
    <Build Include="Tables\Partners\access_code_usages.sql" />

    <Build Include="Views\Partners\vw_partners_admin_list.sql" />
    <Build Include="Views\Partners\vw_partner_pending_details.sql" />

    <Build Include="StoredProcedures\Partners\usp_partners_create.sql" />
    <Build Include="StoredProcedures\Partners\usp_partners_update.sql" />
    <Build Include="StoredProcedures\Partners\usp_partners_change_status.sql" />
    <Build Include="StoredProcedures\Partners\usp_partners_add_note.sql" />
    <Build Include="StoredProcedures\Partners\usp_partner_metrics_upsert_snapshot.sql" />
  </ItemGroup>

  <ItemGroup>
    <PostDeploy Include="Scripts\PostDeployment.sql" />
    <PreDeploy Include="Scripts\PreDeployment.sql" />
  </ItemGroup>

  <Import Project="$(SQLDBExtensionsRefPath)\Microsoft.Data.Tools.Schema.SqlTasks.targets" Condition="'$(SQLDBExtensionsRefPath)' != ''" />
  <Import Project="$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v17.0\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets" Condition="Exists('$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v17.0\SSDT\Microsoft.Data.Tools.Schema.SqlTasks.targets')" />
</Project>
'@

Write-Utf8File "$ProjectPath\ClubeBeneficios.Database.sqlproj" $sqlproj

# =========================================================
# Scripts
# =========================================================
$preDeployment = @'
PRINT 'Iniciando pre-deployment do banco ClubeBeneficiosDb...';
GO
'@

$postDeployment = @'
:r ..\Seeds\001_roles_seed.sql
GO
'@

Write-Utf8File "$ProjectPath\Scripts\PreDeployment.sql" $preDeployment
Write-Utf8File "$ProjectPath\Scripts\PostDeployment.sql" $postDeployment

# =========================================================
# Seeds
# =========================================================
$seedRoles = @'
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'admin')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'admin', 'Administrador da plataforma', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'partner')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'partner', 'Usuário parceiro', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'client')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'client', 'Cliente Matilha', SYSUTCDATETIME());
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE name = 'partner_customer')
BEGIN
    INSERT INTO dbo.roles (id, name, description, created_at)
    VALUES (NEWID(), 'partner_customer', 'Cliente do parceiro', SYSUTCDATETIME());
END
GO
'@

Write-Utf8File "$ProjectPath\Seeds\001_roles_seed.sql" $seedRoles
Write-Utf8File "$ProjectPath\Seeds\README.md" "# Seeds`r`nScripts de carga inicial e apoio ao ambiente."
Write-Utf8File "$ProjectPath\Publish\README.md" "# Publish Profiles`r`nArquivos de publicação do banco."

# =========================================================
# Tables/Auth
# =========================================================
$rolesSql = @'
CREATE TABLE dbo.roles
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    name            VARCHAR(50)        NOT NULL,
    description     VARCHAR(200)       NULL,
    created_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_roles PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_roles_name UNIQUE NONCLUSTERED (name ASC)
);
GO
'@

$userSql = @'
CREATE TABLE dbo.users
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NULL,
    name                VARCHAR(150)       NOT NULL,
    email               VARCHAR(150)       NOT NULL,
    password_hash       VARCHAR(255)       NOT NULL,
    phone               VARCHAR(30)        NULL,
    status              VARCHAR(30)        NOT NULL,
    user_type           VARCHAR(30)        NOT NULL,
    email_confirmed     BIT                NOT NULL CONSTRAINT DF_users_email_confirmed DEFAULT ((0)),
    last_login_at       DATETIME2(7)       NULL,
    created_at          DATETIME2(7)       NOT NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_users PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_users_email UNIQUE NONCLUSTERED (email ASC),
    CONSTRAINT FK_users_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT CK_users_status CHECK ([status] IN ('pending', 'blocked', 'inactive', 'active')),
    CONSTRAINT CK_users_user_type CHECK ([user_type] IN ('admin', 'partner', 'client', 'partner_customer'))
);
GO

CREATE INDEX IX_users_partner_id
    ON dbo.users(partner_id);
GO

CREATE INDEX IX_users_user_type_status
    ON dbo.users(user_type, status);
GO
'@

$userRolesSql = @'
CREATE TABLE dbo.user_roles
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    user_id         UNIQUEIDENTIFIER   NOT NULL,
    role_id         UNIQUEIDENTIFIER   NOT NULL,
    created_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_user_roles PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_user_roles_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_user_roles_roles FOREIGN KEY (role_id) REFERENCES dbo.roles(id)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_user_roles_user_role
    ON dbo.user_roles(user_id, role_id);
GO
'@

$passwordResetSql = @'
CREATE TABLE dbo.password_reset_tokens
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    user_id         UNIQUEIDENTIFIER   NOT NULL,
    token           VARCHAR(500)       NOT NULL,
    expires_at      DATETIME2(7)       NOT NULL,
    created_at      DATETIME2(7)       NOT NULL,
    used_at         DATETIME2(7)       NULL,

    CONSTRAINT PK_password_reset_tokens PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_password_reset_tokens_token UNIQUE NONCLUSTERED (token ASC),
    CONSTRAINT FK_password_reset_tokens_users FOREIGN KEY (user_id) REFERENCES dbo.users(id)
);
GO

CREATE INDEX IX_password_reset_tokens_user_id
    ON dbo.password_reset_tokens(user_id);
GO
'@

$sessionsSql = @'
CREATE TABLE dbo.sessions
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    access_token_jti        VARCHAR(100)       NOT NULL,
    ip_address              VARCHAR(100)       NULL,
    user_agent              VARCHAR(500)       NULL,
    created_at              DATETIME2(7)       NOT NULL,
    expires_at              DATETIME2(7)       NOT NULL,
    revoked_at              DATETIME2(7)       NULL,
    is_valid                BIT                NOT NULL CONSTRAINT DF_sessions_is_valid DEFAULT ((1)),

    CONSTRAINT PK_sessions PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_sessions_access_token_jti UNIQUE NONCLUSTERED (access_token_jti ASC),
    CONSTRAINT FK_sessions_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_sessions_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT CK_sessions_actor CHECK (
        (CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN partner_customer_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);
GO

CREATE INDEX IX_sessions_user_id
    ON dbo.sessions(user_id);
GO

CREATE INDEX IX_sessions_partner_customer_id
    ON dbo.sessions(partner_customer_id);
GO
'@

$refreshTokensSql = @'
CREATE TABLE dbo.refresh_tokens
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    session_id              UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    token                   VARCHAR(500)       NOT NULL,
    expires_at              DATETIME2(7)       NOT NULL,
    created_at              DATETIME2(7)       NOT NULL,
    revoked_at              DATETIME2(7)       NULL,
    replaced_by_token       VARCHAR(500)       NULL,
    created_by_ip           VARCHAR(100)       NULL,

    CONSTRAINT PK_refresh_tokens PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_refresh_tokens_token UNIQUE NONCLUSTERED (token ASC),
    CONSTRAINT FK_refresh_tokens_sessions FOREIGN KEY (session_id) REFERENCES dbo.sessions(id),
    CONSTRAINT FK_refresh_tokens_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_refresh_tokens_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT CK_refresh_tokens_actor CHECK (
        (CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN partner_customer_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);
GO

CREATE INDEX IX_refresh_tokens_session_id
    ON dbo.refresh_tokens(session_id);
GO

CREATE INDEX IX_refresh_tokens_user_id
    ON dbo.refresh_tokens(user_id);
GO

CREATE INDEX IX_refresh_tokens_partner_customer_id
    ON dbo.refresh_tokens(partner_customer_id);
GO
'@

$accessLogsSql = @'
CREATE TABLE dbo.access_logs
(
    id                      UNIQUEIDENTIFIER   NOT NULL,
    user_id                 UNIQUEIDENTIFIER   NULL,
    partner_customer_id     UNIQUEIDENTIFIER   NULL,
    partner_id              UNIQUEIDENTIFIER   NULL,
    session_id              UNIQUEIDENTIFIER   NULL,
    action                  VARCHAR(100)       NOT NULL,
    resource                VARCHAR(100)       NULL,
    ip_address              VARCHAR(100)       NULL,
    user_agent              VARCHAR(500)       NULL,
    success                 BIT                NOT NULL,
    details                 VARCHAR(1000)      NULL,
    created_at              DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_access_logs PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_access_logs_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_access_logs_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id),
    CONSTRAINT FK_access_logs_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_access_logs_sessions FOREIGN KEY (session_id) REFERENCES dbo.sessions(id)
);
GO

CREATE INDEX IX_access_logs_user_id
    ON dbo.access_logs(user_id, created_at DESC);
GO

CREATE INDEX IX_access_logs_partner_customer_id
    ON dbo.access_logs(partner_customer_id, created_at DESC);
GO

CREATE INDEX IX_access_logs_partner_id
    ON dbo.access_logs(partner_id, created_at DESC);
GO
'@

Write-Utf8File "$ProjectPath\Tables\Auth\roles.sql" $rolesSql
Write-Utf8File "$ProjectPath\Tables\Auth\users.sql" $userSql
Write-Utf8File "$ProjectPath\Tables\Auth\user_roles.sql" $userRolesSql
Write-Utf8File "$ProjectPath\Tables\Auth\password_reset_tokens.sql" $passwordResetSql
Write-Utf8File "$ProjectPath\Tables\Auth\sessions.sql" $sessionsSql
Write-Utf8File "$ProjectPath\Tables\Auth\refresh_tokens.sql" $refreshTokensSql
Write-Utf8File "$ProjectPath\Tables\Auth\access_logs.sql" $accessLogsSql

# =========================================================
# Tables/Partners
# =========================================================
$partnersSql = @'
CREATE TABLE dbo.partners
(
    id                          UNIQUEIDENTIFIER   NOT NULL,
    trade_name                  VARCHAR(150)       NOT NULL,
    legal_name                  VARCHAR(150)       NULL,
    document                    VARCHAR(30)        NULL,
    email                       VARCHAR(150)       NULL,
    phone                       VARCHAR(30)        NULL,
    status                      VARCHAR(30)        NOT NULL,
    logo_url                    VARCHAR(500)       NULL,

    segment                     VARCHAR(120)       NULL,
    category                    VARCHAR(120)       NULL,
    service_region              VARCHAR(180)       NULL,
    website                     VARCHAR(250)       NULL,
    instagram                   VARCHAR(150)       NULL,
    description                 VARCHAR(1200)      NULL,
    level                       VARCHAR(30)        NULL,

    indication_flow_enabled     BIT                NOT NULL CONSTRAINT DF_partners_indication_flow_enabled DEFAULT ((1)),
    access_code_flow_enabled    BIT                NOT NULL CONSTRAINT DF_partners_access_code_flow_enabled DEFAULT ((1)),
    origin_type                 VARCHAR(30)        NOT NULL CONSTRAINT DF_partners_origin_type DEFAULT ('admin_created'),

    created_by_user_id          UNIQUEIDENTIFIER   NULL,
    approved_by_user_id         UNIQUEIDENTIFIER   NULL,
    rejected_by_user_id         UNIQUEIDENTIFIER   NULL,

    approved_at                 DATETIME2(7)       NULL,
    rejected_at                 DATETIME2(7)       NULL,
    inactivated_at              DATETIME2(7)       NULL,

    created_at                  DATETIME2(7)       NOT NULL,
    updated_at                  DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partners PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT CK_partners_status CHECK ([status] IN ('pending', 'under_review', 'active', 'inactive', 'rejected', 'suspended', 'blocked')),
    CONSTRAINT CK_partners_level CHECK ([level] IS NULL OR [level] IN ('bronze', 'prata', 'ouro', 'diamante', 'platinum')),
    CONSTRAINT CK_partners_origin_type CHECK ([origin_type] IN ('admin_created', 'self_signup', 'migration', 'api'))
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_partners_document
    ON dbo.partners(document)
    WHERE document IS NOT NULL;
GO

CREATE INDEX IX_partners_status_category_level
    ON dbo.partners(status, category, level);
GO

CREATE INDEX IX_partners_trade_name
    ON dbo.partners(trade_name);
GO
'@

$partnerContactsSql = @'
CREATE TABLE dbo.partner_contacts
(
    id              UNIQUEIDENTIFIER   NOT NULL,
    partner_id      UNIQUEIDENTIFIER   NOT NULL,
    name            VARCHAR(180)       NOT NULL,
    role_name       VARCHAR(120)       NULL,
    email           VARCHAR(150)       NULL,
    phone           VARCHAR(30)        NULL,
    is_primary      BIT                NOT NULL CONSTRAINT DF_partner_contacts_is_primary DEFAULT ((0)),
    is_active       BIT                NOT NULL CONSTRAINT DF_partner_contacts_is_active DEFAULT ((1)),
    created_at      DATETIME2(7)       NOT NULL,
    updated_at      DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_contacts PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_contacts_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id)
);
GO

CREATE UNIQUE INDEX UX_partner_contacts_primary
    ON dbo.partner_contacts(partner_id)
    WHERE is_primary = 1;
GO

CREATE INDEX IX_partner_contacts_partner_id
    ON dbo.partner_contacts(partner_id, is_active, is_primary);
GO
'@

$partnerNotesSql = @'
CREATE TABLE dbo.partner_notes
(
    id                  BIGINT             NOT NULL IDENTITY(1,1),
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    note_type           VARCHAR(30)        NOT NULL CONSTRAINT DF_partner_notes_type DEFAULT ('general'),
    content             VARCHAR(MAX)       NOT NULL,
    created_by_user_id  UNIQUEIDENTIFIER   NULL,
    created_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_notes PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_notes_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_notes_users FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_partner_notes_type CHECK ([note_type] IN ('general', 'commercial', 'operational', 'approval'))
);
GO

CREATE INDEX IX_partner_notes_partner_created_at
    ON dbo.partner_notes(partner_id, created_at DESC);
GO
'@

$partnerStatusHistorySql = @'
CREATE TABLE dbo.partner_status_history
(
    id                  BIGINT             NOT NULL IDENTITY(1,1),
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    from_status         VARCHAR(30)        NULL,
    to_status           VARCHAR(30)        NOT NULL,
    reason              VARCHAR(800)       NULL,
    changed_by_user_id  UNIQUEIDENTIFIER   NULL,
    changed_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_status_history PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_status_history_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_status_history_users FOREIGN KEY (changed_by_user_id) REFERENCES dbo.users(id)
);
GO

CREATE INDEX IX_partner_status_history_partner_changed_at
    ON dbo.partner_status_history(partner_id, changed_at DESC);
GO
'@

$partnerMetricsSnapshotSql = @'
CREATE TABLE dbo.partner_metrics_snapshot
(
    partner_id                  UNIQUEIDENTIFIER   NOT NULL,
    benefits_count              INT                NOT NULL CONSTRAINT DF_partner_metrics_benefits DEFAULT ((0)),
    converted_clients_count     INT                NOT NULL CONSTRAINT DF_partner_metrics_converted DEFAULT ((0)),
    campaigns_count             INT                NOT NULL CONSTRAINT DF_partner_metrics_campaigns DEFAULT ((0)),
    raffles_count               INT                NOT NULL CONSTRAINT DF_partner_metrics_raffles DEFAULT ((0)),
    performance_score           DECIMAL(5,2)       NULL,
    refreshed_at                DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_metrics_snapshot PRIMARY KEY CLUSTERED (partner_id ASC),
    CONSTRAINT FK_partner_metrics_snapshot_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id)
);
GO
'@

$partnerAccessCodesSql = @'
CREATE TABLE dbo.partner_access_codes
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    created_by_user_id  UNIQUEIDENTIFIER   NOT NULL,
    code                VARCHAR(100)       NOT NULL,
    description         VARCHAR(300)       NULL,
    status              VARCHAR(30)        NOT NULL,
    expires_at          DATETIME2(7)       NULL,
    max_uses            INT                NULL,
    used_count          INT                NOT NULL CONSTRAINT DF_partner_access_codes_used_count DEFAULT ((0)),
    created_at          DATETIME2(7)       NOT NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_access_codes PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT UQ_partner_access_codes_code UNIQUE NONCLUSTERED (code ASC),
    CONSTRAINT FK_partner_access_codes_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_access_codes_users FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_partner_access_codes_status CHECK ([status] IN ('active', 'inactive', 'expired', 'blocked'))
);
GO

CREATE INDEX IX_partner_access_codes_partner_status
    ON dbo.partner_access_codes(partner_id, status);
GO
'@

$partnerCustomersSql = @'
CREATE TABLE dbo.partner_customers
(
    id                  UNIQUEIDENTIFIER   NOT NULL,
    partner_id          UNIQUEIDENTIFIER   NOT NULL,
    origin_code_id      UNIQUEIDENTIFIER   NULL,
    name                VARCHAR(150)       NULL,
    email               VARCHAR(150)       NULL,
    phone               VARCHAR(30)        NULL,
    status              VARCHAR(30)        NOT NULL,
    created_at          DATETIME2(7)       NOT NULL,
    last_access_at      DATETIME2(7)       NULL,
    updated_at          DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_partner_customers PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_partner_customers_partners FOREIGN KEY (partner_id) REFERENCES dbo.partners(id),
    CONSTRAINT FK_partner_customers_codes FOREIGN KEY (origin_code_id) REFERENCES dbo.partner_access_codes(id),
    CONSTRAINT CK_partner_customers_status CHECK ([status] IN ('active', 'inactive', 'blocked'))
);
GO

CREATE INDEX IX_partner_customers_partner_id
    ON dbo.partner_customers(partner_id);
GO

CREATE INDEX IX_partner_customers_origin_code_id
    ON dbo.partner_customers(origin_code_id);
GO
'@

$accessCodeUsagesSql = @'
CREATE TABLE dbo.access_code_usages
(
    id                          UNIQUEIDENTIFIER   NOT NULL,
    partner_access_code_id      UNIQUEIDENTIFIER   NOT NULL,
    partner_customer_id         UNIQUEIDENTIFIER   NULL,
    ip_address                  VARCHAR(100)       NULL,
    user_agent                  VARCHAR(500)       NULL,
    used_at                     DATETIME2(7)       NOT NULL,

    CONSTRAINT PK_access_code_usages PRIMARY KEY CLUSTERED (id ASC),
    CONSTRAINT FK_access_code_usages_codes FOREIGN KEY (partner_access_code_id) REFERENCES dbo.partner_access_codes(id),
    CONSTRAINT FK_access_code_usages_partner_customers FOREIGN KEY (partner_customer_id) REFERENCES dbo.partner_customers(id)
);
GO

CREATE INDEX IX_access_code_usages_code_id
    ON dbo.access_code_usages(partner_access_code_id, used_at DESC);
GO
'@

Write-Utf8File "$ProjectPath\Tables\Partners\partners.sql" $partnersSql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_contacts.sql" $partnerContactsSql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_notes.sql" $partnerNotesSql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_status_history.sql" $partnerStatusHistorySql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_metrics_snapshot.sql" $partnerMetricsSnapshotSql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_access_codes.sql" $partnerAccessCodesSql
Write-Utf8File "$ProjectPath\Tables\Partners\partner_customers.sql" $partnerCustomersSql
Write-Utf8File "$ProjectPath\Tables\Partners\access_code_usages.sql" $accessCodeUsagesSql

# =========================================================
# Security - arquivo auxiliar para FKs cruzadas
# =========================================================
$securityRoles = @'
/*
Arquivo reservado para futuras permissões, grants ou scripts de segurança.
No momento, os seeds de roles estão em Seeds/001_roles_seed.sql.
*/
'@

Write-Utf8File "$ProjectPath\Security\Roles.sql" $securityRoles

# =========================================================
# Arquivo de constraints cruzadas
# =========================================================
$crossObjectNote = @'
/*
Observação importante para SSDT / SQL Project:

As FKs cruzadas abaixo podem ser adicionadas em um arquivo complementar,
caso seu ambiente exija separar referências cíclicas:

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_created_by_user
    FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id);

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_approved_by_user
    FOREIGN KEY (approved_by_user_id) REFERENCES dbo.users(id);

ALTER TABLE dbo.partners
    ADD CONSTRAINT FK_partners_rejected_by_user
    FOREIGN KEY (rejected_by_user_id) REFERENCES dbo.users(id);

Em muitos cenários de Database Project, o SSDT resolve a ordem sozinho.
*/
'@

Write-Utf8File "$ProjectPath\Security\CrossReferences.md" $crossObjectNote

# =========================================================
# Views
# =========================================================
$vwPartnersAdminList = @'
CREATE VIEW dbo.vw_partners_admin_list
AS
SELECT
    p.id,
    p.trade_name,
    p.legal_name,
    p.document,
    p.email,
    p.phone,
    p.status,
    p.logo_url,
    p.segment,
    p.category,
    p.service_region,
    p.website,
    p.instagram,
    p.description,
    p.level,
    p.indication_flow_enabled,
    p.access_code_flow_enabled,
    p.origin_type,
    p.created_at,
    p.updated_at,
    p.approved_at,
    p.rejected_at,
    p.inactivated_at,
    p.created_by_user_id,
    p.approved_by_user_id,
    p.rejected_by_user_id,

    c.name AS responsible_name,
    c.role_name AS responsible_role,
    c.email AS responsible_email,
    c.phone AS responsible_phone,

    ISNULL(ms.benefits_count, 0) AS benefits_count,
    ISNULL(ms.converted_clients_count, 0) AS converted_clients_count,
    ISNULL(ms.campaigns_count, 0) AS campaigns_count,
    ISNULL(ms.raffles_count, 0) AS raffles_count,
    ms.performance_score,
    ms.refreshed_at AS metrics_refreshed_at
FROM dbo.partners p
LEFT JOIN dbo.partner_contacts c
    ON c.partner_id = p.id
   AND c.is_primary = 1
LEFT JOIN dbo.partner_metrics_snapshot ms
    ON ms.partner_id = p.id;
GO
'@

$vwPartnerPendingDetails = @'
CREATE VIEW dbo.vw_partner_pending_details
AS
SELECT
    p.id,
    p.trade_name,
    p.legal_name,
    p.document,
    p.email,
    p.phone,
    p.status,
    p.logo_url,
    p.segment,
    p.category,
    p.service_region,
    p.description,
    p.created_at,
    c.name AS responsible_name,
    c.role_name AS responsible_role,
    c.email AS responsible_email,
    c.phone AS responsible_phone,
    (
        SELECT TOP (1) n.content
        FROM dbo.partner_notes n
        WHERE n.partner_id = p.id
        ORDER BY n.created_at DESC
    ) AS latest_note
FROM dbo.partners p
LEFT JOIN dbo.partner_contacts c
    ON c.partner_id = p.id
   AND c.is_primary = 1
WHERE p.status IN ('pending', 'under_review');
GO
'@

Write-Utf8File "$ProjectPath\Views\Partners\vw_partners_admin_list.sql" $vwPartnersAdminList
Write-Utf8File "$ProjectPath\Views\Partners\vw_partner_pending_details.sql" $vwPartnerPendingDetails

# =========================================================
# Stored Procedures
# =========================================================
$uspPartnersCreate = @'
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
'@

$uspPartnersUpdate = @'
CREATE PROCEDURE dbo.usp_partners_update
    @PartnerId UNIQUEIDENTIFIER,
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

    @ResponsibleName VARCHAR(180) = NULL,
    @ResponsibleRole VARCHAR(120) = NULL,
    @ResponsibleEmail VARCHAR(150) = NULL,
    @ResponsiblePhone VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

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
               SET name = @ResponsibleName,
                   role_name = @ResponsibleRole,
                   email = @ResponsibleEmail,
                   phone = @ResponsiblePhone,
                   updated_at = SYSUTCDATETIME()
             WHERE partner_id = @PartnerId
               AND is_primary = 1;
        END
        ELSE IF @ResponsibleName IS NOT NULL
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

    COMMIT TRANSACTION;
END
GO
'@

$uspPartnersChangeStatus = @'
CREATE PROCEDURE dbo.usp_partners_change_status
    @PartnerId UNIQUEIDENTIFIER,
    @NewStatus VARCHAR(30),
    @Reason VARCHAR(800) = NULL,
    @ChangedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentStatus VARCHAR(30);

    SELECT @CurrentStatus = status
    FROM dbo.partners
    WHERE id = @PartnerId;

    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Parceiro não encontrado.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

        UPDATE dbo.partners
           SET status = @NewStatus,
               approved_at = CASE WHEN @NewStatus = 'active' THEN ISNULL(approved_at, SYSUTCDATETIME()) ELSE approved_at END,
               approved_by_user_id = CASE WHEN @NewStatus = 'active' THEN ISNULL(approved_by_user_id, @ChangedByUserId) ELSE approved_by_user_id END,
               rejected_at = CASE WHEN @NewStatus = 'rejected' THEN SYSUTCDATETIME() ELSE rejected_at END,
               rejected_by_user_id = CASE WHEN @NewStatus = 'rejected' THEN @ChangedByUserId ELSE rejected_by_user_id END,
               inactivated_at = CASE WHEN @NewStatus = 'inactive' THEN SYSUTCDATETIME() ELSE inactivated_at END,
               updated_at = SYSUTCDATETIME()
         WHERE id = @PartnerId;

        INSERT INTO dbo.partner_status_history
        (
            partner_id, from_status, to_status, reason, changed_by_user_id, changed_at
        )
        VALUES
        (
            @PartnerId, @CurrentStatus, @NewStatus, @Reason, @ChangedByUserId, SYSUTCDATETIME()
        );

    COMMIT TRANSACTION;
END
GO
'@

$uspPartnersAddNote = @'
CREATE PROCEDURE dbo.usp_partners_add_note
    @PartnerId UNIQUEIDENTIFIER,
    @NoteType VARCHAR(30),
    @Content VARCHAR(MAX),
    @CreatedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.partner_notes
    (
        partner_id, note_type, content, created_by_user_id, created_at
    )
    VALUES
    (
        @PartnerId, @NoteType, @Content, @CreatedByUserId, SYSUTCDATETIME()
    );
END
GO
'@

$uspPartnerMetricsUpsert = @'
CREATE PROCEDURE dbo.usp_partner_metrics_upsert_snapshot
    @PartnerId UNIQUEIDENTIFIER,
    @BenefitsCount INT = 0,
    @ConvertedClientsCount INT = 0,
    @CampaignsCount INT = 0,
    @RafflesCount INT = 0,
    @PerformanceScore DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.partner_metrics_snapshot AS target
    USING (
        SELECT
            @PartnerId AS partner_id,
            @BenefitsCount AS benefits_count,
            @ConvertedClientsCount AS converted_clients_count,
            @CampaignsCount AS campaigns_count,
            @RafflesCount AS raffles_count,
            @PerformanceScore AS performance_score
    ) AS source
    ON target.partner_id = source.partner_id
    WHEN MATCHED THEN
        UPDATE SET
            benefits_count = source.benefits_count,
            converted_clients_count = source.converted_clients_count,
            campaigns_count = source.campaigns_count,
            raffles_count = source.raffles_count,
            performance_score = source.performance_score,
            refreshed_at = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT
        (
            partner_id, benefits_count, converted_clients_count, campaigns_count, raffles_count, performance_score, refreshed_at
        )
        VALUES
        (
            source.partner_id, source.benefits_count, source.converted_clients_count, source.campaigns_count, source.raffles_count, source.performance_score, SYSUTCDATETIME()
        );
END
GO
'@

Write-Utf8File "$ProjectPath\StoredProcedures\Partners\usp_partners_create.sql" $uspPartnersCreate
Write-Utf8File "$ProjectPath\StoredProcedures\Partners\usp_partners_update.sql" $uspPartnersUpdate
Write-Utf8File "$ProjectPath\StoredProcedures\Partners\usp_partners_change_status.sql" $uspPartnersChangeStatus
Write-Utf8File "$ProjectPath\StoredProcedures\Partners\usp_partners_add_note.sql" $uspPartnersAddNote
Write-Utf8File "$ProjectPath\StoredProcedures\Partners\usp_partner_metrics_upsert_snapshot.sql" $uspPartnerMetricsUpsert

Write-Host ""
Write-Host "Projeto preenchido com sucesso em: $ProjectPath" -ForegroundColor Cyan
Write-Host "Agora cole ou adicione, se necessário, os ajustes finais de FKs cruzadas no seu Database Project." -ForegroundColor Yellow