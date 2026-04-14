CREATE TABLE [dbo].[customer_loyalty_score_history](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[score_value] [decimal](18, 4) NOT NULL,
	[points_last_12m] [int] NOT NULL,
	[monthly_usage_avg] [decimal](18, 4) NOT NULL,
	[monthly_ticket_avg] [decimal](18, 2) NOT NULL,
	[downgrade_risk_flag] [bit] NOT NULL,
	[low_redemption_flag] [bit] NOT NULL,
	[calculated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_customer_loyalty_score_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] ADD  CONSTRAINT [DF_customer_loyalty_score_history_points_last_12m]  DEFAULT ((0)) FOR [points_last_12m]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] ADD  CONSTRAINT [DF_customer_loyalty_score_history_monthly_usage_avg]  DEFAULT ((0)) FOR [monthly_usage_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] ADD  CONSTRAINT [DF_customer_loyalty_score_history_monthly_ticket_avg]  DEFAULT ((0)) FOR [monthly_ticket_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] ADD  CONSTRAINT [DF_customer_loyalty_score_history_downgrade_risk_flag]  DEFAULT ((0)) FOR [downgrade_risk_flag]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] ADD  CONSTRAINT [DF_customer_loyalty_score_history_low_redemption_flag]  DEFAULT ((0)) FOR [low_redemption_flag]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_score_history_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [FK_customer_loyalty_score_history_clients]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_score_history_level_code] CHECK  (([level_code]='platinum' OR [level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [CK_customer_loyalty_score_history_level_code]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_score_history_monthly_ticket_avg] CHECK  (([monthly_ticket_avg]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [CK_customer_loyalty_score_history_monthly_ticket_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_score_history_monthly_usage_avg] CHECK  (([monthly_usage_avg]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [CK_customer_loyalty_score_history_monthly_usage_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_score_history_points_last_12m] CHECK  (([points_last_12m]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [CK_customer_loyalty_score_history_points_last_12m]
GO

ALTER TABLE [dbo].[customer_loyalty_score_history]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_score_history_score_value] CHECK  (([score_value]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_score_history] CHECK CONSTRAINT [CK_customer_loyalty_score_history_score_value]
GO


