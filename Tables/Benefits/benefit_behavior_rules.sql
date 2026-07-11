CREATE TABLE [dbo].[benefit_behavior_rules](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[min_frequency_enabled] [bit] NOT NULL,
	[min_frequency_value] [int] NULL,
	[frequency_window_months] [int] NULL,
	[min_ticket_enabled] [bit] NOT NULL,
	[min_ticket_value] [decimal](18, 2) NULL,
	[ticket_window_months] [int] NULL,
	[first_use_only] [bit] NOT NULL,
	[requires_matilha_approval] [bit] NOT NULL,
	[custom_rule_text] [varchar](1500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_behavior_rules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_benefit_behavior_rules_benefit] UNIQUE NONCLUSTERED 
(
	[benefit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_behavior_rules] ADD  CONSTRAINT [DF_benefit_behavior_rules_min_frequency_enabled]  DEFAULT ((0)) FOR [min_frequency_enabled]
GO
ALTER TABLE [dbo].[benefit_behavior_rules] ADD  CONSTRAINT [DF_benefit_behavior_rules_min_ticket_enabled]  DEFAULT ((0)) FOR [min_ticket_enabled]
GO
ALTER TABLE [dbo].[benefit_behavior_rules] ADD  CONSTRAINT [DF_benefit_behavior_rules_first_use_only]  DEFAULT ((0)) FOR [first_use_only]
GO
ALTER TABLE [dbo].[benefit_behavior_rules] ADD  CONSTRAINT [DF_benefit_behavior_rules_requires_matilha_approval]  DEFAULT ((0)) FOR [requires_matilha_approval]
GO
ALTER TABLE [dbo].[benefit_behavior_rules]  WITH CHECK ADD  CONSTRAINT [FK_benefit_behavior_rules_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[benefit_behavior_rules] CHECK CONSTRAINT [FK_benefit_behavior_rules_benefits]
GO
ALTER TABLE [dbo].[benefit_behavior_rules]  WITH CHECK ADD  CONSTRAINT [CK_benefit_behavior_rules_frequency_window] CHECK  (([frequency_window_months] IS NULL OR [frequency_window_months]>(0)))
GO
ALTER TABLE [dbo].[benefit_behavior_rules] CHECK CONSTRAINT [CK_benefit_behavior_rules_frequency_window]
GO
ALTER TABLE [dbo].[benefit_behavior_rules]  WITH CHECK ADD  CONSTRAINT [CK_benefit_behavior_rules_min_frequency_value] CHECK  (([min_frequency_value] IS NULL OR [min_frequency_value]>=(0)))
GO
ALTER TABLE [dbo].[benefit_behavior_rules] CHECK CONSTRAINT [CK_benefit_behavior_rules_min_frequency_value]
GO
ALTER TABLE [dbo].[benefit_behavior_rules]  WITH CHECK ADD  CONSTRAINT [CK_benefit_behavior_rules_min_ticket_value] CHECK  (([min_ticket_value] IS NULL OR [min_ticket_value]>=(0)))
GO
ALTER TABLE [dbo].[benefit_behavior_rules] CHECK CONSTRAINT [CK_benefit_behavior_rules_min_ticket_value]
GO
ALTER TABLE [dbo].[benefit_behavior_rules]  WITH CHECK ADD  CONSTRAINT [CK_benefit_behavior_rules_ticket_window] CHECK  (([ticket_window_months] IS NULL OR [ticket_window_months]>(0)))
GO
ALTER TABLE [dbo].[benefit_behavior_rules] CHECK CONSTRAINT [CK_benefit_behavior_rules_ticket_window]
GO

