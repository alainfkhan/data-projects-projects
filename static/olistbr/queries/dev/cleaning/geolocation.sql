use olist;

select
    g.geolocation_zip_code_prefix,
    count(distinct g.geolocation_lat) as lat_count,
    count(distinct g.geolocation_lng) as lng_count,
    avg(g.geolocation_lat) as avg_lat,
    avg(g.geolocation_lng) as avg_lng
from olist.logistics.fact_geolocation as g
group by g.geolocation_zip_code_prefix
order by g.geolocation_zip_code_prefix


select
    g.geolocation_zip_code_prefix,
    count(distinct g.geolocation_lat) as lat_count,
    count(distinct g.geolocation_lng) as lng_count,
    avg(g.geolocation_lat) as avg_lat,
    avg(g.geolocation_lng) as avg_lng
from olist_stg.logistics.fact_geolocation as g
group by g.geolocation_zip_code_prefix
order by g.geolocation_zip_code_prefix

-- analysis
select
    g.*
from olist.logistics.fact_geolocation as g
where g.geolocation_zip_code_prefix = '01124'
order by g.geolocation_sk

select
    g.*
from olist_stg.logistics.fact_geolocation as g
where g.geolocation_zip_code_prefix = '01124'
order by g.geolocation_sk
