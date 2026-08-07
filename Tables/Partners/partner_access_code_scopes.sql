CREATE TABLE [dbo].[partner_access_code_scopes](
	[id] [uniqueidentifier] NOT NULL,
	[partner_access_code_id] [uniqueidentifier] NOT NULL,
	[scope_type] [varchar](40) NOT NULL,
	[external_reference_id] [uniqueidentifier] NULL,
	[external_reference_key] [varchar](100) NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_access_code_scopes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_access_code_scopes]  WITH CHECK ADD  CONSTRAINT [FK_partner_access_code_scopes_access_code] FOREIGN KEY([partner_access_code_id])
REFERENCES [dbo].[partner_access_codes] ([id])
GO
ALTER TABLE [dbo].[partner_access_code_scopes] CHECK CONSTRAINT [FK_partner_access_code_scopes_access_code]
GO
ALTER TABLE [dbo].[partner_access_code_scopes]  WITH CHECK ADD  CONSTRAINT [CK_partner_access_code_scopes_scope_type] CHECK  (([scope_type]='rule' OR [scope_type]='catalog' OR [scope_type]='campaign' OR [scope_type]='benefit_group' OR [scope_type]='benefit'))
GO
ALTER TABLE [dbo].[partner_access_code_scopes] CHECK CONSTRAINT [CK_partner_access_code_scopes_scope_type]
GO

