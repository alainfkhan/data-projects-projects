/*
Create proper tables of imported data.

The Rank column of all tables are unique
Assume all column datatypes are consistent
Convert column names to 'SomeColumn':
    'Some Column', 'Some_Column'

All tables are from the 2020 data
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
Units           -- 2019 US Units
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

INSERT OR REPLACE INTO Future50 (
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
SELECT
    CAST(f.Rank AS INTEGER),
    f.Restaurant,
    SUBSTR(f.Location, 1, INSTR(f.Location, ', ') - 1),
    SUBSTR(f.Location, INSTR(f.Location, ', ') + 2),
    CAST(f.Sales AS INTEGER),                           -- prev. year Systemwide Sales (millions USD)
    CAST(REPLACE(f.YOY_Sales, '%', '') / 100.0 AS REAL),  -- YOY Sales Change
    CAST(f.Units AS INTEGER),                           -- prev. year US Units
    CAST(REPLACE(f.YOY_Units, '%', '') / 100.0 AS REAL),  -- YOY Unit Change
    CAST(f.Unit_Volume AS INTEGER),                     -- prev. year Average Unit Volume (thousands USD)
    CASE
        WHEN f.Franchising = 'Yes' THEN 1
        WHEN f.Franchising = 'No' THEN 0
        ELSE NULL
    END
FROM future50_raw f;

/*
Single errors
select * from Future50 where State like ' %';
select * from Future50 where Rank in (6, 9);
*/

UPDATE Future50
SET State = 'N.J.'
WHERE Rank = 6;

UPDATE Future50
SET State = 'Calif.'
WHERE Rank = 9;

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

INSERT OR REPLACE INTO Independent100 (
    Rank,
    Restaurant,
    Sales,
    AverageCheck,
    City,
    State,
    MealsServed
)
SELECT
    CAST(i.Rank AS INTEGER),
    i.Restaurant,
    CAST(i.Sales AS INTEGER),
    CAST(i."Average Check" AS INTEGER),
    i.City,
    i.State,
    CAST(i."Meals Served" AS INTEGER)
FROM independence100_raw i;

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

INSERT OR REPLACE INTO Top250 (
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
SELECT
    CAST(t.Rank AS INTEGER) AS Rank,
    t.Restaurant,
    CASE    -- Content
        WHEN t.Content = 'NA' THEN NULL
        ELSE t.Content
    END AS Content,
    CAST(t.Sales AS INTEGER) AS Sales,
    CAST(REPLACE(t.YOY_Sales, '%', '') / 100.0 AS REAL) AS YOYSales,
    CAST(t.Units AS INTEGER) AS Units,
    CAST(REPLACE(t.YOY_Units, '%', '') / 100.0 AS REAL) AS YOYUnits,
    CASE    -- HQCity
        WHEN INSTR(t.Headquarters, ', ') = 0 THEN NULL
        ELSE SUBSTR(t.Headquarters, 1, INSTR(t.Headquarters, ', ') - 1)
    END AS HQCity,
    CASE    -- HQState
        WHEN t.Headquarters = 'NA' THEN NULL
        ELSE SUBSTR(t.Headquarters, INSTR(t.Headquarters, ', ') + 2)
    END AS HQRegion,
    CASE    -- Segment
        WHEN INSTR(t.Segment_Category, ' & ') = 0 THEN NULL
        ELSE SUBSTR(t.Segment_Category, 1, INSTR(t.Segment_Category, ' & ') - 1)
    END AS Segment,
    CASE    -- MenuCategory
        WHEN INSTR(t.Segment_Category, ' & ') = 0 THEN t.Segment_Category
        ELSE SUBSTR(t.Segment_Category, INSTR(t.Segment_Category, ' & ') + 3)
    END AS MenuCategory
FROM top250_raw AS t;

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
