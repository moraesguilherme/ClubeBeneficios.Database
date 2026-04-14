CREATE TABLE [dbo].[etl_import_row_matches](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[import_row_id] [bigint] NOT NULL,
	[client_id] [uniqueidentifier] NULL,
	[user_id] [uniqueidentifier] NULL,
	[client_pet_id] [uniqueidentifier] NULL,
	[partner_id] [uniqueidentifier] NULL,
	[match_status] [varchar](30) NOT NULL,
	[match_confidence] [decimal](5, 2) NULL,
	[matched_by_rule] [varchar](100) NULL,
	[review_required] [bit] NOT NULL,
	[reviewed_at] [datetime2](7) NULL,
	[reviewed_by_user_id] [uniqueidentifier] NULL,
	[review_notes] [varchar](1500) NULL,
 CONSTRAINT [PK_etl_import_row_matches] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_import_row_matches] ADD  CONSTRAINT [DF_etl_import_row_matches_review_required]  DEFAULT ((0)) FOR [review_required]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_client_pets] FOREIGN KEY([client_pet_id])
REFERENCES [dbo].[client_pets] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_client_pets]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_clients] FOREIGN KEY([client_id])
REFERENCES [dbo].[clients] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_clients]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_partners] FOREIGN KEY([partner_id])
REFERENCES [dbo].[partners] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_partners]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_rows] FOREIGN KEY([import_row_id])
REFERENCES [dbo].[etl_import_rows] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_rows]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_users]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_matches_users_reviewed] FOREIGN KEY([reviewed_by_user_id])
REFERENCES [dbo].[users] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [FK_etl_import_row_matches_users_reviewed]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_row_matches_confidence] CHECK  (([match_confidence] IS NULL OR [match_confidence]>=(0) AND [match_confidence]<=(100)))
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [CK_etl_import_row_matches_confidence]
GO

ALTER TABLE [dbo].[etl_import_row_matches]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_row_matches_match_status] CHECK  (([match_status]='discarded' OR [match_status]='manually_resolved' OR [match_status]='not_matched' OR [match_status]='partially_matched' OR [match_status]='matched'))
GO

ALTER TABLE [dbo].[etl_import_row_matches] CHECK CONSTRAINT [CK_etl_import_row_matches_match_status]
GO


