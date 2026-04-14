CREATE TABLE [dbo].[customer_loyalty_events](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[event_type] [varchar](50) NOT NULL,
	[movement_type] [varchar](30) NOT NULL,
	[source_type] [varchar](50) NOT NULL,
	[source_id] [varchar](100) NULL,
	[rule_id] [uniqueidentifier] NULL,
	[campaign_id] [uniqueidentifier] NULL,
	[reward_id] [uniqueidentifier] NULL,
	[adjustment_id] [uniqueidentifier] NULL,
	[points_delta] [int] NOT NULL,
	[monetary_amount] [decimal](18, 2) NULL,
	[payment_method] [varchar](50) NULL,
	[payment_reference] [varchar](150) NULL,
	[occurred_at] [datetime2](7) NOT NULL,
	[effective_at] [datetime2](7) NOT NULL,
	[expires_at] [datetime2](7) NULL,
	[is_expired] [bit] NOT NULL,
	[description] [varchar](1500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_customer_loyalty_events] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_loyalty_events] ADD  CONSTRAINT [DF_customer_loyalty_events_is_expired]  DEFAULT ((0)) FOR [is_expired]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_events_campaigns] FOREIGN KEY([campaign_id])
REFERENCES [dbo].[loyalty_campaigns] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [FK_customer_loyalty_events_campaigns]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_events_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [FK_customer_loyalty_events_clients]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_events_rules] FOREIGN KEY([rule_id])
REFERENCES [dbo].[loyalty_rules] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [FK_customer_loyalty_events_rules]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_events_users_created_by] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [FK_customer_loyalty_events_users_created_by]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_dates] CHECK  (([effective_at]>=[occurred_at]))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_dates]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_event_type] CHECK  (([event_type]='custom' OR [event_type]='etl_import' OR [event_type]='reward_reversal' OR [event_type]='reward_redemption' OR [event_type]='points_expired' OR [event_type]='manual_adjustment' OR [event_type]='pet_birthday_bonus' OR [event_type]='referral_bonus' OR [event_type]='signup_bonus' OR [event_type]='payment_confirmed' OR [event_type]='service_consumed'))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_event_type]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_expiration_consistency] CHECK  (([is_expired]=(0) OR [expires_at] IS NOT NULL))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_expiration_consistency]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_movement_type] CHECK  (([movement_type]='redemption_cancel' OR [movement_type]='redemption_commit' OR [movement_type]='redemption_reserve' OR [movement_type]='reversal' OR [movement_type]='adjustment' OR [movement_type]='expiration' OR [movement_type]='debit' OR [movement_type]='credit'))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_movement_type]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_payment_method] CHECK  (([payment_method] IS NULL OR ([payment_method]='other' OR [payment_method]='boleto' OR [payment_method]='bank_transfer' OR [payment_method]='debit_card' OR [payment_method]='credit_card' OR [payment_method]='cash' OR [payment_method]='pix')))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_payment_method]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_points_delta] CHECK  (([points_delta]<>(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_points_delta]
GO

ALTER TABLE [dbo].[customer_loyalty_events]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_events_source_type] CHECK  (([source_type]='custom' OR [source_type]='manual' OR [source_type]='redemption' OR [source_type]='adjustment' OR [source_type]='campaign' OR [source_type]='signup' OR [source_type]='referral' OR [source_type]='pet_birthday' OR [source_type]='benefit_usage' OR [source_type]='benefit_request' OR [source_type]='etl_payment_row' OR [source_type]='etl_import'))
GO

ALTER TABLE [dbo].[customer_loyalty_events] CHECK CONSTRAINT [CK_customer_loyalty_events_source_type]
GO


