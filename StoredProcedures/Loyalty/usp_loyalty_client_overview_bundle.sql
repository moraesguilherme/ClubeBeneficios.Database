CREATE   PROCEDURE [dbo].[usp_loyalty_client_overview_bundle]
    @ClientId uniqueidentifier,
    @LedgerDateFrom datetime2(7) = NULL,
    @LedgerDateTo datetime2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_loyalty_client_profile_summary
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_client_balance_get
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_client_latest_score_get
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_client_latest_level_get
        @ClientId = @ClientId;

    EXEC dbo.usp_loyalty_client_ledger_summary
        @ClientId = @ClientId,
        @DateFrom = @LedgerDateFrom,
        @DateTo = @LedgerDateTo;
END
GO


