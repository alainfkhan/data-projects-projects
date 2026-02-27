use olist_stg;

-- does photos qty affect review score?
/*

*/

with tbl_xy as (
    select distinct
        -- p.product_id,
        p.product_photos_qty as x,
        r.review_score as y
    from sales.fact_orders as o
    left join sales.fact_order_reviews as r
        on o.order_id = r.order_id
    left join sales.fact_order_items as oi
        on o.order_id = oi.order_id
    left join sales.dim_products as p
        on oi.product_id = p.product_id
    left join sales.dim_product_category_name_translation as pt
        on p.product_category_name = pt.product_category_name
    where
        p.product_photos_qty is not null
        and r.review_score is not null
)
select
    -- t.*,
    (count(*) * sum(x*y) - sum(x)*sum(y))
    / (sqrt(count(*) * sum(square(x)) - square(sum(x))) * sqrt(count(*) * sum(square(y)) - square(sum(y)))) as corr_photos_qty_review_score
from tbl_xy as t
-- order by
--     t.x,
--     t.y
