use olist_stg;

-- datetime to datekey function (slow, dont use)
go;

create or alter function utils.fn_datetime_to_datekey
(
    @i_date datetime2
)
returns int
as
begin
    declare @date_key int = concat(
        datepart(year, @i_date),
        format(datepart(month, @i_date), '00'),
        format(datepart(day, @i_date), '00')
    )
    return @date_key
end

go;
