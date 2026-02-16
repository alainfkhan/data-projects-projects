use olist_stg

select 
    *
from INFORMATION_SCHEMA.tables
where TABLE_SCHEMA = 'logistics'

-- define the main cep as
if (object_id('logistics.dim_cep_iz_AuBmA')) is not null
    begin
        exec sp_rename 'logistics.dim_cep_AuBmA', 'logistics.dim_cep';
    end

-- last minute cleaning
select
    top 1000
    *
from logistics.dim_cep_iz_B as c

select
    -- top 1000
    c.*
from logistics.dim_cep_iz_AuBmA as c
where c.bairro is null


