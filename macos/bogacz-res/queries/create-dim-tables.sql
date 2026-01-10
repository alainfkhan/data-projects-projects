pragma foreign_keys = ON;

-- ==================================================
-- Create dim tables
-- ==================================================

-- ==========
-- US States
-- ==========
CREATE TABLE IF NOT EXISTS USStates (
    USPS TEXT PRIMARY KEY,
    USGPO TEXT,
    Name TEXT
);

insert or replace into USStates (
    USPS,
    USGPO,
    Name
)
select
    ps.STUSAB,
    gpo.STUSGPOAB,
    ps.STATE_NAME
from usps_raw ps
left join usgpo_raw gpo
    on ps.STUSAB = gpo.STUSAB;


-- ====================
-- Canadian Regions 
-- ====================
/*
ID integer primary key,
PoT text,
Abbr text,
*/