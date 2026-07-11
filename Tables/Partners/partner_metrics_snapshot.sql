CREATE TABLE [dbo].[partner_metrics_snapshot](
	[partner_id] [uniqueidentifier] NOT NULL,
	[benefits_count] [int] NOT NULL,
	[converted_clients_count] [int] NOT NULL,
	[campaigns_count] [int] NOT NULL,
	[raffles_count] [int] NOT NULL,
	[performance_score] [decimal](5, 2) NULL,
	[refreshed_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[partner_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_metrics_snapshot] ADD  CONSTRAINT [DF_partner_metrics_benefits]  DEFAULT ((0)) FOR [benefits_count]
GO
ALTER TABLE [dbo].[partner_metrics_snapshot] ADD  CONSTRAINT [DF_partner_metrics_converted]  DEFAULT ((0)) FOR [converted_clients_count]
GO
ALTER TABLE [dbo].[partner_metrics_snapshot] ADD  CONSTRAINT [DF_partner_metrics_campaigns]  DEFAULT ((0)) FOR [campaigns_count]
GO
ALTER TABLE [dbo].[partner_metrics_snapshot] ADD  CONSTRAINT [DF_partner_metrics_raffles]  DEFAULT ((0)) FOR [raffles_count]
GO
ALTER TABLE [dbo].[partner_metrics_snapshot]  WITH CHECK ADD  CONSTRAINT [FK_partner_metrics_snapshot_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_metrics_snapshot] CHECK CONSTRAINT [FK_partner_metrics_snapshot_partners]
GO

