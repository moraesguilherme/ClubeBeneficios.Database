CREATE TABLE [dbo].[app_settings](
	[setting_key] [varchar](120) NOT NULL,
	[setting_value] [varchar](1000) NOT NULL,
	[description] [varchar](500) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_app_settings] PRIMARY KEY CLUSTERED 
(
	[setting_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[app_settings] ADD  CONSTRAINT [DF_app_settings_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[app_settings] ADD  CONSTRAINT [DF_app_settings_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO

