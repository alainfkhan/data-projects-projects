use olist_stg

select * from INFORMATION_SCHEMA.tables

select * from utils.dim_date;
select * from utils.dim_time;
select top 1000 * from logistics.dim_cep;
select top 1000 * from staging.dim_cep_iz_B;

drop table utils.dim_date;
drop table utils.dim_time;
drop schema utils;
-- drop table logistics.dim_cep_iz_AuBmA;
drop table logistics.dim_cep
drop table staging.dim_cep_iz_B
-- drop table logistics.dim_cep_iz_B;
-- drop table logistics.dim_cep;

select datepart(week, '2016-01-01')

select
    count(*)
from logistics.fact_geolocation

select
    st.row_count
from sys.dm_db_partition_stats as st
where st.object_id = object_id('logistics.fact_geolocation')

select object_id('logistics.fact_geolocation')
select object_name(object_id('logistics.fact_geolocation'))
