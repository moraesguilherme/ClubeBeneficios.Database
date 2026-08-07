CREATE TABLE [dbo].[notification_recipients](
	[id] [uniqueidentifier] NOT NULL,
	[module] [varchar](80) NOT NULL,
	[event_type] [varchar](120) NOT NULL,
	[recipient_type] [varchar](50) NOT NULL,
	[recipient_email] [varchar](320) NOT NULL,
	[recipient_name] [varchar](180) NULL,
	[is_active] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_notification_recipients] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification_recipients] ADD  CONSTRAINT [DF_notification_recipients_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[notification_recipients] ADD  CONSTRAINT [DF_notification_recipients_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[notification_recipients] ADD  CONSTRAINT [DF_notification_recipients_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[notification_recipients] ADD  CONSTRAINT [DF_notification_recipients_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO

