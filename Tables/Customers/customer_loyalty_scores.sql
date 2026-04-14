CREATE TABLE [dbo].[customer_loyalty_scores](
	[client_id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[score_value] [decimal](18, 4) NOT NULL,
	[points_last_12m] [int] NOT NULL,
	[monthly_usage_avg] [decimal](18, 4) NOT NULL,
	[monthly_ticket_avg] [decimal](18, 2) NOT NULL,
	[upgrade_distance] [int] NULL,
	[downgrade_risk_flag] [bit] NOT NULL,
	[low_redemption_flag] [bit] NOT NULL,
	[calculated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_customer_loyalty_scores] PRIMARY KEY CLUSTERED 
(
	[client_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[customer_loyalty_scores] ADD  CONSTRAINT [DF_customer_loyalty_scores_points_last_12m]  DEFAULT ((0)) FOR [points_last_12m]
GO

ALTER TABLE [dbo].[customer_loyalty_scores] ADD  CONSTRAINT [DF_customer_loyalty_scores_monthly_usage_avg]  DEFAULT ((0)) FOR [monthly_usage_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_scores] ADD  CONSTRAINT [DF_customer_loyalty_scores_monthly_ticket_avg]  DEFAULT ((0)) FOR [monthly_ticket_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_scores] ADD  CONSTRAINT [DF_customer_loyalty_scores_downgrade_risk_flag]  DEFAULT ((0)) FOR [downgrade_risk_flag]
GO

ALTER TABLE [dbo].[customer_loyalty_scores] ADD  CONSTRAINT [DF_customer_loyalty_scores_low_redemption_flag]  DEFAULT ((0)) FOR [low_redemption_flag]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [FK_customer_loyalty_scores_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [FK_customer_loyalty_scores_clients]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_level_code] CHECK  (([level_code]='platinum' OR [level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_level_code]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_monthly_ticket_avg] CHECK  (([monthly_ticket_avg]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_monthly_ticket_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_monthly_usage_avg] CHECK  (([monthly_usage_avg]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_monthly_usage_avg]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_points_last_12m] CHECK  (([points_last_12m]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_points_last_12m]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_score_value] CHECK  (([score_value]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_score_value]
GO

ALTER TABLE [dbo].[customer_loyalty_scores]  WITH CHECK ADD  CONSTRAINT [CK_customer_loyalty_scores_upgrade_distance] CHECK  (([upgrade_distance] IS NULL OR [upgrade_distance]>=(0)))
GO

ALTER TABLE [dbo].[customer_loyalty_scores] CHECK CONSTRAINT [CK_customer_loyalty_scores_upgrade_distance]
GO


