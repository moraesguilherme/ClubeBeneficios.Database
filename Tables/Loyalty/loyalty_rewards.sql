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
	[redemption_mode] [varchar](30) NULL,
	[minimum_notice_hours] [int] NULL,
	[cumulative_mode] [varchar](30) NULL,
	[usage_window_type] [varchar](30) NULL,
	[usage_window_value] [int] NULL,
	[availability_type] [varchar](30) NULL,
	[season_type] [varchar](30) NULL,
	[is_transferable] [bit] NOT NULL,
 CONSTRAINT [PK_loyalty_rewards] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_rewards] ADD  CONSTRAINT [DF_loyalty_rewards_is_transferable]  DEFAULT ((0)) FOR [is_transferable]
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
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_availability_type] CHECK  (([availability_type] IS NULL OR ([availability_type]='seasonal' OR [availability_type]='limited' OR [availability_type]='general')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_availability_type]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_cumulative_mode] CHECK  (([cumulative_mode] IS NULL OR ([cumulative_mode]='cumulative' OR [cumulative_mode]='non_cumulative')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_cumulative_mode]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_eligible_level_code] CHECK  (([eligible_level_code] IS NULL OR ([eligible_level_code]='diamond' OR [eligible_level_code]='gold' OR [eligible_level_code]='silver' OR [eligible_level_code]='bronze')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_eligible_level_code]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_minimum_notice_hours] CHECK  (([minimum_notice_hours] IS NULL OR [minimum_notice_hours]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_minimum_notice_hours]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_points_cost] CHECK  (([points_cost]>(0)))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_points_cost]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_redemption_mode] CHECK  (([redemption_mode] IS NULL OR ([redemption_mode]='manual_review' OR [redemption_mode]='automatic' OR [redemption_mode]='approval_required')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_redemption_mode]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_season_type] CHECK  (([season_type] IS NULL OR ([season_type]='holiday' OR [season_type]='high_season' OR [season_type]='low_season' OR [season_type]='all')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_season_type]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='scheduled' OR [status]='draft'))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_status]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_usage_window_type] CHECK  (([usage_window_type] IS NULL OR ([usage_window_type]='year' OR [usage_window_type]='semester' OR [usage_window_type]='quarter' OR [usage_window_type]='month' OR [usage_window_type]='week' OR [usage_window_type]='day')))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_usage_window_type]
GO
ALTER TABLE [dbo].[loyalty_rewards]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rewards_usage_window_value] CHECK  (([usage_window_value] IS NULL OR [usage_window_value]>(0)))
GO
ALTER TABLE [dbo].[loyalty_rewards] CHECK CONSTRAINT [CK_loyalty_rewards_usage_window_value]
GO

