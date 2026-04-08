CREATE TABLE [dbo].[benefit_usage_locks](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[actor_type] [varchar](30) NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[partner_customer_id] [uniqueidentifier] NULL,
	[window_start] [datetime2](7) NOT NULL,
	[window_end] [datetime2](7) NOT NULL,
	[allowed_uses] [int] NOT NULL,
	[used_count] [int] NOT NULL,
	[next_available_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_usage_locks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_locks_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [FK_benefit_usage_locks_benefits]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_locks_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [FK_benefit_usage_locks_partner_customers]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [FK_benefit_usage_locks_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [FK_benefit_usage_locks_users]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_locks_actor_type] CHECK  (([actor_type]='partner_customer' OR [actor_type]='client'))
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [CK_benefit_usage_locks_actor_type]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_locks_counts] CHECK  (([allowed_uses]>=(0) AND [used_count]>=(0) AND [used_count]<=[allowed_uses]))
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [CK_benefit_usage_locks_counts]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_locks_presence] CHECK  (([actor_type]='client' AND [user_id] IS NOT NULL AND [partner_customer_id] IS NULL OR [actor_type]='partner_customer' AND [partner_customer_id] IS NOT NULL AND [user_id] IS NULL))
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [CK_benefit_usage_locks_presence]
GO

ALTER TABLE [dbo].[benefit_usage_locks]  WITH CHECK ADD  CONSTRAINT [CK_benefit_usage_locks_window] CHECK  (([window_end]>=[window_start]))
GO

ALTER TABLE [dbo].[benefit_usage_locks] CHECK CONSTRAINT [CK_benefit_usage_locks_window]
GO


