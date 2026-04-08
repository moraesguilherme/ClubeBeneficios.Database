CREATE TABLE [dbo].[client_status_history](
	[id] [uniqueidentifier] NOT NULL,
	[client_id] [uniqueidentifier] NOT NULL,
	[old_status] [varchar](30) NULL,
	[new_status] [varchar](30) NOT NULL,
	[reason] [varchar](500) NULL,
	[changed_at] [datetime2](7) NOT NULL,
	[changed_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_client_status_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[client_status_history] ADD  DEFAULT (newsequentialid()) FOR [id]
GO

ALTER TABLE [dbo].[client_status_history] ADD  CONSTRAINT [DF_client_status_history_changed_at]  DEFAULT (sysutcdatetime()) FOR [changed_at]
GO

ALTER TABLE [dbo].[client_status_history]  WITH CHECK ADD  CONSTRAINT [FK_client_status_history_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[client_status_history] CHECK CONSTRAINT [FK_client_status_history_clients]
GO

ALTER TABLE [dbo].[client_status_history]  WITH CHECK ADD  CONSTRAINT [CK_client_status_history_new_status] CHECK  (([new_status]='archived' OR [new_status]='blocked' OR [new_status]='inactive' OR [new_status]='active' OR [new_status]='pending_behavior_evaluation' OR [new_status]='pending_documents' OR [new_status]='pending_profile' OR [new_status]='lead'))
GO

ALTER TABLE [dbo].[client_status_history] CHECK CONSTRAINT [CK_client_status_history_new_status]
GO

ALTER TABLE [dbo].[client_status_history]  WITH CHECK ADD  CONSTRAINT [CK_client_status_history_old_status] CHECK  (([old_status] IS NULL OR ([old_status]='archived' OR [old_status]='blocked' OR [old_status]='inactive' OR [old_status]='active' OR [old_status]='pending_behavior_evaluation' OR [old_status]='pending_documents' OR [old_status]='pending_profile' OR [old_status]='lead')))
GO

ALTER TABLE [dbo].[client_status_history] CHECK CONSTRAINT [CK_client_status_history_old_status]
GO


