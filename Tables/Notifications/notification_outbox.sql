CREATE TABLE [dbo].[notification_outbox](
	[id] [uniqueidentifier] NOT NULL,
	[module] [varchar](80) NOT NULL,
	[event_type] [varchar](120) NOT NULL,
	[aggregate_type] [varchar](80) NULL,
	[aggregate_id] [uniqueidentifier] NULL,
	[template_key] [varchar](120) NOT NULL,
	[recipient_type] [varchar](50) NOT NULL,
	[recipient_email] [varchar](320) NOT NULL,
	[recipient_name] [varchar](180) NULL,
	[cc_emails] [varchar](1000) NULL,
	[bcc_emails] [varchar](1000) NULL,
	[payload_json] [nvarchar](max) NOT NULL,
	[priority] [int] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[attempts] [int] NOT NULL,
	[max_attempts] [int] NOT NULL,
	[next_attempt_at] [datetime2](7) NOT NULL,
	[locked_until] [datetime2](7) NULL,
	[lock_id] [uniqueidentifier] NULL,
	[idempotency_key] [varchar](250) NULL,
	[smtp_message_id] [varchar](500) NULL,
	[last_error] [varchar](max) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[sent_at] [datetime2](7) NULL,
	[failed_at] [datetime2](7) NULL,
 CONSTRAINT [PK_notification_outbox] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_priority]  DEFAULT ((5)) FOR [priority]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_attempts]  DEFAULT ((0)) FOR [attempts]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_max_attempts]  DEFAULT ((5)) FOR [max_attempts]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_next_attempt_at]  DEFAULT (sysutcdatetime()) FOR [next_attempt_at]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[notification_outbox] ADD  CONSTRAINT [DF_notification_outbox_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[notification_outbox]  WITH CHECK ADD  CONSTRAINT [CK_notification_outbox_status] CHECK  (([status]='cancelled' OR [status]='dead' OR [status]='failed' OR [status]='sent' OR [status]='processing' OR [status]='pending'))
GO
ALTER TABLE [dbo].[notification_outbox] CHECK CONSTRAINT [CK_notification_outbox_status]
GO

