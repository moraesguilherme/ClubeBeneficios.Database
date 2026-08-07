CREATE TABLE [dbo].[notification_delivery_attempts](
	[id] [uniqueidentifier] NOT NULL,
	[notification_id] [uniqueidentifier] NOT NULL,
	[attempt_number] [int] NOT NULL,
	[status] [varchar](30) NOT NULL,
	[smtp_message_id] [varchar](500) NULL,
	[error_message] [varchar](max) NULL,
	[started_at] [datetime2](7) NOT NULL,
	[finished_at] [datetime2](7) NULL,
 CONSTRAINT [PK_notification_delivery_attempts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[notification_delivery_attempts] ADD  CONSTRAINT [DF_notification_delivery_attempts_id]  DEFAULT (newsequentialid()) FOR [id]
GO
ALTER TABLE [dbo].[notification_delivery_attempts] ADD  CONSTRAINT [DF_notification_delivery_attempts_started_at]  DEFAULT (sysutcdatetime()) FOR [started_at]
GO
ALTER TABLE [dbo].[notification_delivery_attempts]  WITH CHECK ADD  CONSTRAINT [FK_notification_delivery_attempts_outbox] FOREIGN KEY([notification_id])
REFERENCES [dbo].[notification_outbox] ([id])
GO
ALTER TABLE [dbo].[notification_delivery_attempts] CHECK CONSTRAINT [FK_notification_delivery_attempts_outbox]
GO
ALTER TABLE [dbo].[notification_delivery_attempts]  WITH CHECK ADD  CONSTRAINT [CK_notification_delivery_attempts_status] CHECK  (([status]='failed' OR [status]='sent' OR [status]='processing'))
GO
ALTER TABLE [dbo].[notification_delivery_attempts] CHECK CONSTRAINT [CK_notification_delivery_attempts_status]
GO

