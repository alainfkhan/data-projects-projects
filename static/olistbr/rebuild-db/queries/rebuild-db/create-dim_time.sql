use olist_stg;

if (schema_id('utils')) is null
    begin
        exec ('create schema utils');
    end;

if (object_id('utils.dim_time')) is not null
    begin
        -- drop table utils.dim_time;
        set noexec on;
    end;

set nocount on;

/*
minute of day is floor, 0 indexed, is range
minute 0 is 00:00:00 to 00:00:59
minute 1 is 00:01:00 to 00:01:59
minute n is 00:{n}:00 to 00:{n}:59

the first minute is minute 0
the second minute is minute 1
the (n+1)th minute is minute n
*/

-- second [)
create table utils.dim_time (
    time_key int,               -- 33497 = 9*60*60 + 18*60 + 17 | 47281 = 13*60*60 + 8*60 + 1 
    am_pm char(2),              -- AM | PM

    full_time time,             -- 09:18:17 | 13:08:01
    full_time_12 varchar(20),   -- 9:18:17 AM | 1:08:01 PM

    hour_part tinyint,          -- 9 | 13
    hour_part_12 tinyint,       -- 9 | 1
    hh char(2),                 -- 09 | 13
    hh_12 char(2),              -- 09 | 01
    hour_of_day tinyint,        -- 9 | 13

    minute_part tinyint,        -- 18 | 8
    mm char(2),                 -- 18 | 08
    minute_of_day smallint,     -- 558 = 9*60 + 18 | 788 = 13*60 + 8 

    second_part tinyint,        -- 17 | 1
    ss char(2),                 -- 17 | 01
    second_of_day int,          -- 33497 | 47281

    shorthand varchar(10),      -- 9h18 | 13h8
    hhmm char(4),               -- 0918 | 1308
    hhmm_12 char(4),            -- 0918 | 0108
    hhmmss char(6),             -- 091817 | 130801
    hhmmss_12 char(6),          -- 091817 | 010801

    -- day_bucket_24h tinyint,
    day_bucket_12h tinyint,         -- 1 | 2
    day_bucket_8h tinyint,          -- 2 | 2
    day_bucket_6h tinyint,          -- 2 | 3
    day_bucket_4h tinyint,          -- 3 | 4
    day_bucket_3h tinyint,          -- 4 | 5
    day_bucket_2h tinyint,          -- 5 | 7
    -- day_bucket_1h tinyint,

    -- hour_bucket_60m tinyint,
    hour_bucket_30m tinyint,         -- 1 | 1
    hour_bucket_20m tinyint,         -- 1 | 1
    hour_bucket_15m tinyint,         -- 2 | 1
    hour_bucket_10m tinyint,         -- 2 | 1
    -- hour_bucket_6m tinyint,
    hour_bucket_5m tinyint,          -- 4 | 2
    -- hour_bucket_4m tinyint,
    -- hour_bucket_3m tinyint,
    -- hour_bucket_2m tinyint,
    -- hour_bucket_1m tinyint,          -- 18 | 8

    constraint pk_dim_time
        primary key (time_key)
)

declare @time_key int
declare @am_pm char(2)
declare @full_time time
declare @full_time_12 varchar(20)
declare @hour_part tinyint
declare @hour_part_12 tinyint
declare @hh char(2)
declare @hh_12 char(2)
declare @hour_of_day tinyint
declare @minute_part tinyint
declare @mm char(2)
declare @minute_of_day smallint
declare @second_part tinyint
declare @ss char(2)
declare @second_of_day int
declare @shorthand varchar(10)
declare @hhmm char(4)
declare @hhmm_12 char(4)
declare @hhmmss char(6)
declare @hhmmss_12 char(6)
-- declare @day_bucket_24h tinyint
declare @day_bucket_12h tinyint
declare @day_bucket_8h tinyint
declare @day_bucket_6h tinyint
declare @day_bucket_4h tinyint
declare @day_bucket_3h tinyint
declare @day_bucket_2h tinyint
-- declare @day_bucket_1h tinyint
-- declare @hour_bucket_60m tinyint
declare @hour_bucket_30m tinyint
declare @hour_bucket_20m tinyint
declare @hour_bucket_15m tinyint
declare @hour_bucket_10m tinyint
-- declare @hour_bucket_6m tinyint
declare @hour_bucket_5m tinyint
-- declare @hour_bucket_4m tinyint
-- declare @hour_bucket_3m tinyint
-- declare @hour_bucket_2m tinyint
-- declare @hour_bucket_1m tinyint

-- debugs
declare @start_second int = 0
declare @end_second int = 60*60*24 - 1

declare @i_second int = @start_second
while @i_second <= @end_second
    begin

    set @time_key = @start_second

    set @full_time = dateadd(second, @i_second, 0)
    
    set @hour_part = datepart(hour, @full_time)
    set @minute_part = datepart(minute, @full_time)
    set @second_part = datepart(second, @full_time)

    set @am_pm =
        case when @hour_part < 12
            then 'AM'
            else 'PM'
        end;
    
    set @hour_part_12 =
        case when @hour_part <= 12
            then @hour_part
            else @hour_part % 12
        end;
    set @hh = format(@hour_part, '00') 
    set @hh_12 = format(@hour_part_12, '00')
    set @hour_of_day = @hour_part
    
    set @mm = format(@minute_part, '00')
    set @minute_of_day = @hour_part*60 + @minute_part

    set @ss = format(@second_part, '00')
    set @second_of_day = @hour_part*60*60 + @minute_part*60 + @second_part

    set @shorthand = concat(@hour_part, 'h', @mm)
    set @hhmm = concat(@hh, @mm)
    set @hhmm_12 = concat(@hh_12, @mm)
    set @hhmmss = concat(@hh, @mm, @ss)
    set @hhmmss_12 = concat(@hh_12, @mm, @ss)

    -- buckets
    set @day_bucket_12h = ((@hour_part / 12) % 12) + 1
    set @day_bucket_8h = ((@hour_part / 8) % 12) + 1
    set @day_bucket_6h = ((@hour_part / 6) % 12) + 1
    set @day_bucket_4h = ((@hour_part / 4) % 12) + 1
    set @day_bucket_3h = ((@hour_part / 3) % 12) + 1
    set @day_bucket_2h = ((@hour_part / 2) % 12) + 1

    set @hour_bucket_30m = ((@minute_part / 30) % 12) + 1
    set @hour_bucket_20m = ((@minute_part / 20) % 12) + 1
    set @hour_bucket_15m = ((@minute_part / 15) % 12) + 1
    set @hour_bucket_10m = ((@minute_part / 10) % 12) + 1
    set @hour_bucket_5m = ((@minute_part / 5) % 12) + 1

    set @full_time_12 = concat(
        case when @hour_part_12 = 0
            then '12'
            else @hour_part_12
        end,
        ':', @mm, ':', @ss, ' ', @am_pm)

    -- key
    set @time_key = @second_of_day
    
    -- increment
    set @i_second = @i_second + 1

    -- inserts
    insert into utils.dim_time(
        time_key,
        am_pm,
        full_time,
        full_time_12,
        hour_part,
        hour_part_12,
        hh,
        hh_12,
        hour_of_day,
        minute_part,
        mm,
        minute_of_day,
        second_part,
        ss,
        second_of_day,
        shorthand,
        hhmm,
        hhmm_12,
        hhmmss,
        hhmmss_12,
        -- day_bucket_24h,
        day_bucket_12h,
        day_bucket_8h,
        day_bucket_6h,
        day_bucket_4h,
        day_bucket_3h,
        day_bucket_2h,
        -- day_bucket_1h,
        -- hour_bucket_60m,
        hour_bucket_30m,
        hour_bucket_20m,
        hour_bucket_15m,
        hour_bucket_10m,
        -- hour_bucket_6m,
        hour_bucket_5m
        -- hour_bucket_4m,
        -- hour_bucket_3m,
        -- hour_bucket_2m,
        -- hour_bucket_1m,
    )
    select
        @time_key,
        @am_pm,
        @full_time,
        @full_time_12,
        @hour_part,
        @hour_part_12,
        @hh,
        @hh_12,
        @hour_of_day,
        @minute_part,
        @mm,
        @minute_of_day,
        @second_part,
        @ss,
        @second_of_day,
        @shorthand,
        @hhmm,
        @hhmm_12,
        @hhmmss,
        @hhmmss_12,
        -- @day_bucket_24h,
        @day_bucket_12h,
        @day_bucket_8h,
        @day_bucket_6h,
        @day_bucket_4h,
        @day_bucket_3h,
        @day_bucket_2h,
        -- @day_bucket_1h,
        -- @hour_bucket_60m,
        @hour_bucket_30m,
        @hour_bucket_20m,
        @hour_bucket_15m,
        @hour_bucket_10m,
        -- @hour_bucket_6m,
        @hour_bucket_5m
        -- @hour_bucket_4m,
        -- @hour_bucket_3m,
        -- @hour_bucket_2m,
        -- @hour_bucket_1m
    end

set noexec off;


-- select top 1000
-- *
-- from utils.dim_time

/*

select * from utils.dim_time
*/

/* verify


-- verify day_bucket
select
    sub.hour_part,
    sub.day_bucket_2h
from (
    select
        t.hour_part,
        row_number() over (
            partition by t.hour_part
            order by t.day_bucket_2h
        ) as row_num,
        t.day_bucket_2h
    from utils.dim_time as t
) as sub
where sub.row_num = 1
order by sub.hour_part

-- verify hour_bucket
select
    sub.minute_part,
    sub.hour_bucket_5m
from (
    select
        t.minute_part,
        row_number() over (
            partition by t.minute_part
            order by t.hour_bucket_5m
        ) as row_number,
        t.hour_bucket_5m
    from utils.dim_time as t
) as sub
where sub.row_number = 1
order by sub.minute_part

*/
