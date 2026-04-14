CREATE TABLE [dbo].[loyalty_rules](
	[id] [uniqueidentifier] NOT NULL,
	[rule_set_id] [uniqueidentifier] NOT NULL,
	[name] [varchar](150) NOT NULL,
	[category] [varchar](50) NOT NULL,
	[description] [varchar](1500) NULL,
	[calculation_type] [varchar](50) NOT NULL,
	[stacking_mode] [varchar](30) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[priority] [int] NOT NULL,
	[valid_from] [datetime2](7) NULL,
	[valid_to] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_loyalty_rules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[loyalty_rules] ADD  CONSTRAINT [DF_loyalty_rules_priority]  DEFAULT ((0)) FOR [priority]
GO

ALTER TABLE [dbo].[loyalty_rules]  WITH CHECK ADD  CONSTRAINT [FK_loyalty_rules_rule_sets] FOREIGN KEY([rule_set_id])
REFERENCES [dbo].[loyalty_rule_sets] ([id])
GO

ALTER TABLE [dbo].[loyalty_rules] CHECK CONSTRAINT [FK_loyalty_rules_rule_sets]
GO

ALTER TABLE [dbo].[loyalty_rules]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rules_calculation_type] CHECK  (([calculation_type]='manual_only' OR [calculation_type]='formula' OR [calculation_type]='multiplier' OR [calculation_type]='fixed_points' OR [calculation_type]='per_currency'))
GO

ALTER TABLE [dbo].[loyalty_rules] CHECK CONSTRAINT [CK_loyalty_rules_calculation_type]
GO

ALTER TABLE [dbo].[loyalty_rules]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rules_category] CHECK  (([category]='campaign_bonus' OR [category]='eligibility' OR [category]='usage' OR [category]='redemption' OR [category]='level' OR [category]='scoring'))
GO

ALTER TABLE [dbo].[loyalty_rules] CHECK CONSTRAINT [CK_loyalty_rules_category]
GO

ALTER TABLE [dbo].[loyalty_rules]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rules_stacking_mode] CHECK  (([stacking_mode]='highest_only' OR [stacking_mode]='stackable' OR [stacking_mode]='exclusive'))
GO

ALTER TABLE [dbo].[loyalty_rules] CHECK CONSTRAINT [CK_loyalty_rules_stacking_mode]
GO

ALTER TABLE [dbo].[loyalty_rules]  WITH CHECK ADD  CONSTRAINT [CK_loyalty_rules_status] CHECK  (([status]='archived' OR [status]='inactive' OR [status]='active' OR [status]='draft'))
GO

ALTER TABLE [dbo].[loyalty_rules] CHECK CONSTRAINT [CK_loyalty_rules_status]
GO


