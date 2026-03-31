SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.benefit_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.benefit_reviews
    (
        id UNIQUEIDENTIFIER NOT NULL,
        benefit_id UNIQUEIDENTIFIER NOT NULL,
        review_status VARCHAR(30) NOT NULL,
        review_point VARCHAR(200) NULL,
        review_recommendation VARCHAR(1500) NULL,
        reviewed_by_user_id UNIQUEIDENTIFIER NOT NULL,
        reviewed_at DATETIME2(7) NOT NULL,
        created_at DATETIME2(7) NOT NULL,

        CONSTRAINT PK_benefit_reviews PRIMARY KEY CLUSTERED (id ASC),
        CONSTRAINT FK_benefit_reviews_benefits FOREIGN KEY (benefit_id) REFERENCES dbo.benefits(id),
        CONSTRAINT FK_benefit_reviews_users FOREIGN KEY (reviewed_by_user_id) REFERENCES dbo.users(id),
        CONSTRAINT CK_benefit_reviews_review_status CHECK (review_status IN ('pending', 'changes_requested', 'approved', 'rejected'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_benefit_reviews_benefit_reviewed_at' AND object_id = OBJECT_ID('dbo.benefit_reviews'))
    CREATE INDEX IX_benefit_reviews_benefit_reviewed_at ON dbo.benefit_reviews(benefit_id, reviewed_at DESC);
GO