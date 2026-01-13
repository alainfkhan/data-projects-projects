PRAGMA foreign_keys = ON;

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

INSERT OR REPLACE INTO USStates (
    USPS,
    USGPO,
    Name
)
SELECT
    ps.STUSAB,
    gpo.STUSGPOAB,
    ps.STATE_NAME
FROM usps_raw AS ps
LEFT JOIN usgpo_raw AS gpo
    ON ps.STUSAB = gpo.STUSAB;