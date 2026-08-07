CREATE TABLE [dbo].[benefit_code_rules](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[requires_access_code] [bit] NOT NULL,
	[allow_any_active_partner_code] [bit] NOT NULL,
	[specific_access_code_id] [uniqueidentifier] NULL,
	[code_validation_mode] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_code_rules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_benefit_code_rules_benefit] UNIQUE NONCLUSTERED 
(
	[benefit_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_code_rules] ADD  CONSTRAINT [DF_benefit_code_rules_requires_access_code]  DEFAULT ((0)) FOR [requires_access_code]
GO
ALTER TABLE [dbo].[benefit_code_rules] ADD  CONSTRAINT [DF_benefit_code_rules_allow_any_active_partner_code]  DEFAULT ((1)) FOR [allow_any_active_partner_code]
GO
ALTER TABLE [dbo].[benefit_code_rules] ADD  CONSTRAINT [DF_benefit_code_rules_code_validation_mode]  DEFAULT ('partner_code') FOR [code_validation_mode]
GO
ALTER TABLE [dbo].[benefit_code_rules]  WITH CHECK ADD  CONSTRAINT [FK_benefit_code_rules_access_codes] FOREIGN KEY([specific_access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO
ALTER TABLE [dbo].[benefit_code_rules] CHECK CONSTRAINT [FK_benefit_code_rules_access_codes]
GO
ALTER TABLE [dbo].[benefit_code_rules]  WITH CHECK ADD  CONSTRAINT [FK_benefit_code_rules_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO
ALTER TABLE [dbo].[benefit_code_rules] CHECK CONSTRAINT [FK_benefit_code_rules_benefits]
GO
ALTER TABLE [dbo].[benefit_code_rules]  WITH CHECK ADD  CONSTRAINT [CK_benefit_code_rules_code_validation_mode] CHECK  (([code_validation_mode]='invite_code' OR [code_validation_mode]='matilha_coupon' OR [code_validation_mode]='partner_code'))
GO
ALTER TABLE [dbo].[benefit_code_rules] CHECK CONSTRAINT [CK_benefit_code_rules_code_validation_mode]
GO

