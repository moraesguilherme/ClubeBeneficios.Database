CREATE TABLE [dbo].[partner_contacts](
	[id] [uniqueidentifier] NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[name] [varchar](180) NOT NULL,
	[role_name] [varchar](120) NULL,
	[email] [varchar](150) NULL,
	[phone] [varchar](30) NULL,
	[is_primary] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_contacts] ADD  CONSTRAINT [DF_partner_contacts_is_primary]  DEFAULT ((0)) FOR [is_primary]
GO
ALTER TABLE [dbo].[partner_contacts] ADD  CONSTRAINT [DF_partner_contacts_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[partner_contacts]  WITH CHECK ADD  CONSTRAINT [FK_partner_contacts_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_contacts] CHECK CONSTRAINT [FK_partner_contacts_partners]
GO

