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
