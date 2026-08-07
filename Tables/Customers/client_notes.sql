CREATE TABLE [dbo].[client_notes](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[note_type] [varchar](30) NOT NULL,
	[title] [varchar](150) NULL,
	[content] [varchar](2000) NOT NULL,
	[is_internal] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_client_notes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[client_notes] ADD  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[client_notes] ADD  CONSTRAINT [DF_client_notes_note_type]  DEFAULT ('general') FOR [note_type]
GO
ALTER TABLE [dbo].[client_notes] ADD  CONSTRAINT [DF_client_notes_is_internal]  DEFAULT ((1)) FOR [is_internal]
GO
ALTER TABLE [dbo].[client_notes] ADD  CONSTRAINT [DF_client_notes_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[client_notes]  WITH CHECK ADD  CONSTRAINT [FK_client_notes_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO
ALTER TABLE [dbo].[client_notes] CHECK CONSTRAINT [FK_client_notes_clients]
GO
ALTER TABLE [dbo].[client_notes]  WITH CHECK ADD  CONSTRAINT [CK_client_notes_note_type] CHECK  (([note_type]='warning' OR [note_type]='approval' OR [note_type]='financial' OR [note_type]='behavior' OR [note_type]='service' OR [note_type]='general'))
GO
ALTER TABLE [dbo].[client_notes] CHECK CONSTRAINT [CK_client_notes_note_type]
GO

