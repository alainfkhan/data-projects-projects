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

create or alter function utils.fn_seconds_to_ddhhmmss (
    @total_seconds bigint
)
returns varchar(50)
as
begin
    declare @days smallint
    declare @hours tinyint
    declare @minutes tinyint
    declare @seconds tinyint

    declare @remaining_seconds bigint = @total_seconds

    set @days = @remaining_seconds / 86400
    set @remaining_seconds = @remaining_seconds % 86400

    set @hours = @remaining_seconds / 3600
    set @remaining_seconds = @remaining_seconds % 3600

    set @minutes = @remaining_seconds / 60
    set @seconds = @remaining_seconds % 60

    declare @duration varchar(50) = ''
    if @days > 0
        set @duration = concat(
            @duration,
            cast(@days as varchar),
            case when @days > 1
                then ' days '
                else ' day '
            end
    )

    set @duration = concat(
        @duration,
        format(@hours, '00'), ':',
        format(@minutes, '00'), ':',
        format(@seconds, '00')
    )

    if @total_seconds is null
        set @duration = null

    return @duration
end

go;




