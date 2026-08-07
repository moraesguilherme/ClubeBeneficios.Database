CREATE TABLE [dbo].[loyalty_redemptions](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[reward_id] [uniqueidentifier] NOT NULL,
	[redemption_code] [varchar](50) NULL,
	[requested_points_cost] [int] NOT NULL,
	[approved_points_cost] [int] NULL,
	[status] [varchar](30) NOT NULL,
	[request_channel] [varchar](30) NULL,
	[requested_at] [datetime2](7) NOT NULL,
	[approved_at] [datetime2](7) NULL,
	[rejected_at] [datetime2](7) NULL,
	[canceled_at] [datetime2](7) NULL,
	[used_at] [datetime2](7) NULL,
	[completed_at] [datetime2](7) NULL,
	[expires_at] [datetime2](7) NULL,
	[notes] [varchar](1500) NULL,
	[internal_notes] [varchar](1500) NULL,
	[requested_by_user_id] [uniqueidentifier] NULL,
	[decided_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[scheduled_for] [datetime2](7) NULL,
 CONSTRAINT [PK_loyalty_redemptions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_redemptions_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [FK_loyalty_redemptions_clients]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_redemptions_rewards] FOREIGN KEY([reward_id])
REFERENCES [dbo].[loyalty_rewards] ([id])
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [FK_loyalty_redemptions_rewards]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_redemptions_users_decided_by] FOREIGN KEY([decided_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [FK_loyalty_redemptions_users_decided_by]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_redemptions_users_requested_by] FOREIGN KEY([requested_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [FK_loyalty_redemptions_users_requested_by]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_redemptions_approved_points_cost] CHECK  (([approved_points_cost] IS NULL OR [approved_points_cost]>(0)))
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [CK_loyalty_redemptions_approved_points_cost]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_redemptions_request_channel] CHECK  (([request_channel] IS NULL OR ([request_channel]='internal' OR [request_channel]='system' OR [request_channel]='client_portal' OR [request_channel]='admin')))
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [CK_loyalty_redemptions_request_channel]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_redemptions_requested_points_cost] CHECK  (([requested_points_cost]>(0)))
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [CK_loyalty_redemptions_requested_points_cost]
GO
ALTER TABLE [dbo].[loyalty_redemptions]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_redemptions_status] CHECK  (([status]='expired' OR [status]='completed' OR [status]='used' OR [status]='canceled' OR [status]='rejected' OR [status]='approved' OR [status]='under_review' OR [status]='requested'))
GO
ALTER TABLE [dbo].[loyalty_redemptions] CHECK CONSTRAINT [CK_loyalty_redemptions_status]
GO

