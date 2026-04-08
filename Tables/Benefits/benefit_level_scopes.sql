CREATE TABLE [dbo].[benefit_level_scopes](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_id] [uniqueidentifier] NOT NULL,
	[level_type] [varchar](30) NOT NULL,
	[level_code] [varchar](30) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_level_scopes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[benefit_level_scopes]  WITH CHECK ADD  CONSTRAINT [FK_benefit_level_scopes_benefits] FOREIGN KEY([benefit_id])
REFERENCES [dbo].[benefits] ([id])
GO

ALTER TABLE [dbo].[benefit_level_scopes] CHECK CONSTRAINT [FK_benefit_level_scopes_benefits]
GO

ALTER TABLE [dbo].[benefit_level_scopes]  WITH CHECK ADD  CONSTRAINT [CK_benefit_level_scopes_level_code] CHECK  (([level_code]='platinum' OR [level_code]='diamond' OR [level_code]='gold' OR [level_code]='silver' OR [level_code]='bronze'))
GO

ALTER TABLE [dbo].[benefit_level_scopes] CHECK CONSTRAINT [CK_benefit_level_scopes_level_code]
GO

ALTER TABLE [dbo].[benefit_level_scopes]  WITH CHECK ADD  CONSTRAINT [CK_benefit_level_scopes_level_type] CHECK  (([level_type]='client_level' OR [level_type]='partner_level'))
GO

ALTER TABLE [dbo].[benefit_level_scopes] CHECK CONSTRAINT [CK_benefit_level_scopes_level_type]
GO


