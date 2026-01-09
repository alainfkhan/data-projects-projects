/*
Columns
Future50.csv: "Rank","Restaurant","Location","Sales","YOY_Sales","Units","YOY_Units","Unit_Volume","Franchising"
Independence100.csv: "Rank","Restaurant","Sales","Average Check","City","State","Meals Served"
Top250.csv: "Rank","Restaurant","Content","Sales","YOY_Sales","Units","YOY_Units","Headquarters","Segment_Category"
*/

/*
The Rank column of all tables are unique, they could be used as primary keys
Assume all column datatypes are consistent
Convert column names: 'Some Column' to 'SomeColumn'
*/

-- ==================================================
-- Create table schemas and insert into new table 
-- ==================================================

-- Future50.csv

CREATE TABLE IF NOT EXISTS Future50 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    Location TEXT,
    Sales INTEGER,
    YOYSales REAL,              -- '130.5%' to 1.305
    Units INTEGER,
    YOYUnits REAL,
    UnitVolume INTEGER,
    Franchising INTEGER         -- 'No' to 0, 'Yes' to 1
);

insert or replace into Future50 (Rank, Restaurant, Location, Sales, YOYSales, Units, YOYUnits, UnitVolume, Franchising)
select
    cast(f.Rank as integer),
    f.Restaurant,
    f.Location,
    cast(f.Sales as integer),
    cast(replace(f.YOY_Sales, '%', '')/100.0 as real),
    cast(f.Units as integer),
    cast(replace(f.YOY_Units, '%', '')/100.0 as real),
    cast(f.Unit_Volume as integer),
    case
        when f.Franchising = 'Yes' then 1
        when f.Franchising = 'No' then 0
        else NULL
    end
from future50_raw f;

/*
pragma table_info(future50_raw);
pragma table_info(Future50);
*/

-- Independence100.csv

CREATE TABLE IF NOT EXISTS Independent100 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    Sales INTEGER,
    AverageCheck INTEGER,
    City TEXT,
    State TEXT,
    MealsServed INTEGER
);

insert or replace into Independent100 (Rank, Restaurant, Sales, AverageCheck, City, State, MealsServed)
select
    cast(i.Rank as integer),
    i.Restaurant,
    cast(i.Sales as integer),
    cast(i.[Average Check] as integer),
    i.City,
    i.State,
    cast(i.[Meals Served] as integer)
from independence100_raw i;

/*
pragma table_info(independence100_raw);
pragma table_info(Independent100);
*/

-- Top250.csv

CREATE TABLE IF NOT EXISTS Top250 (
    Rank INTEGER PRIMARY KEY,
    Restaurant TEXT,
    Content TEXT,
    Sales INTEGER,
    YOYSales REAL,
    Units INTEGER,
    YOYUnits REAL,
    Headquarters TEXT,
    SegmentCategory TEXT
)

insert or replace into Top250 (Rank, Restaurant, Content, Sales, YOYSales, Units, YOYUnits, Headquarters, SegmentCategory)
select
    cast(t.Rank as integer),
    t.Restaurant,
    case
        when t.Content = 'NA' then NULL
        else t.Content
    end,
    cast(t.Sales as integer),
    cast(replace(t.YOY_Sales, '%', '')/100.0 as real),
    cast(t.Units as integer),
    cast(replace(t.YOY_Units, '%', '')/100.0 as real),
    case
        when t.Headquarters = 'NA' then NULL
        else t.Headquarters
    end,
    t.Segment_Category
from top250_raw as t;

/*
pragma table_info(top250_raw);
pragma table_info(Top250);
*/

/*
select * from Future50;
select * from Independent100;
select * from Top250;
*/