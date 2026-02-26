use olist_stg;

-- which product categories sell the most
/*
a sale is defined as
    order_status:
        'approved',
        'delivered',
        'invoiced',
        'processing',
        'shipped'
    and price is not null
*/


go;

-- top 3 highest grossing product categories

with rev_by_pt as (
    select
        d.year_number,
        d.month_number,
        pt.product_category_name_english,
        count(distinct s.order_id) as order_count,
        sum(s.price) as total_product_revenue,
        sum(s.freight_value) as total_freight_revenue,
        sum(s.price + s.freight_value) as total_revenue
    from sales.vw_sales as s
    left join sales.dim_products as p
        on s.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    right join utils.dim_date as d
        on s.date_key = d.date_key
    group by 
        d.year_number,
        d.month_number,
        pt.product_category_name_english
),

rn_rev as (
    select
        -- r.year_number,
        -- r.month_number,
        -- r.product_category_name_english,
        r.*,
        row_number() over (
            partition by
                r.year_number,
                r.month_number
            order by 
                r.total_revenue desc
        ) as rn
    from rev_by_pt as r
)
-- select
--     r.*
-- from rn_rev as r

select
    r.year_number,
    r.month_number,
    r.rn as top_category_rank,
    r.product_category_name_english,
    -- r.total_product_revenue,
    -- r.total_freight_revenue,
    r.total_revenue
into #top_three_categories
from rn_rev as r
where r.rn between 1 and 3
order by 
    r.year_number,
    r.month_number,
    r.rn

-- which consistently appear in top three product categories?
select
    t.product_category_name_english,
    count(t.product_category_name_english) as appearances
from #top_three_categories as t
group by t.product_category_name_english
order by appearances desc

/*
health_beauty has consistently appeared the most out of all categories
*/





go;


