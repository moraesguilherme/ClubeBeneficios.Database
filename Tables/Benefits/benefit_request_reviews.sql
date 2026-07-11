CREATE TABLE [dbo].[benefit_request_reviews](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[review_status] [varchar](30) NOT NULL,
	[review_point] [varchar](200) NULL,
	[review_recommendation] [varchar](1500) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NOT NULL,
	[reviewed_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_request_reviews] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_request_reviews] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[benefit_request_reviews] ADD  CONSTRAINT [DF_benefit_request_reviews_reviewed_at]  DEFAULT (sysutcdatetime()) FOR [reviewed_at]
GO
ALTER TABLE [dbo].[benefit_request_reviews] ADD  CONSTRAINT [DF_benefit_request_reviews_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[benefit_request_reviews]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_reviews_requests] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_request_reviews] CHECK CONSTRAINT [FK_benefit_request_reviews_requests]
GO
ALTER TABLE [dbo].[benefit_request_reviews]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_reviews_users] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[benefit_request_reviews] CHECK CONSTRAINT [FK_benefit_request_reviews_users]
GO
ALTER TABLE [dbo].[benefit_request_reviews]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_reviews_status] CHECK  (([review_status]='expired' OR [review_status]='cancelled' OR [review_status]='rejected' OR [review_status]='approved' OR [review_status]='under_review' OR [review_status]='pending_review'))
GO
ALTER TABLE [dbo].[benefit_request_reviews] CHECK CONSTRAINT [CK_benefit_request_reviews_status]
GO

