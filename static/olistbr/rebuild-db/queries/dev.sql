use olist_stg

select * from core.dim_date;
select top 1000 * from logistics.dim_cep_iz_AuBmA;
select top 1000 * from logistics.dim_cep_iz_B;

drop table core.dim_date;
drop schema core;
drop table logistics.dim_cep_iz_AuBmA;
drop table logistics.dim_cep_iz_B;

select
    count(*)
from logistics.fact_geolocation

select
    st.row_count
from sys.dm_db_partition_stats as st
where st.object_id = object_id('logistics.fact_geolocation')

select object_id('logistics.fact_geolocation')
select object_name(object_id('logistics.fact_geolocation'))