CREATE TABLE [dbo].[customer_loyalty_balances](
	[client_id] [uniqueidentifier] NOT NULL,
	[available_points] [int] NOT NULL,
	[pending_points] [int] NOT NULL,
	[expired_points] [int] NOT NULL,
	[redeemed_points] [int] NOT NULL,
	[lifetime_earned_points] [int] NOT NULL,
	[last_movement_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_customer_loyalty_balances] PRIMARY KEY CLUSTERED 
(
	[client_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_loyalty_balances] ADD  CONSTRAINT [DF_customer_loyalty_balances_available_points]  DEFAULT ((0)) FOR [available_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances] ADD  CONSTRAINT [DF_customer_loyalty_balances_pending_points]  DEFAULT ((0)) FOR [pending_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances] ADD  CONSTRAINT [DF_customer_loyalty_balances_expired_points]  DEFAULT ((0)) FOR [expired_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances] ADD  CONSTRAINT [DF_customer_loyalty_balances_redeemed_points]  DEFAULT ((0)) FOR [redeemed_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances] ADD  CONSTRAINT [DF_customer_loyalty_balances_lifetime_earned_points]  DEFAULT ((0)) FOR [lifetime_earned_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_balances_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [FK_customer_loyalty_balances_clients]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_balances_available_points] CHECK  (([available_points]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [CK_customer_loyalty_balances_available_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_balances_expired_points] CHECK  (([expired_points]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [CK_customer_loyalty_balances_expired_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_balances_lifetime_earned_points] CHECK  (([lifetime_earned_points]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [CK_customer_loyalty_balances_lifetime_earned_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_balances_pending_points] CHECK  (([pending_points]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [CK_customer_loyalty_balances_pending_points]
GO

ALTER TABLE [dbo].[customer_loyalty_balances]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_balances_redeemed_points] CHECK  (([redeemed_points]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_balances] CHECK CONSTRAINT [CK_customer_loyalty_balances_redeemed_points]
GO


