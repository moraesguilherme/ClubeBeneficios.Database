CREATE TABLE [dbo].[benefit_reviews](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[review_status] [varchar](30) NOT NULL,
	[review_point] [varchar](200) NULL,
	[review_recommendation] [varchar](1500) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NOT NULL,
	[reviewed_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_reviews] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefit_reviews]  WITH CHECK ADD  CONSTRAINT [FK_benefit_reviews_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO

ALTER TABLE [dbo].[benefit_reviews] CHECK CONSTRAINT [FK_benefit_reviews_benefits]
GO

ALTER TABLE [dbo].[benefit_reviews]  WITH CHECK ADD  CONSTRAINT [FK_benefit_reviews_users] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_reviews] CHECK CONSTRAINT [FK_benefit_reviews_users]
GO

ALTER TABLE [dbo].[benefit_reviews]  WITH CHECK ADD  CONSTRAINT [CK_benefit_reviews_review_status] CHECK  (([review_status]='rejected' OR [review_status]='approved' OR [review_status]='changes_requested' OR [review_status]='pending'))
GO

ALTER TABLE [dbo].[benefit_reviews] CHECK CONSTRAINT [CK_benefit_reviews_review_status]
GO


