CREATE TABLE [dbo].[loyalty_campaigns](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](150) NOT NULL,
	[description] [varchar](1500) NULL,
	[campaign_type] [varchar](50) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[starts_at] [datetime2](7) NOT NULL,
	[ends_at] [datetime2](7) NULL,
	[audience_type] [varchar](50) NULL,
	[stacking_mode] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_loyalty_campaigns] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[loyalty_campaigns]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_campaigns_audience_type] CHECK  (([audience_type] IS NULL OR ([audience_type]='custom' OR [audience_type]='all_clients' OR [audience_type]='partner_customers' OR [audience_type]='clients')))
GO

ALTER TABLE [dbo].[loyalty_campaigns] CHECK CONSTRAINT [CK_loyalty_campaigns_audience_type]
GO

ALTER TABLE [dbo].[loyalty_campaigns]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_campaigns_campaign_type] CHECK  (([campaign_type]='custom' OR [campaign_type]='signup' OR [campaign_type]='referral' OR [campaign_type]='anniversary' OR [campaign_type]='seasonal' OR [campaign_type]='fixed_bonus' OR [campaign_type]='multiplier'))
GO

ALTER TABLE [dbo].[loyalty_campaigns] CHECK CONSTRAINT [CK_loyalty_campaigns_campaign_type]
GO

ALTER TABLE [dbo].[loyalty_campaigns]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_campaigns_stacking_mode] CHECK  (([stacking_mode]='highest_only' OR [stacking_mode]='stackable' OR [stacking_mode]='exclusive'))
GO

ALTER TABLE [dbo].[loyalty_campaigns] CHECK CONSTRAINT [CK_loyalty_campaigns_stacking_mode]
GO

ALTER TABLE [dbo].[loyalty_campaigns]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_campaigns_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='scheduled' OR [status]='draft'))
GO

ALTER TABLE [dbo].[loyalty_campaigns] CHECK CONSTRAINT [CK_loyalty_campaigns_status]
GO


