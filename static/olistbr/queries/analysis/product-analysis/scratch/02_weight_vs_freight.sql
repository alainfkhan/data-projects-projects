use olist_stg;

-- does weight affect freight
-- ie. does weight cause freight
-- correlation !=> causation

go;

with cov_part_values as (
    select distinct
        pt.product_category_name_english,
        -- p.product_weight_g,
        -- oi.freight_value
        count(*) as n,
        sum(1.0 * p.product_weight_g) as sum_x,
        sum(square(1.0 * p.product_weight_g)) as sum_sq_x,
        sum(1.0 * oi.freight_value) as sum_y,
        sum(square(1.0 * oi.freight_value)) as sum_sq_y,
        sum(1.0 * p.product_weight_g * oi.freight_value) as sum_xy
    from sales.fact_orders as o
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    left join sales.dim_products as p
        on oi.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    where
        pt.product_category_name_english is not null
        and p.product_weight_g is not null
        and oi.freight_value is not null
    group by
        pt.product_category_name_english
)

select
    -- c.*,
    c.product_category_name_english,
    c.n,
    (c.n * c.sum_xy - sum_x * sum_y)
    / nullif((sqrt(c.n * c.sum_sq_x - square(sum_x)) * sqrt(c.n * c.sum_sq_y - square(sum_y))), 0) as corr_weight_freight
into #corr_weight_freight
from cov_part_values as c
order by corr_weight_freight desc

go;

drop table #corr_weight_freight

select
    c.*
from #corr_weight_freight as c

/*
product_category_name_english, n, corr_weight_freight
security_and_services, 2, 0.9999999999999996
arts_and_craftmanship, 24, 0.8280962503655963
fashion_sport, 30, 0.7748094224432427
la_cuisine, 14, 0.7743581296550879
market_place, 311, 0.7208589101151077
small_appliances_home_oven_and_coffee, 76, 0.7095594159903362
small_appliances, 679, 0.7010162923282609
construction_tools_lights, 304, 0.6993337682135085
health_beauty, 9670, 0.696506374281815
furniture_living_room, 503, 0.6959616992931418
agro_industry_and_commerce, 212, 0.6822100050805389
*/

select
    pt.product_category_name_english,
    p.product_weight_g,
    oi.freight_value
from sales.fact_orders as o
left join sales.fact_order_items as oi
    on o.order_id = oi.order_id
left join sales.dim_products as p
    on oi.product_id = p.product_id
left join sales.dim_product_category_name_translation as pt
    on p.product_category_name = pt.product_category_name
where pt.product_category_name_english = 'arts_and_craftmanship'
order by
    p.product_weight_g,
    oi.freight_value