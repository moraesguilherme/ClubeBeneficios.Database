SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_metrics_snapshot', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_metrics_snapshot
    (
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        requests_count INT NOT NULL CONSTRAINT DF_benefit_metrics_snapshot_requests_count DEFAULT ((0)),
        approved_requests_count INT NOT NULL CONSTRAINT DF_benefit_metrics_snapshot_approved_requests_count DEFAULT ((0)),
        usages_count INT NOT NULL CONSTRAINT DF_benefit_metrics_snapshot_usages_count DEFAULT ((0)),
        conversion_rate DECIMAL(9,2) NULL,
        refreshed_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_metrics_snapshot PRIMARY KEY CLUSTERED (benefit_id ASC),
        CONSTRAINT FK_benefit_metrics_snapshot_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id)
    );
END
GO