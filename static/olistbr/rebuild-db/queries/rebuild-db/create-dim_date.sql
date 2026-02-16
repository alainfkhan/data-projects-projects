/*
create dim_dates table
choose 2016-01-01 to 2020-12-31 inclusive

use english names
follow brazilian financial year
    jan1 - dec31
    fiscal year is calendar year
follow brasilia time
    BRT = UTC-3
    daylight savings time stopped april 2019
follow iso 8601
    day 1: monday
    day 7: sunday

select * from core.dim_date

*/

USE olist_stg;

-- if schema core doest exist, create it
if (schema_id('core')) is null
    begin
        exec ('create schema core');
    end

-- if table exists return
if (object_id('core.dim_date')) is not null
    begin
        set noexec on;
    end

-- settings
-- set day1=monday
-- force
SET DATEFIRST 1;

CREATE TABLE core.dim_date (
    date_key INT,
    full_date DATE,
    day_of_week TINYINT,
    day_name VARCHAR(20),
    day_name_short VARCHAR(10),
    is_weekend BIT,
    day_of_month TINYINT,
    is_end_of_month BIT,
    day_of_year SMALLINT,
    week_number TINYINT,
    month_number TINYINT,
    month_name VARCHAR(20),
    month_name_short VARCHAR(10),
    quarter_number TINYINT,
    year_number SMALLINT

    CONSTRAINT pk_date_key
        PRIMARY KEY (date_key)
);

DECLARE @date_key INT
DECLARE @full_date DATE
DECLARE @day_of_week TINYINT
DECLARE @day_name VARCHAR(20)
DECLARE @day_name_short VARCHAR(10)
DECLARE @is_weekend BIT
DECLARE @day_of_month TINYINT
DECLARE @is_end_of_month BIT
DECLARE @day_of_year SMALLINT
DECLARE @week_number TINYINT
DECLARE @month_number TINYINT
DECLARE @month_name VARCHAR(20)
DECLARE @month_name_short VARCHAR(10)
DECLARE @quarter_number TINYINT
DECLARE @year_number SMALLINT

-- determined from analysis
DECLARE @first_date DATE = '2016-01-01'
DECLARE @end_date DATE = '2020-12-31'

DECLARE @i_date DATE = @first_date
WHILE @i_date <= @end_date
    BEGIN

    SET @full_date = @i_date
    SET @day_of_week = DATEPART(WEEKDAY, @i_date)
    SET @day_name = DATENAME(WEEKDAY, @i_date)
    SET @day_name_short = LEFT(@day_name, 3)
    SET @is_weekend =
        CASE WHEN @day_of_week IN (6, 7)
            THEN 1
            ELSE 0
        END;

    SET @day_of_month = DATEPART(DAY, @i_date)
    SET @is_end_of_month =
        CASE WHEN @i_date = EOMONTH(@i_date)
            THEN 1
            ELSE 0
        END;

    SET @day_of_year = DATEPART(DAYOFYEAR, @i_date)
    SET @week_number = DATEPART(WEEK, @i_date)
    SET @month_number = DATEPART(MONTH, @i_date)
    SET @month_name = DATENAME(MONTH, @i_date)
    SET @month_name_short = LEFT(@month_name, 3)
    SET @quarter_number = DATEPART(QUARTER, @i_date)
    SET @year_number = DATEPART(YEAR, @i_date)

    DECLARE @zero_padded_month_number CHAR(2) = FORMAT(@month_number, '00')
    DECLARE @zero_padded_day_of_month CHAR(2) = FORMAT(@day_of_month, '00')
    SET @date_key = CAST(
        CONCAT(
            @year_number, @zero_padded_month_number, @zero_padded_day_of_month
        ) AS INT
    )

    -- increment
    SET @i_date = DATEADD(DAY, 1, @i_date)

    INSERT INTO core.dim_date(
        date_key,
        full_date,
        day_of_week,
        day_name,
        day_name_short,
        is_weekend,
        day_of_month,
        is_end_of_month,
        day_of_year,
        week_number,
        month_number,
        month_name,
        month_name_short,
        quarter_number,
        year_number
    )
    SELECT
        @date_key AS date_key,
        @full_date AS full_date,
        @day_of_week AS day_of_week,
        @day_name AS day_name,
        @day_name_short AS day_name_short,
        @is_weekend AS is_weekend,
        @day_of_month AS day_of_month,
        @is_end_of_month AS is_end_of_month,
        @day_of_year AS day_of_year,
        @week_number AS week_number,
        @month_number AS month_number,
        @month_name AS month_name,
        @month_name_short AS month_name_short,
        @quarter_number AS quarter_number,
        @year_number AS year_number;
    END

set noexec off;