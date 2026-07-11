CREATE TABLE [dbo].[notification_template_versions](
	[id] [uniqueidentifier] NOT NULL,
	[template_id] [uniqueidentifier] NOT NULL,
	[version_number] [int] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[subject_template] [varchar](300) NOT NULL,
	[body_html_template] [varchar](max) NOT NULL,
	[body_text_template] [varchar](max) NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[created_at] [datetime2](7) NOT NULL,
	[activated_at] [datetime2](7) NULL,
 CONSTRAINT [PK_notification_template_versions] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification_template_versions] ADD  CONSTRAINT [DF_notification_template_versions_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[notification_template_versions] ADD  CONSTRAINT [DF_notification_template_versions_status]  DEFAULT ('draft') FOR [status]
GO
ALTER TABLE [dbo].[notification_template_versions] ADD  CONSTRAINT [DF_notification_template_versions_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[notification_template_versions]  WITH CHECK ADD  CONSTRAINT [FK_notification_template_versions_templates] FOREIGN KEY([template_id])
REFERENCES [dbo].[notification_templates] ([id])
GO
ALTER TABLE [dbo].[notification_template_versions] CHECK CONSTRAINT [FK_notification_template_versions_templates]
GO
ALTER TABLE [dbo].[notification_template_versions]  WITH CHECK ADD  CONSTRAINT [CK_notification_template_versions_status] CHECK  (([status]='archived' OR [status]='active' OR [status]='draft'))
GO
ALTER TABLE [dbo].[notification_template_versions] CHECK CONSTRAINT [CK_notification_template_versions_status]
GO

