CREATE   PROCEDURE [dbo].[usp_loyalty_lookup_source_types]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        VALUES
            ('etl_payment_row',   'Linha ETL financeira', 1),
            ('loyalty_redemption','Resgate de reward',    2),
            ('loyalty_adjustment','Ajuste manual',        3),
            ('system',            'Sistema',              4),
            ('admin',             'Admin',                5),
            ('internal',          'Interno',              6)
    ) AS x(source_type_code, source_type_name, display_order)
    ORDER BY x.display_order;
END
GO


