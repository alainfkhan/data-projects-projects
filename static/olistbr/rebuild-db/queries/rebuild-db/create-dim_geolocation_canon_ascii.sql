-- scrap

use olist_stg

select *
from INFORMATION_SCHEMA.columns
where table_schema = 'logistics'

-- drop staging table
drop table #tmp_dim_geolocation_canon_ascii

-- create staging table a copy
select
    g.*
into #tmp_dim_geolocation_canon_ascii
from logistics.dim_geolocation as g

-- view table
select top 1000
    *
from #tmp_dim_geolocation_canon_ascii
order by geolocation_sk



-- clean staging table
-- cp1251 cyrillic
-- cp1252 western 
select distinct
    sub.state,
    sub.city_ascii
from (
    select distinct
        t.geolocation_zip_code_prefix as regional_code,
        cast(t.geolocation_city as varchar(40)) collate sql_latin1_general_cp1251_ci_as as city_ascii,
        t.geolocation_state as [state]
    from #tmp_dim_geolocation_canon_ascii as t
) as sub
order by
    sub.state asc,
    sub.city_ascii asc











-- create cleaned table 
create table logistics.dim_geolocation_canon_ascii (
    geolocation_sk int identity(1,1),
    geolocation_zip_code_prefix char(5),
    geolocation_lat decimal(9, 6),
    geolocation_lng decimal(9, 6),
    geolocation_city varchar(40),
    geolocation_state char(2),
    
    constraint pk_geolocation_sk
        primary key (geolocation_sk)
)
