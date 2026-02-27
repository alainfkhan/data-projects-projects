use olist_stg;

-- do longer product descriptions correlate with higher sales?
-- no

with cte as (
    select distinct
        p.product_description_lenght as x,
        -- sum(s.price) as total_product_revenue,
        -- sum(s.freight_value) as total_freight_revenue,
        sum(s.price + s.freight_value) as y
    from sales.vw_sales as s
    left join sales.dim_products as p
        on s.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    group by p.product_description_lenght
)
-- select
--     *
-- from cte

select
    (count(*) * sum(x*y) - sum(x)*sum(y))
    / (
        sqrt(count(*) * sum(square(x)) - square(sum(x))) *
        sqrt(count(*) * sum(square(y)) - square(sum(y)))
    ) as corr
from cte

/*
corr
-0.42102038891692506
*/