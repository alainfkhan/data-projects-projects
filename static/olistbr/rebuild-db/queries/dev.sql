USE olist_stg

SELECT * FROM INFORMATION_SCHEMA.tables

SELECT * FROM utils.dim_date;
SELECT * FROM utils.dim_time;
SELECT TOP 1000 * FROM logistics.dim_cep;
SELECT TOP 1000 * FROM staging.dim_cep_iz_B;

DROP TABLE utils.dim_date;
DROP TABLE utils.dim_time;
DROP SCHEMA utils;
-- drop table logistics.dim_cep_iz_AuBmA;
DROP TABLE logistics.dim_cep
DROP TABLE staging.dim_cep_iz_B
-- drop table logistics.dim_cep_iz_B;
-- drop table logistics.dim_cep;

SELECT DATEPART(WEEK, '2016-01-01')

SELECT COUNT(*)
FROM logistics.fact_geolocation

SELECT st.row_count
FROM sys.dm_db_partition_stats AS st
WHERE st.object_id = OBJECT_ID('logistics.fact_geolocation')

SELECT OBJECT_ID('logistics.fact_geolocation')
SELECT OBJECT_NAME(OBJECT_ID('logistics.fact_geolocation'))
