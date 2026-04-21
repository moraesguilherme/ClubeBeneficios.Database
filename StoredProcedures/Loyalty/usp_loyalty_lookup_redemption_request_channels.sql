CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_redemption_request_channels]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('admin',         'Admin',              1),
            ('client_portal', 'Portal do cliente',  2),
            ('system',        'Sistema',            3),
            ('internal',      'Interno',            4)
    ) AS x(channel_code, channel_name, display_order)
    ORDER BY x.display_order;
END
GO


