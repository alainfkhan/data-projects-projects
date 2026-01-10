/*
Create proper tables of imported data.

The Rank column of all tables are unique
Assume all column datatypes are consistent
Convert column names to 'SomeColumn':
    'Some Column', 'Some_Column'

All tables are 2020
*/

-- ==================================================
-- Create new table schemas, insert data into new table 
-- ==================================================

-- ====================
-- Future50.csv 
-- ====================
/* Columns:
State           -- USGPO (US Government Printing Office)
Sales           -- 2019 Systemwide Sales (in millions USD)
YOYSales        -- YOY Sales Change
Units           -- 2019 US Units (?)
YOYUnits        -- YOY Unit Change
UnitVolume      -- 2019 Average Unit Volume (in thousands USD)
Franchising
*/

CREATE TABLE IF NOT EXISTS Future50 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    City TEXT,
    State TEXT,
    Sales INTEGER,
    YOYSales REAL,
    Units INTEGER,
    YOYUnits REAL,
    UnitVolume INTEGER,
    Franchising INTEGER
);

insert or replace into Future50(
    Rank,
    Restaurant,
    City,
    State,
    Sales,
    YOYSales,
    Units,
    YOYUnits,
    UnitVolume,
    Franchising
)
select
    cast(f.Rank as integer),
    f.Restaurant,
    substr(f.Location, 1, instr(f.Location, ', ') - 1),
    substr(f.Location, instr(f.Location, ', ') + 2),
    cast(f.Sales as integer),                           -- prev. year Systemwide Sales (millions USD)
    cast(replace(f.YOY_Sales, '%', '')/100.0 as real),  -- YOY Sales Change
    cast(f.Units as integer),                           -- prev. year US Units
    cast(replace(f.YOY_Units, '%', '')/100.0 as real),  -- YOY Unit Change
    cast(f.Unit_Volume as integer),                     -- prev. year Average Unit Volume (thousands USD)
    case
        when f.Franchising = 'Yes' then 1
        when f.Franchising = 'No' then 0
        else NULL
    end
from future50_raw f;

/*
select * from Future50;
pragma table_info(future50_raw);
pragma table_info(Future50);
*/

-- ====================
-- Independence100.csv
-- ====================
/* Columns:
Sales       -- Annual Sales
*/

CREATE TABLE IF NOT EXISTS Independent100 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    Sales INTEGER,
    AverageCheck INTEGER,
    City TEXT,
    State TEXT,
    MealsServed INTEGER
);

insert or replace into Independent100 (
    Rank,
    Restaurant,
    Sales,
    AverageCheck,
    City,
    State,
    MealsServed
)
select
    cast(i.Rank as integer),
    i.Restaurant,
    cast(i.Sales as integer),               -- Annual Sales (USD)
    cast(i.[Average Check] as integer),     -- 
    i.City,
    i.State,
    cast(i.[Meals Served] as integer)
from independence100_raw i;

/*
select * from Independent100;
pragma table_info(independence100_raw);
pragma table_info(Independent100);
*/

-- ====================
-- Top250.csv
-- ====================

CREATE TABLE IF NOT EXISTS Top250 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    Content TEXT,
    Sales INTEGER,
    YOYSales REAL,
    Units INTEGER,
    YOYUnits REAL,
    HQCity TEXT,
    HQState TEXT,
    Segment TEXT,
    MenuCategory TEXT
);

insert or replace into Top250 (
    Rank,
    Restaurant,
    Content,
    Sales,
    YOYSales,
    Units,
    YOYUnits,
    HQCity,
    HQState,
    Segment,
    MenuCategory
)
select
    cast(t.Rank as integer) as Rank,
    t.Restaurant,
    case    -- Content
        when t.Content = 'NA' then NULL
        else t.Content
    end as Content,
    cast(t.Sales as integer) as Sales,
    cast(replace(t.YOY_Sales, '%', '')/100.0 as real) as YOYSales,
    cast(t.Units as integer) as Units,
    cast(replace(t.YOY_Units, '%', '')/100.0 as real) as YOYUnits,
    case    -- HQCity
        when instr(t.Headquarters, ', ') = 0 then NULL
        else substr(t.Headquarters, 1, instr(t.Headquarters, ', ') - 1)
    end as HQCity,
    case    -- HQState
        when t.Headquarters = 'NA' then NULL
        else substr(t.Headquarters, instr(t.Headquarters, ', ') + 2)
    end as HQRegion,
    case    -- Segment
        when instr(t.Segment_Category, ' & ') = 0 then NULL
        else substr(t.Segment_Category, 1, instr(t.Segment_Category, ' & ') - 1)
    end as Segment,
    case    -- MenuCategory
        when instr(t.Segment_Category, ' & ') = 0 then t.Segment_Category
        else substr(t.Segment_Category, instr(t.Segment_Category, ' & ') + 3)
    end as MenuCategory
from top250_raw as t;

/*
select * from Top250;
pragma table_info(top250_raw);
pragma table_info(Top250);
*/

/*
select * from Future50;
select * from Independent100;
select * from Top250;
*/