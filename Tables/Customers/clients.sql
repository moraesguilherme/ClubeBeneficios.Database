CREATE TABLE [dbo].[clients](
	[id] [uniqueidentifier] NOT NULL,
	[user_id] [uniqueidentifier] NULL,
	[full_name] [varchar](150) NOT NULL,
	[document] [varchar](30) NULL,
	[email] [varchar](150) NOT NULL,
	[phone] [varchar](30) NULL,
	[birth_date] [date] NULL,
	[instagram] [varchar](100) NULL,
	[address_zip_code] [varchar](20) NULL,
	[address_street] [varchar](150) NULL,
	[address_number] [varchar](30) NULL,
	[address_complement] [varchar](100) NULL,
	[address_neighborhood] [varchar](100) NULL,
	[address_city] [varchar](100) NULL,
	[address_state] [varchar](50) NULL,
	[origin_type] [varchar](30) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[notes_summary] [varchar](1000) NULL,
	[accepts_marketing] [bit] NOT NULL,
	[lgpd_consent_at] [datetime2](7) NULL,
	[first_service_at] [datetime2](7) NULL,
	[last_service_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
	[created_by_user_id] [uniqueidentifier] NULL,
	[updated_by_user_id] [uniqueidentifier] NULL,
 CONSTRAINT [PK_clients] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[clients] ADD  DEFAULT (newsequentialid()) FOR [id]
GO

ALTER TABLE [dbo].[clients] ADD  CONSTRAINT [DF_clients_origin_type]  DEFAULT ('manual') FOR [origin_type]
GO

ALTER TABLE [dbo].[clients] ADD  CONSTRAINT [DF_clients_status]  DEFAULT ('lead') FOR [status]
GO

ALTER TABLE [dbo].[clients] ADD  CONSTRAINT [DF_clients_accepts_marketing]  DEFAULT ((0)) FOR [accepts_marketing]
GO

ALTER TABLE [dbo].[clients] ADD  CONSTRAINT [DF_clients_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO

ALTER TABLE [dbo].[clients] ADD  CONSTRAINT [DF_clients_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO

ALTER TABLE [dbo].[clients]  WITH CHECK ADD  CONSTRAINT [CK_clients_origin_type] CHECK  (([origin_type]='internal_import' OR [origin_type]='partner_conversion' OR [origin_type]='indication' OR [origin_type]='landing_page' OR [origin_type]='site' OR [origin_type]='manual'))
GO

ALTER TABLE [dbo].[clients] CHECK CONSTRAINT [CK_clients_origin_type]
GO

ALTER TABLE [dbo].[clients]  WITH CHECK ADD  CONSTRAINT [CK_clients_status] CHECK  (([status]='archived' OR [status]='blocked' OR [status]='inactive' OR [status]='active' OR [status]='pending_behavior_evaluation' OR [status]='pending_documents' OR [status]='pending_profile' OR [status]='lead'))
GO

ALTER TABLE [dbo].[clients] CHECK CONSTRAINT [CK_clients_status]
GO


