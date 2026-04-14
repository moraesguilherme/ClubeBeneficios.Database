CREATE TABLE [dbo].[etl_import_row_errors](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[import_row_id] [bigint] NOT NULL,
	[error_code] [varchar](100) NOT NULL,
	[error_message] [varchar](2000) NOT NULL,
	[error_stage] [varchar](50) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_etl_import_row_errors] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[etl_import_row_errors]  WITH CHECK ADD  CONSTRAINT [FK_etl_import_row_errors_rows] FOREIGN KEY([import_row_id])
REFERENCES [dbo].[etl_import_rows] ([id])
GO

ALTER TABLE [dbo].[etl_import_row_errors] CHECK CONSTRAINT [FK_etl_import_row_errors_rows]
GO

ALTER TABLE [dbo].[etl_import_row_errors]  WITH CHECK ADD  CONSTRAINT [CK_etl_import_row_errors_error_stage] CHECK  (([error_stage]='persist' OR [error_stage]='transform' OR [error_stage]='match' OR [error_stage]='parse' OR [error_stage]='read'))
GO

ALTER TABLE [dbo].[etl_import_row_errors] CHECK CONSTRAINT [CK_etl_import_row_errors_error_stage]
GO


