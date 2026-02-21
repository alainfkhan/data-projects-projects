/*
revenue by product category
*/
use olist_stg;

select * from INFORMATION_SCHEMA.tables

-- list tables to be used
select
    o.*
from sales.fact_orders as o

select
    oi.*
from sales.fact_order_items as oi

select
    p.*
from sales.dim_products as p

select
    pt.*
from sales.dim_product_category_name_translation as pt

-- start
select
    d.*,
    sub.*
into #order_category_revenue
from (
    select
        -- o.*,
        -- oi.*,
        -- p.*,
        -- pt.*
        o.order_id,
        o.order_approved_at,
        cast(o.order_approved_at as date) as order_purchase_date,
        pt.product_category_name_english,
        oi.price,
        oi.freight_value
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    left join sales.dim_products as p
        on oi.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    where o.order_status in (
            'approved',
            'delivered',
            'invoiced',
            'processing',
            'shipped'
        )
        and oi.price is not null
) as sub
right join utils.dim_date as d
    on sub.order_purchase_date = d.full_date
order by d.full_date asc, sub.product_category_name_english

/*
drop table #order_category_revenue
*/

select * from #order_category_revenue


-- year
select
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    group by c.year_number, c.product_category_name_english
) as sub
order by sub.year_number, sub.product_category_name_english


-- quarter
select
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.quarter_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    group by c.year_number, c.quarter_number, c.product_category_name_english
) as sub
order by sub.year_number, sub.quarter_number, sub.product_category_name_english


-- month
select
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.month_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    group by c.year_number, c.month_number, c.product_category_name_english
) as sub
order by sub.year_number, sub.month_number, sub.product_category_name_english


-- week
select
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.week_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    group by c.year_number, c.week_number, c.product_category_name_english
) as sub
order by sub.year_number, sub.week_number, sub.product_category_name_english


-- day
select
    sub.*,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.day_of_year,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    group by c.year_number, c.day_of_year, c.product_category_name_english
) as sub
order by sub.year_number, sub.day_of_year, sub.product_category_name_english


-- ==================================================
-- special interest: 'health_beauty'
-- can work with no filter,
-- evolution of previous query, includes non orders on all dates
-- ==================================================

declare @category varchar(30)= 'health_beauty'


-- quarter
select
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.quarter_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    where c.product_category_name_english = 'health_beauty'
    group by c.year_number, c.quarter_number, c.product_category_name_english
) as sub
right join (
    select
        -- d.*
        d.year_number,
        d.quarter_number
    from utils.dim_date as d
    group by d.year_number, d.quarter_number
    -- order by d.year_number, d.quarter_number
) as d
    on sub.year_number = d.year_number
    and sub.quarter_number = d.quarter_number
-- where sub.product_category_name_english = 'health_beauty'
order by d.year_number, d.quarter_number, sub.product_category_name_english


-- filter case, month
-- messy, includes null category
select
    -- c.*,
    d.*,
    -- c.year_number,
    -- c.quarter_number,
    c.product_category_name_english,
    count(distinct c.order_id) as order_count,
    sum(c.price) as total_product_revenue,
    sum(c.freight_value) as total_freight_revenue
from #order_category_revenue as c
right join (
    select
        d.year_number,
        d.month_number,
        d.month_name
    from utils.dim_date as d
    group by d.year_number, d.month_number, d.month_name
) as d
    on c.year_number = d.year_number
    and c.month_number = d.month_number
where c.product_category_name_english = 'health_beauty'
    or c.product_category_name_english is null
group by d.year_number, d.month_number, d.month_name, c.product_category_name_english
order by d.year_number, d.month_number, d.month_name, c.product_category_name_english


-- filter case, month repeat of quarter query
-- good
select
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.month_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    where c.product_category_name_english = 'health_beauty'
    group by c.year_number, c.month_number, c.product_category_name_english
) as sub
right join (
    select
        -- d.*
        d.year_number,
        d.month_number
    from utils.dim_date as d
    group by d.year_number, d.month_number
    -- order by d.year_number, d.month_number
) as d
    on sub.year_number = d.year_number
    and sub.month_number = d.month_number
-- where sub.product_category_name_english = 'health_beauty'
order by d.year_number, d.month_number, sub.product_category_name_english


-- week
select
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.week_number,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    where c.product_category_name_english = 'health_beauty'
    group by c.year_number, c.week_number, c.product_category_name_english
) as sub
right join (
    select
        -- d.*
        d.year_number,
        d.week_number
    from utils.dim_date as d
    group by d.year_number, d.week_number
    -- order by d.year_number, d.week_number
) as d
    on sub.year_number = d.year_number
    and sub.week_number = d.week_number
-- where sub.product_category_name_english = 'health_beauty'
order by d.year_number, d.week_number, sub.product_category_name_english


-- day
select
    d.*,
    sub.product_category_name_english,
    sub.order_count,
    sub.total_product_revenue,
    sub.total_product_revenue + sub.total_freight_revenue as total_revenue,
    sub.total_product_revenue / sub.order_count as aov,
    sub.total_freight_revenue / sub.order_count as avg_shipping_income,
    sub.total_freight_revenue
    / sub.total_product_revenue AS freight_to_product_ratio
from (
    select
        -- c.*,
        -- c.full_date,
        c.year_number,
        c.day_of_year,
        c.product_category_name_english,
        count(distinct c.order_id) as order_count,
        sum(c.price) as total_product_revenue,
        sum(c.freight_value) as total_freight_revenue
    from #order_category_revenue as c
    where c.product_category_name_english = 'health_beauty'
    group by c.year_number, c.day_of_year, c.product_category_name_english
) as sub
right join (
    select
        -- d.*
        d.year_number,
        d.day_of_year
    from utils.dim_date as d
    group by d.year_number, d.day_of_year
    -- order by d.year_number, d.day_of_year
) as d
    on sub.year_number = d.year_number
    and sub.day_of_year = d.day_of_year
-- where sub.product_category_name_english = 'health_beauty'
order by d.year_number, d.day_of_year, sub.product_category_name_english