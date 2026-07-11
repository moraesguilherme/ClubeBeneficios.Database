CREATE TABLE [dbo].[benefit_metrics_snapshot](
	[benefit_id] [uniqueidentifier] NOT NULL,
	[requests_count] [int] NOT NULL,
	[approved_requests_count] [int] NOT NULL,
	[usages_count] [int] NOT NULL,
	[conversion_rate] [decimal](9, 2) NULL,
	[refreshed_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_metrics_snapshot] PRIMARY KEY CLUSTERED 
(
	[benefit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_metrics_snapshot] ADD  CONSTRAINT [DF_benefit_metrics_snapshot_requests_count]  DEFAULT ((0)) FOR [requests_count]
GO
ALTER TABLE [dbo].[benefit_metrics_snapshot] ADD  CONSTRAINT [DF_benefit_metrics_snapshot_approved_requests_count]  DEFAULT ((0)) FOR [approved_requests_count]
GO
ALTER TABLE [dbo].[benefit_metrics_snapshot] ADD  CONSTRAINT [DF_benefit_metrics_snapshot_usages_count]  DEFAULT ((0)) FOR [usages_count]
GO
ALTER TABLE [dbo].[benefit_metrics_snapshot]  WITH CHECK ADD  CONSTRAINT [FK_benefit_metrics_snapshot_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[benefit_metrics_snapshot] CHECK CONSTRAINT [FK_benefit_metrics_snapshot_benefits]
GO

