CREATE TABLE [dbo].[notification_templates](
	[id] [uniqueidentifier] NOT NULL,
	[template_key] [varchar](120) NOT NULL,
	[module] [varchar](80) NOT NULL,
	[name] [varchar](180) NOT NULL,
	[description] [varchar](1000) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_notification_templates] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_notification_templates_key] UNIQUE NONCLUSTERED 
(
	[template_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification_templates] ADD  CONSTRAINT [DF_notification_templates_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[notification_templates] ADD  CONSTRAINT [DF_notification_templates_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[notification_templates] ADD  CONSTRAINT [DF_notification_templates_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[notification_templates] ADD  CONSTRAINT [DF_notification_templates_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO

