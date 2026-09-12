CREATE TABLE [dbo].[benefit_request_correction_tokens](
	[id] [uniqueidentifier] NOT NULL,
	[benefit_request_id] [uniqueidentifier] NOT NULL,
	[token_hash] [varchar](128) NOT NULL,
	[status] [varchar](30) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[used_at] [datetime2](7) NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benefit_request_correction_tokens] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_benefit_request_correction_tokens_token_hash] UNIQUE NONCLUSTERED 
(
	[token_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_request_correction_tokens]  WITH CHECK ADD  CONSTRAINT [FK_benefit_request_correction_tokens_request] FOREIGN KEY([benefit_request_id])
REFERENCES [dbo].[benefit_requests] ([id])
GO
ALTER TABLE [dbo].[benefit_request_correction_tokens] CHECK CONSTRAINT [FK_benefit_request_correction_tokens_request]
GO
ALTER TABLE [dbo].[benefit_request_correction_tokens]  WITH CHECK ADD  CONSTRAINT [CK_benefit_request_correction_tokens_status] CHECK  (([status]='cancelled' OR [status]='expired' OR [status]='used' OR [status]='active'))
GO
ALTER TABLE [dbo].[benefit_request_correction_tokens] CHECK CONSTRAINT [CK_benefit_request_correction_tokens_status]
GO

