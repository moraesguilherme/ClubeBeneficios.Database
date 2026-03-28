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
