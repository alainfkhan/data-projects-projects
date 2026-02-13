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

use olist_stg

-- quick view
/*
select top 1000
    g.*
from logistics.dim_geolocation as g
*/

-- list distinct zip code prefixes
select distinct
    g.geolocation_zip_code_prefix
from logistics.dim_geolocation as g
order by g.geolocation_zip_code_prefix

-- find distinct zp
select
    distinct g.geolocation_zip_code_prefix
from logistics.dim_geolocation as g
order by g.geolocation_zip_code_prefix

-- find count of distinct zip code prefixes: 19015
select
    count(distinct g.geolocation_zip_code_prefix)
from logistics.dim_geolocation as g

-- get distinct zp and city
select distinct top 1000
    g.geolocation_zip_code_prefix,
    g.geolocation_city
from logistics.dim_geolocation as g

-- analysis: get states from zipcode starting with:
select distinct
    g.geolocation_state as distinct_states
from logistics.dim_geolocation as g
where g.geolocation_zip_code_prefix like '0%'
order by g.geolocation_state

-- analysis: count 
select
    count(*) as count_state_from_zp
from logistics.dim_geolocation as g
where g.geolocation_zip_code_prefix like '9%'
and g.geolocation_state = 'rs'

-- see table
select 
    g.*
from logistics.dim_geolocation as g
where g.geolocation_zip_code_prefix like '01%'

-- analysis: distinct cities from zp 2 digits
select distinct
    g.geolocation_city
from logistics.dim_geolocation as g
where g.geolocation_zip_code_prefix like '01%'


-- find distinct cities
-- TODO: after cleaning
select distinct
    count(g.geolocation_city)
from logistics.dim_geolocation as g
where g.geolocation_zip_code_prefix like '01%'
and g.geolocation_city in ('sao paulo', 'são paulo')


/*
*/

-- ==================================================
/* 
want to create table distinct
zip_code_prefix, city, state
*/
-- view schema
select *
from INFORMATION_SCHEMA.columns
where table_name = 'dim_geolocation'
-- ==================================================
-- get distinct regional codes, total: 19015
select
    distinct g.geolocation_zip_code_prefix as distinct_base_codes
from logistics.dim_geolocation as g
order by g.geolocation_zip_code_prefix

-- get distinct cities, total: 8010
select
    distinct g.geolocation_city as distinct_cities
from logistics.dim_geolocation as g
order by g.geolocation_city

-- get distinct states, total: 27
select
    distinct g.geolocation_state as distinct_states
from logistics.dim_geolocation as g
order by g.geolocation_state
-- ==================================================

drop table #dist_rc_city_state

-- get distinct (regional codes, cities, states)
select distinct
    g.geolocation_zip_code_prefix as regional_code,
    g.geolocation_city as city,
    g.geolocation_state as [state]
into #dist_rc_city_state
from logistics.dim_geolocation as g

-- query table, total: 27911
select *
from #dist_rc_city_state as d
order by
    d.regional_code asc,
    d.city asc,
    d.state asc

-- change city to ascii
select
    d.*
from #dist_rc_city_state as d
order by 
    d.regional_code asc,
    d.city asc,
    d.state asc


-- 
select *
from tempdb.sys.all_columns
where object_id = (
    select object_id
    from tempdb.sys.tables
    where name like '#tmp_dim_geolocation_canon_ascii%'
)

select
    d.*
    
from #dist_rc_city_state as d
order by
    d.regional_code asc,
    d.city asc,
    d.state asc




