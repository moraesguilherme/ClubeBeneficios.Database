CREATE TABLE [dbo].[customer_loyalty_metric_snapshots](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[trend_code] [varchar](30) NOT NULL,
	[trend_reason] [varchar](1000) NULL,
	[average_ticket_amount] [decimal](18, 2) NULL,
	[available_points] [int] NOT NULL,
	[pending_points] [int] NOT NULL,
	[upgrade_distance_amount] [decimal](18, 2) NULL,
	[downgrade_risk_flag] [bit] NOT NULL,
	[low_redemption_flag] [bit] NOT NULL,
	[calculated_at] [datetime2](7) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customer_loyalty_metric_snapshots]  WITH CHECK ADD  CONSTRAINT [FK_metric_snapshots_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[customer_loyalty_metric_snapshots] CHECK CONSTRAINT [FK_metric_snapshots_clients]
GO

