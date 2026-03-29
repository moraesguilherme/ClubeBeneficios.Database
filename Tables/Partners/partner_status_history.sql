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