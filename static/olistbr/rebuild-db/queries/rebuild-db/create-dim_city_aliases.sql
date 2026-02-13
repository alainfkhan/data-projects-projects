-- scrap

use olist_stg

drop table core.dim_city_aliases

create table core.dim_city_aliases (
    city_name nvarchar(40),
    city_alias nvarchar(40)
)

insert into core.dim_city_aliases
values
    ('sao paulo', 'são paulo')

select * from core.dim_city_aliases


