USE olist_stg;

-- datetime to datekey function (avoid using)
GO;

CREATE OR ALTER FUNCTION utils.fn_datetime_to_datekey(
    @i_date DATETIME2
)
RETURNS INT
AS
BEGIN
    DECLARE @date_key INT = CONCAT(
        DATEPART(YEAR, @i_date),
        FORMAT(DATEPART(MONTH, @i_date), '00'),
        FORMAT(DATEPART(DAY, @i_date), '00')
    )
    RETURN @date_key
END

GO;
