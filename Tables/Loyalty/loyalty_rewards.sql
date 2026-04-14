CREATE TABLE [dbo].[loyalty_rewards](
	[id] [uniqueidentifier] NOT NULL,
	[title] [varchar](150) NOT NULL,
	[description] [varchar](1500) NULL,
	[points_cost] [int] NOT NULL,
	[availability_summary] [varchar](300) NULL,
	[operational_rule_summary] [varchar](1000) NULL,
	[eligible_level_code] [varchar](30) NULL,
	[status] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_loyalty_rewards] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rewards_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [FK_loyalty_rewards_users_created_by]
GO

ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rewards_users_updated_by] FOREIGN KEY([updated_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [FK_loyalty_rewards_users_updated_by]
GO

ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_eligible_level_code] CHECK  (([eligible_level_code] IS NULL OR ([eligible_level_code]='platinum' OR [eligible_level_code]='diamond' OR [eligible_level_code]='gold' OR [eligible_level_code]='silver' OR [eligible_level_code]='bronze')))
GO

ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_eligible_level_code]
GO

ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_points_cost] CHECK  (([points_cost]>(0)))
GO

ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_points_cost]
GO

ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='draft'))
GO

ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_status]
GO


