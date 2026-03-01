/*
analyse zipcodes

definitions:
zp = zipcode prefix
zipcode prefix = base/ regional code

we know:
brazil zipcode is filtered
brazil zipcode prefix looks like: nnnnn
annnn > abnnn
zp annnn contains zp abnnn
*/

USE olist_stg

-- quick view
/*
select top 1000
    g.*
from logistics.dim_geolocation as g
*/

-- list distinct zip code prefixes
SELECT DISTINCT g.geolocation_zip_code_prefix
FROM logistics.dim_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix

-- find distinct zp
SELECT DISTINCT g.geolocation_zip_code_prefix
FROM logistics.dim_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix

-- find count of distinct zip code prefixes: 19015
SELECT COUNT(DISTINCT g.geolocation_zip_code_prefix)
FROM logistics.dim_geolocation AS g

-- get distinct zp and city
SELECT DISTINCT TOP 1000
    g.geolocation_zip_code_prefix,
    g.geolocation_city
FROM logistics.dim_geolocation AS g

-- analysis: get states from zipcode starting with:
SELECT DISTINCT g.geolocation_state AS distinct_states
FROM logistics.dim_geolocation AS g
WHERE g.geolocation_zip_code_prefix LIKE '0%'
ORDER BY g.geolocation_state

-- analysis: count 
SELECT COUNT(*) AS count_state_from_zp
FROM logistics.dim_geolocation AS g
WHERE g.geolocation_zip_code_prefix LIKE '9%'
AND g.geolocation_state = 'rs'

-- see table
SELECT g.*
FROM logistics.dim_geolocation AS g
WHERE g.geolocation_zip_code_prefix LIKE '01%'

-- analysis: distinct cities from zp 2 digits
SELECT DISTINCT g.geolocation_city
FROM logistics.dim_geolocation AS g
WHERE g.geolocation_zip_code_prefix LIKE '01%'


-- find distinct cities
-- TODO: after cleaning
SELECT DISTINCT COUNT(g.geolocation_city)
FROM logistics.dim_geolocation AS g
WHERE g.geolocation_zip_code_prefix LIKE '01%'
AND g.geolocation_city IN ('sao paulo', 'são paulo')


/*
*/

-- ==================================================
/*
want to create table distinct
zip_code_prefix, city, state
*/
-- view schema
SELECT *
FROM INFORMATION_SCHEMA.columns
WHERE table_name = 'dim_geolocation'
-- ==================================================
-- get distinct regional codes, total: 19015
SELECT DISTINCT g.geolocation_zip_code_prefix AS distinct_base_codes
FROM logistics.dim_geolocation AS g
ORDER BY g.geolocation_zip_code_prefix

-- get distinct cities, total: 8010
SELECT DISTINCT g.geolocation_city AS distinct_cities
FROM logistics.dim_geolocation AS g
ORDER BY g.geolocation_city

-- get distinct states, total: 27
SELECT DISTINCT g.geolocation_state AS distinct_states
FROM logistics.dim_geolocation AS g
ORDER BY g.geolocation_state
-- ==================================================

DROP TABLE #dist_rc_city_state

-- get distinct (regional codes, cities, states)
SELECT DISTINCT
    g.geolocation_zip_code_prefix AS regional_code,
    g.geolocation_city AS city,
    g.geolocation_state AS [state]
INTO #dist_rc_city_state
FROM logistics.dim_geolocation AS g

-- query table, total: 27911
SELECT *
FROM #dist_rc_city_state AS d
ORDER BY
    d.regional_code ASC,
    d.city ASC,
    d.state ASC

-- change city to ascii
SELECT d.*
FROM #dist_rc_city_state AS d
ORDER BY
    d.regional_code ASC,
    d.city ASC,
    d.state ASC


-- 
SELECT *
FROM tempdb.sys.all_columns
WHERE object_id = (
    SELECT object_id
    FROM tempdb.sys.tables
    WHERE name LIKE '#tmp_dim_geolocation_canon_ascii%'
)

SELECT d.*

FROM #dist_rc_city_state AS d
ORDER BY
    d.regional_code ASC,
    d.city ASC,
    d.state ASC
