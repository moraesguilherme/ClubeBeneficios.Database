CREATE TABLE [dbo].[loyalty_level_benefits](
	[id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[title] [varchar](150) NOT NULL,
	[description] [varchar](1500) NULL,
	[display_order] [int] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[valid_from] [datetime2](7) NULL,
	[valid_to] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_loyalty_level_benefits] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_level_benefits]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_level_benefits_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_level_benefits] CHECK CONSTRAINT [FK_loyalty_level_benefits_users_created_by]
GO
ALTER TABLE [dbo].[loyalty_level_benefits]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_level_benefits_users_updated_by] FOREIGN KEY([updated_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_level_benefits] CHECK CONSTRAINT [FK_loyalty_level_benefits_users_updated_by]
GO
ALTER TABLE [dbo].[loyalty_level_benefits]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_level_benefits_display_order] CHECK  (([display_order]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_level_benefits] CHECK CONSTRAINT [CK_loyalty_level_benefits_display_order]
GO
ALTER TABLE [dbo].[loyalty_level_benefits]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_level_benefits_level_code] CHECK  (([level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO
ALTER TABLE [dbo].[loyalty_level_benefits] CHECK CONSTRAINT [CK_loyalty_level_benefits_level_code]
GO
ALTER TABLE [dbo].[loyalty_level_benefits]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_level_benefits_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='scheduled' OR [status]='draft'))
GO
ALTER TABLE [dbo].[loyalty_level_benefits] CHECK CONSTRAINT [CK_loyalty_level_benefits_status]
GO

