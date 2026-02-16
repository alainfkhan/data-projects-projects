use olist_stg

select * from core.dim_date;
select top 1000 * from logistics.dim_cep_iz_AuBmA;
select top 1000 * from logistics.dim_cep_iz_B;

drop table core.dim_date;
drop schema core;
drop table logistics.dim_cep_iz_AuBmA;
drop table logistics.dim_cep_iz_B;


