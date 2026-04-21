CREATE TABLE [dbo].[loyalty_reward_benefits](
	[id] [uniqueidentifier] NOT NULL,
	[reward_id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[link_type] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_loyalty_reward_benefits] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_reward_benefits]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_reward_benefits_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[loyalty_reward_benefits] CHECK CONSTRAINT [FK_loyalty_reward_benefits_benefits]
GO
ALTER TABLE [dbo].[loyalty_reward_benefits]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_reward_benefits_rewards] FOREIGN KEY([reward_id])
REFERENCES [dbo].[loyalty_rewards] ([id])
GO
ALTER TABLE [dbo].[loyalty_reward_benefits] CHECK CONSTRAINT [FK_loyalty_reward_benefits_rewards]
GO
ALTER TABLE [dbo].[loyalty_reward_benefits]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_reward_benefits_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_reward_benefits] CHECK CONSTRAINT [FK_loyalty_reward_benefits_users_created_by]
GO
ALTER TABLE [dbo].[loyalty_reward_benefits]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_reward_benefits_link_type] CHECK  (([link_type]='reference_only' OR [link_type]='unlock_benefit' OR [link_type]='redeemable_benefit'))
GO
ALTER TABLE [dbo].[loyalty_reward_benefits] CHECK CONSTRAINT [CK_loyalty_reward_benefits_link_type]
GO

