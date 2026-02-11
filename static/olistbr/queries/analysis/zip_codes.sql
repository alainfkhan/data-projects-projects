/*
analyse zipcodes

definitions:
zp = zipcode prefix

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

-- find count of distinct zip code prefixes: 1000163
select distinct
    count(g.geolocation_zip_code_prefix)
from logistics.dim_geolocation as g


-- count rows in table 1000163
select
    count(g.geolocation_sk)
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

