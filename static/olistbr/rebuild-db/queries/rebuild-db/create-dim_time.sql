-- USE olist_stg;

IF (SCHEMA_ID('utils')) IS NULL
    BEGIN
        EXEC ('create schema utils');
    END;

IF (OBJECT_ID('utils.dim_time')) IS NOT NULL
    BEGIN
        -- drop table utils.dim_time;
        SET NOEXEC ON;
    END;

SET NOCOUNT ON;

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
CREATE TABLE utils.dim_time (
    time_key INT,               -- 33497 = 9*60*60 + 18*60 + 17 | 47281 = 13*60*60 + 8*60 + 1 
    am_pm CHAR(2),              -- AM | PM

    full_time TIME,             -- 09:18:17 | 13:08:01
    full_time_12 VARCHAR(20),   -- 9:18:17 AM | 1:08:01 PM

    hour_part TINYINT,          -- 9 | 13
    hour_part_12 TINYINT,       -- 9 | 1
    hh CHAR(2),                 -- 09 | 13
    hh_12 CHAR(2),              -- 09 | 01
    hour_of_day TINYINT,        -- 9 | 13

    minute_part TINYINT,        -- 18 | 8
    mm CHAR(2),                 -- 18 | 08
    minute_of_day SMALLINT,     -- 558 = 9*60 + 18 | 788 = 13*60 + 8 

    second_part TINYINT,        -- 17 | 1
    ss CHAR(2),                 -- 17 | 01
    second_of_day INT,          -- 33497 | 47281

    shorthand VARCHAR(10),      -- 9h18 | 13h8
    hhmm CHAR(4),               -- 0918 | 1308
    hhmm_12 CHAR(4),            -- 0918 | 0108
    hhmmss CHAR(6),             -- 091817 | 130801
    hhmmss_12 CHAR(6),          -- 091817 | 010801

    -- day_bucket_24h tinyint,
    day_bucket_12h TINYINT,         -- 1 | 2
    day_bucket_8h TINYINT,          -- 2 | 2
    day_bucket_6h TINYINT,          -- 2 | 3
    day_bucket_4h TINYINT,          -- 3 | 4
    day_bucket_3h TINYINT,          -- 4 | 5
    day_bucket_2h TINYINT,          -- 5 | 7
    -- day_bucket_1h tinyint,

    -- hour_bucket_60m tinyint,
    hour_bucket_30m TINYINT,         -- 1 | 1
    hour_bucket_20m TINYINT,         -- 1 | 1
    hour_bucket_15m TINYINT,         -- 2 | 1
    hour_bucket_10m TINYINT,         -- 2 | 1
    -- hour_bucket_6m tinyint,
    hour_bucket_5m TINYINT,          -- 4 | 2
    -- hour_bucket_4m tinyint,
    -- hour_bucket_3m tinyint,
    -- hour_bucket_2m tinyint,
    -- hour_bucket_1m tinyint,          -- 18 | 8

    CONSTRAINT pk_dim_time
        PRIMARY KEY (time_key)
)

DECLARE @time_key INT
DECLARE @am_pm CHAR(2)
DECLARE @full_time TIME
DECLARE @full_time_12 VARCHAR(20)
DECLARE @hour_part TINYINT
DECLARE @hour_part_12 TINYINT
DECLARE @hh CHAR(2)
DECLARE @hh_12 CHAR(2)
DECLARE @hour_of_day TINYINT
DECLARE @minute_part TINYINT
DECLARE @mm CHAR(2)
DECLARE @minute_of_day SMALLINT
DECLARE @second_part TINYINT
DECLARE @ss CHAR(2)
DECLARE @second_of_day INT
DECLARE @shorthand VARCHAR(10)
DECLARE @hhmm CHAR(4)
DECLARE @hhmm_12 CHAR(4)
DECLARE @hhmmss CHAR(6)
DECLARE @hhmmss_12 CHAR(6)
-- declare @day_bucket_24h tinyint
DECLARE @day_bucket_12h TINYINT
DECLARE @day_bucket_8h TINYINT
DECLARE @day_bucket_6h TINYINT
DECLARE @day_bucket_4h TINYINT
DECLARE @day_bucket_3h TINYINT
DECLARE @day_bucket_2h TINYINT
-- declare @day_bucket_1h tinyint
-- declare @hour_bucket_60m tinyint
DECLARE @hour_bucket_30m TINYINT
DECLARE @hour_bucket_20m TINYINT
DECLARE @hour_bucket_15m TINYINT
DECLARE @hour_bucket_10m TINYINT
-- declare @hour_bucket_6m tinyint
DECLARE @hour_bucket_5m TINYINT
-- declare @hour_bucket_4m tinyint
-- declare @hour_bucket_3m tinyint
-- declare @hour_bucket_2m tinyint
-- declare @hour_bucket_1m tinyint

-- debugs
DECLARE @start_second INT = 0
DECLARE @end_second INT = 60 * 60 * 24 - 1

DECLARE @i_second INT = @start_second
WHILE @i_second <= @end_second
    BEGIN

    SET @time_key = @start_second

    SET @full_time = DATEADD(SECOND, @i_second, 0)

    SET @hour_part = DATEPART(HOUR, @full_time)
    SET @minute_part = DATEPART(MINUTE, @full_time)
    SET @second_part = DATEPART(SECOND, @full_time)

    SET @am_pm =
        CASE WHEN @hour_part < 12
            THEN 'AM'
            ELSE 'PM'
        END;

    SET @hour_part_12 =
        CASE WHEN @hour_part <= 12
            THEN @hour_part
            ELSE @hour_part % 12
        END;
    SET @hh = FORMAT(@hour_part, '00')
    SET @hh_12 = FORMAT(@hour_part_12, '00')
    SET @hour_of_day = @hour_part

    SET @mm = FORMAT(@minute_part, '00')
    SET @minute_of_day = @hour_part * 60 + @minute_part

    SET @ss = FORMAT(@second_part, '00')
    SET @second_of_day = @hour_part * 60 * 60 + @minute_part * 60 + @second_part

    SET @shorthand = CONCAT(@hour_part, 'h', @mm)
    SET @hhmm = CONCAT(@hh, @mm)
    SET @hhmm_12 = CONCAT(@hh_12, @mm)
    SET @hhmmss = CONCAT(@hh, @mm, @ss)
    SET @hhmmss_12 = CONCAT(@hh_12, @mm, @ss)

    -- buckets
    SET @day_bucket_12h = ((@hour_part / 12) % 12) + 1
    SET @day_bucket_8h = ((@hour_part / 8) % 12) + 1
    SET @day_bucket_6h = ((@hour_part / 6) % 12) + 1
    SET @day_bucket_4h = ((@hour_part / 4) % 12) + 1
    SET @day_bucket_3h = ((@hour_part / 3) % 12) + 1
    SET @day_bucket_2h = ((@hour_part / 2) % 12) + 1

    SET @hour_bucket_30m = ((@minute_part / 30) % 12) + 1
    SET @hour_bucket_20m = ((@minute_part / 20) % 12) + 1
    SET @hour_bucket_15m = ((@minute_part / 15) % 12) + 1
    SET @hour_bucket_10m = ((@minute_part / 10) % 12) + 1
    SET @hour_bucket_5m = ((@minute_part / 5) % 12) + 1

    SET @full_time_12 = CONCAT(
        CASE WHEN @hour_part_12 = 0
            THEN '12'
            ELSE @hour_part_12
        END,
        ':', @mm, ':', @ss, ' ', @am_pm)

    -- key
    SET @time_key = @second_of_day

    -- increment
    SET @i_second = @i_second + 1

    -- inserts
    INSERT INTO utils.dim_time (
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
    SELECT
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
    END

SET NOEXEC OFF;

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
