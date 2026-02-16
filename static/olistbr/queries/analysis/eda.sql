use olist_stg;

-- complemento had converter type str meaning any nulls = ''
-- need to change all '' to null
select
    *
from logistics.dim_cep_iz_AuBmA as c
where c.COMPLEMENTO != '';

select top 1000
    c.*
from logistics.dim_cep_iz_AuBmA as c
where c.CEP like '89600%';

select top 1
    g.*
from logistics.fact_geolocation as g
order by newid()