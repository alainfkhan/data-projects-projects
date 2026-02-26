use olist_stg;

-- ==================================================
-- total revenues (per state) of orders made by users who have ordered before
-- ==================================================

with user_recent_orders as (
    -- the most recent order of each user
    select
        o.order_purchase_timestamp,
        cast(o.order_purchase_timestamp as date) as order_purchase_date,
        o.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        row_number() over (
            partition by c.customer_unique_id
            order by
                o.order_purchase_timestamp desc
        ) as rn
    from sales.fact_orders as o
    left join sales.dim_customers as c
        on o.customer_id = c.customer_id
),

user_last_orders as (
    -- the last order of each user (total rows = 96096)
    select
        ro.*
    from user_recent_orders as ro
    where ro.rn = 1
),

user_not_last_orders as (
    -- the orders that aren't the last
    -- can imply get users who have ordered before
    select
        ro.*
    from user_recent_orders as ro
    where ro.rn > 1
)
-- select ro.*
-- from user_not_last_orders as ro
-- select lo.*
-- from user_last_orders as lo

select
    s.year_number,
    s.month_number,
    ufs.uf,
    count(distinct s.order_id) as order_count,
    sum(s.price) as total_product_revenue,
    sum(s.freight_value) as total_freight_revenue,
    sum(s.price + s.freight_value) as total_revenue
from sales.vw_sales as s
left join sales.dim_customers as c
    on s.customer_id = c.customer_id
left join (
    -- all ufs
    select
        distinct left(cep.uf, 2) as uf
    from logistics.dim_cep as cep
) as ufs
    on c.customer_state = ufs.uf
where c.customer_unique_id in (
    -- users who have ordered before
    select distinct nlo.customer_unique_id
    from user_not_last_orders as nlo
)
group by
    s.year_number,
    s.month_number,
    ufs.uf
order by
    s.year_number,
    s.month_number,
    ufs.uf

-- ==================================================

-- explanation
/*
total revenues (per state) of orders made by users who have ordered before

there is one order where it isnt categorised in a defined date
*/

select
    oi.*,
    o.*,
    c.*
from sales.fact_order_items as oi
left join sales.fact_orders as o
    on oi.order_id = o.order_id
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
where oi.price = '149.8000'
and oi.freight_value = '13.6300'

/*
order_id, order_purchase_timestamp, order_approved_at
7f13a20e25350f4a55fb2a7c9a2e8d88 2017-03-13 18:14:37.0000000	2017-03-13 18:14:37.0000000
d69e5d356402adc8cf17e08b5033acfb 2017-02-19 01:28:47.0000000	NULL

customer_unique_id
51838d41add414a0b1b989b7d251d9ee
2e0a2166aa23da2472c6a60c4af6f7a6

product_id
cae2e38942c8489d9d7a87a3f525c06b

seller_id
cca3071e3e9bb7d12640c9fbe2301306
*/

select
    o.*,
    oi.*,
    c.*
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
where c.customer_unique_id in (
    '51838d41add414a0b1b989b7d251d9ee',
    '2e0a2166aa23da2472c6a60c4af6f7a6'
)

-- find product
select
    p.*,
    pt.*
from sales.dim_products as p
left join sales.dim_product_category_name_translation as pt
    on p.product_category_name = pt.product_category_name
where p.product_id = 'cae2e38942c8489d9d7a87a3f525c06b'

-- find seller
select
    s.*
from sales.dim_sellers as s
where s.seller_id = 'cca3071e3e9bb7d12640c9fbe2301306'


select
    o.*
from sales.fact_orders as o
where cast(o.order_purchase_timestamp as date) = '2017-02-19'
order by o.order_purchase_timestamp

select
    o.*
from sales.fact_orders as o
where o.order_approved_at is null


-- scratch

with cte as (
    select
        -- o.*,
        -- oi.*
        o.order_purchase_timestamp,
        cast(o.order_purchase_timestamp as date) as order_purchase_date,
        o.order_approved_at,
        cast(order_approved_at as date) as order_approved_date,
        case when (cast(o.order_purchase_timestamp as date) = cast(o.order_approved_at as date))
            then 1
            else 0
        end as is_same_date
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
),

purchased_dates as (
    select
        distinct cte.order_purchase_date
    from cte
),

approved_dates as (
    select
        distinct cte.order_approved_date
    from cte
)

select
    d.full_date,
    pd.*,
    ad.*
from utils.dim_date as d
left join purchased_dates as pd
    on d.key_date = pd.order_purchase_date
left join approved_dates as ad
    on d.key_date = ad.order_approved_date
order by d.full_date


/*
a repeat user is someone who has made more than one order
*/
-- first attempt
go;
-- ==================================================

with relu as (
    -- relocated users
    select
        -- c.*
        distinct c.customer_unique_id as relocated_users
    from (
        select
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state,
            row_number() over (
                partition by c.customer_unique_id
                order by
                    c.customer_unique_id,
                    c.customer_zip_code_prefix,
                    c.customer_city,
                    c.customer_state
            ) as rn
        from sales.dim_customers as c
        group by
            c.customer_unique_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state
    ) as c
    where c.rn > 1
    -- order by relocated_users
    -- order by
    --     c.customer_unique_id,
    --     c.customer_zip_code_prefix,
    --     c.customer_city,
    --     c.customer_state
)

select
    o.order_purchase_timestamp,
    o.customer_id,
    relu.relocated_users,
    row_number() over (
        partition by relu.relocated_users
        order by o.order_purchase_timestamp desc
    ) as rn
from sales.fact_orders as o
left join sales.dim_customers as c
    on o.customer_id = c.customer_id
right join relu
    on c.customer_unique_id = relu.relocated_users

-- ...

go;
-- ==================================================






-- this user has had 3 relocations
-- d44ccec15f5f86d14d6a2cfa67da1975
select
    c.*
from sales.dim_customers as c
where c.customer_unique_id = '83e7958a94bd7f74a9414d8782f87628'
