CREATE TABLE [dbo].[loyalty_score_snapshots](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[score_value] [int] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[trend_code] [varchar](30) NOT NULL,
	[trend_reason] [varchar](1000) NULL,
	[average_ticket_amount] [decimal](18, 2) NULL,
	[available_points] [int] NOT NULL,
	[pending_points] [int] NOT NULL,
	[upgrade_distance] [int] NULL,
	[downgrade_risk_flag] [bit] NOT NULL,
	[low_redemption_flag] [bit] NOT NULL,
	[calculated_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_loyalty_score_snapshots] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_score_snapshots_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [FK_loyalty_score_snapshots_clients]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_available_points] CHECK  (([available_points]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_available_points]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_level_code] CHECK  (([level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_level_code]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_pending_points] CHECK  (([pending_points]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_pending_points]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_score_value] CHECK  (([score_value]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_score_value]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_trend_code] CHECK  (([trend_code]='downgrade' OR [trend_code]='stable' OR [trend_code]='upgrade'))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_trend_code]
GO
ALTER TABLE [dbo].[loyalty_score_snapshots]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_score_snapshots_upgrade_distance] CHECK  (([upgrade_distance] IS NULL OR [upgrade_distance]>=(0)))
GO
ALTER TABLE [dbo].[loyalty_score_snapshots] CHECK CONSTRAINT [CK_loyalty_score_snapshots_upgrade_distance]
GO

