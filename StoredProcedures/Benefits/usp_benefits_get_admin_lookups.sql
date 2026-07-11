CREATE   PROCEDURE [dbo].[usp_benefits_get_admin_lookups]
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.usp_benefits_admin_filter_options;
END
GO

