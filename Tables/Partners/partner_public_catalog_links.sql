CREATE TABLE [dbo].[partner_public_catalog_links](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[slug] [varchar](140) NOT NULL,
	[title] [varchar](180) NULL,
	[description] [varchar](500) NULL,
	[status] [varchar](30) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_public_catalog_links] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_public_catalog_links] ADD  CONSTRAINT [DF_partner_public_catalog_links_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[partner_public_catalog_links] ADD  CONSTRAINT [DF_partner_public_catalog_links_status]  DEFAULT ('active') FOR [status]
GO
ALTER TABLE [dbo].[partner_public_catalog_links] ADD  CONSTRAINT [DF_partner_public_catalog_links_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[partner_public_catalog_links] ADD  CONSTRAINT [DF_partner_public_catalog_links_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[partner_public_catalog_links]  WITH CHECK ADD  CONSTRAINT [FK_partner_public_catalog_links_created_by_user] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partner_public_catalog_links] CHECK CONSTRAINT [FK_partner_public_catalog_links_created_by_user]
GO
ALTER TABLE [dbo].[partner_public_catalog_links]  WITH CHECK ADD  CONSTRAINT [FK_partner_public_catalog_links_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_public_catalog_links] CHECK CONSTRAINT [FK_partner_public_catalog_links_partners]
GO
ALTER TABLE [dbo].[partner_public_catalog_links]  WITH CHECK ADD  CONSTRAINT [CK_partner_public_catalog_links_status] CHECK  (([status]='blocked' OR [status]='inactive' OR [status]='active'))
GO
ALTER TABLE [dbo].[partner_public_catalog_links] CHECK CONSTRAINT [CK_partner_public_catalog_links_status]
GO

