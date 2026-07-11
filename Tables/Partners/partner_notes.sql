CREATE TABLE [dbo].[partner_notes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[partner_id] [uniqueidentifier] NOT NULL,
	[note_type] [varchar](30) NOT NULL,
	[content] [varchar](max) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_partner_notes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[partner_notes] ADD  CONSTRAINT [DF_partner_notes_type]  DEFAULT ('general') FOR [note_type]
GO
ALTER TABLE [dbo].[partner_notes]  WITH CHECK ADD  CONSTRAINT [FK_partner_notes_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO
ALTER TABLE [dbo].[partner_notes] CHECK CONSTRAINT [FK_partner_notes_partners]
GO
ALTER TABLE [dbo].[partner_notes]  WITH CHECK ADD  CONSTRAINT [FK_partner_notes_users] FOREIGN KEY([created_by_user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[partner_notes] CHECK CONSTRAINT [FK_partner_notes_users]
GO
ALTER TABLE [dbo].[partner_notes]  WITH CHECK ADD  CONSTRAINT [CK_partner_notes_type] CHECK  (([note_type]='approval' OR [note_type]='operational' OR [note_type]='commercial' OR [note_type]='general'))
GO
ALTER TABLE [dbo].[partner_notes] CHECK CONSTRAINT [CK_partner_notes_type]
GO

