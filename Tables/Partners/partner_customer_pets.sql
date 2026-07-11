CREATE TABLE [dbo].[partner_customer_pets](
	[id] [uniqueidentifier] NOT NULL,
	[partner_customer_id] [uniqueidentifier] NOT NULL,
	[name] [varchar](120) NOT NULL,
	[species] [varchar](30) NOT NULL,
	[breed] [varchar](100) NULL,
	[sex] [varchar](20) NULL,
	[birth_date] [date] NULL,
	[age_months] [int] NULL,
	[weight_kg] [decimal](10, 2) NULL,
	[size] [varchar](30) NULL,
	[color] [varchar](60) NULL,
	[is_neutered] [bit] NOT NULL,
	[neutered_at] [date] NULL,
	[behavior_status] [varchar](30) NOT NULL,
	[temperament_summary] [varchar](1000) NULL,
	[restriction_notes] [varchar](1500) NULL,
	[medical_notes] [varchar](1500) NULL,
	[feeding_notes] [varchar](1500) NULL,
	[special_care_notes] [varchar](1500) NULL,
	[status] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_customer_pets] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_species]  DEFAULT ('dog') FOR [species]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_is_neutered]  DEFAULT ((0)) FOR [is_neutered]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_behavior_status]  DEFAULT ('not_evaluated') FOR [behavior_status]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_status]  DEFAULT ('active') FOR [status]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[partner_customer_pets] ADD  CONSTRAINT [DF_partner_customer_pets_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [FK_partner_customer_pets_partner_customers] FOREIGN KEY([partner_customer_id])
REFERENCES [dbo].[partner_customers] ([id])
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [FK_partner_customer_pets_partner_customers]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_age_months] CHECK  (([age_months] IS NULL OR [age_months]>=(0)))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_age_months]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_behavior_status] CHECK  (([behavior_status]='rejected' OR [behavior_status]='approved_with_restrictions' OR [behavior_status]='approved' OR [behavior_status]='pending_evaluation' OR [behavior_status]='not_evaluated'))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_behavior_status]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_sex] CHECK  (([sex] IS NULL OR ([sex]='female' OR [sex]='male')))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_sex]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_size] CHECK  (([size] IS NULL OR ([size]='giant' OR [size]='large' OR [size]='medium' OR [size]='small')))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_size]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_species] CHECK  (([species]='other' OR [species]='dog'))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_species]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_status] CHECK  (([status]='archived' OR [status]='blocked' OR [status]='inactive' OR [status]='active'))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_status]
GO
ALTER TABLE [dbo].[partner_customer_pets]  WITH CHECK ADD  CONSTRAINT [CK_partner_customer_pets_weight_kg] CHECK  (([weight_kg] IS NULL OR [weight_kg]>=(0)))
GO
ALTER TABLE [dbo].[partner_customer_pets] CHECK CONSTRAINT [CK_partner_customer_pets_weight_kg]
GO

