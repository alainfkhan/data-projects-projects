/*
revenue by state
    for customers
    for sellers

definitions:
sale if
    order_status:
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    price not null

accounting sale made at order_approved_at
    

*/
use olist_stg;

-- list tables
select
    o.*
from sales.fact_orders as o

select
    oi.*
from sales.fact_order_items as oi

select
    c.*
from sales.dim_customers as c

select
    s.*
from sales.dim_sellers as s

select top 1000
    g.*
from logistics.fact_geolocation as g

select top 1000
    cep.*
from logistics.dim_cep as cep

-- joins
select
    -- o.*,
    -- c.*,
    -- oi.*,
    -- s.*,
    d.*,
    o.order_id,
    o.order_approved_at,
    cast(o.order_approved_at as date) as order_approved_date,
    oi.price,
    oi.freight_value,
    c.customer_state,
    s.seller_state
into #orders_cs_state   -- cs means customer seller
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
left join sales.dim_sellers as s
    on oi.seller_id = s.seller_id
right join utils.dim_date as d
    on cast(o.order_approved_at as date) = d.full_date
where o.order_status in (
    'approved',
    'delivered',
    'invoiced',
    'processing',
    'shipped')
    and oi.price is not null
order by o.order_approved_at

drop table #orders_cs_state

select
    o.*
from #orders_cs_state as o
order by o.order_approved_at

-- start
-- whole dataset
-- customer
select
    o.customer_state,
    count(distinct o.order_id) as order_count,
    sum(o.price) as total_product_revenue,
    sum(o.freight_value) as total_freight_revenue
from #orders_cs_state as o
group by o.customer_state
order by o.customer_state

-- seller
select
    o.seller_state,
    count(distinct o.order_id) as order_count,
    sum(o.price) as total_product_revenue,
    sum(o.freight_value) as total_freight_revenue
from #orders_cs_state as o
group by o.seller_state
order by o.seller_state

-- all together
select
    -- cep.*,
    -- c.*,
    -- s.*
    cep.br_state,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv
from (
    select distinct
        left(cep.uf, 2) as br_state
    from logistics.dim_cep as cep
) as cep
left join (
    select
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv 
    from #orders_cs_state as o
    group by o.customer_state
    ) as c
    on cep.br_state = c.customer_state
left join (
    select
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv 
    from #orders_cs_state as o
    group by o.seller_state
    ) as s
    on cep.br_state = s.seller_state
order by cep.br_state

-- ==================================================
-- revenue by state by time
-- ==================================================

-- year
select 
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
from (
    select distinct
        d.year_number,
        cep.br_state
    from utils.dim_date as d
    cross join (
        select distinct
            left(cep.uf, 2) as br_state
        from logistics.dim_cep as cep
        ) as cep
    group by d.year_number, cep.br_state
) as sub
left join (
    select
        o.year_number,
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.customer_state
    ) as c
    on sub.year_number = c.year_number
        and sub.br_state = c.customer_state
left join (
    select
        o.year_number,
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.seller_state
    ) as s
    on sub.year_number = s.year_number
        and sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
order by sub.year_number, sub.br_state

-- quarter
select 
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
from (
    select distinct
        d.year_number,
        d.quarter_number,
        cep.br_state
    from utils.dim_date as d
    cross join (
        select distinct
            left(cep.uf, 2) as br_state
        from logistics.dim_cep as cep
        ) as cep
    group by d.year_number, d.quarter_number, cep.br_state
) as sub
left join (
    select
        o.year_number,
        o.quarter_number,
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.quarter_number, o.customer_state
    ) as c
    on sub.year_number = c.year_number
        and sub.quarter_number = c.quarter_number
        and sub.br_state = c.customer_state
left join (
    select
        o.year_number,
        o.quarter_number,
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.quarter_number, o.seller_state
    ) as s
    on sub.year_number = s.year_number
        and sub.quarter_number = s.quarter_number
        and sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
order by sub.year_number, sub.quarter_number, sub.br_state


-- month
select 
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
from (
    select distinct
        d.year_number,
        d.month_number,
        cep.br_state
    from utils.dim_date as d
    cross join (
        select distinct
            left(cep.uf, 2) as br_state
        from logistics.dim_cep as cep
        ) as cep
    group by d.year_number, d.month_number, cep.br_state
) as sub
left join (
    select
        o.year_number,
        o.month_number,
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.month_number, o.customer_state
    ) as c
    on sub.year_number = c.year_number
        and sub.month_number = c.month_number
        and sub.br_state = c.customer_state
left join (
    select
        o.year_number,
        o.month_number,
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.month_number, o.seller_state
    ) as s
    on sub.year_number = s.year_number
        and sub.month_number = s.month_number
        and sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
order by sub.year_number, sub.month_number, sub.br_state

-- week
select 
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
from (
    select distinct
        d.year_number,
        d.week_number,
        cep.br_state
    from utils.dim_date as d
    cross join (
        select distinct
            left(cep.uf, 2) as br_state
        from logistics.dim_cep as cep
        ) as cep
    group by d.year_number, d.week_number, cep.br_state
) as sub
left join (
    select
        o.year_number,
        o.week_number,
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.week_number, o.customer_state
    ) as c
    on sub.year_number = c.year_number
        and sub.week_number = c.week_number
        and sub.br_state = c.customer_state
left join (
    select
        o.year_number,
        o.week_number,
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.week_number, o.seller_state
    ) as s
    on sub.year_number = s.year_number
        and sub.week_number = s.week_number
        and sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
order by sub.year_number, sub.week_number, sub.br_state

-- day
select 
    sub.*,
    c.customer_order_count,
    c.customer_product_gmv,
    c.customer_freight_gmv,
    s.seller_order_count,
    s.seller_product_gmv,
    s.seller_freight_gmv
from (
    select distinct
        d.year_number,
        d.day_of_year,
        cep.br_state
    from utils.dim_date as d
    cross join (
        select distinct
            left(cep.uf, 2) as br_state
        from logistics.dim_cep as cep
        ) as cep
    group by d.year_number, d.day_of_year, cep.br_state
) as sub
left join (
    select
        o.year_number,
        o.day_of_year,
        o.customer_state,
        count(distinct o.order_id) as customer_order_count,
        sum(o.price) as customer_product_gmv,
        sum(o.freight_value) as customer_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.day_of_year, o.customer_state
    ) as c
    on sub.year_number = c.year_number
        and sub.day_of_year = c.day_of_year
        and sub.br_state = c.customer_state
left join (
    select
        o.year_number,
        o.day_of_year,
        o.seller_state,
        count(distinct o.order_id) as seller_order_count,
        sum(o.price) as seller_product_gmv,
        sum(o.freight_value) as seller_freight_gmv
    from #orders_cs_state as o
    group by o.year_number, o.day_of_year, o.seller_state
    ) as s
    on sub.year_number = s.year_number
        and sub.day_of_year = s.day_of_year
        and sub.br_state = s.seller_state
-- where sub.br_state = 'SP'
order by sub.year_number, sub.day_of_year, sub.br_state













