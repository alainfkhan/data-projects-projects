use olist_stg;


/*
want to generate seller names from seller_id, ...
create a query for context

what would affect seller name:
seller id
seller zip code prefix
seller city
seller state 
price  
freight value
product category name
business type
business segment
lead behaviour profile
product name lenght
product description lenght
product photos qty
product weight g
product length cm
product height cm
product width cm
review score
review comment title
review comment message
*/

with cte as (
    select distinct
        -- *
        m.*,
        cd.business_segment,
        -- cd.lead_behaviour_profile,
        cd.business_type,
        p.product_category_name,
        p.product_name_lenght,
        p.product_description_lenght,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        oi.price,
        -- oi.freight_value,
        -- r.review_score,
        r.review_comment_title,
        r.review_comment_message,
        isnull(len(r.review_comment_title), 0) + isnull(len(r.review_comment_message), 0) as len_review_comment
    from sales.dim_sellers as m
    left join sales.fact_order_items as oi
        on m.seller_id = oi.seller_id
    left join sales.fact_orders as o
        on oi.order_id = o.order_id
    left join sales.fact_order_reviews as r
        on o.order_id = r.order_id
    left join sales.dim_products as p
        on oi.product_id = p.product_id
    left join marketing.fact_closed_deals as cd
        on m.seller_id = cd.seller_id
    -- order by
    --     m.seller_id,
    --     p.product_name_lenght,
    --     oi.price,
    --     len_review_comment desc
),

tbl_rank as (
    select
        c.*,
        row_number() over (
            partition by
                c.seller_id,
                c.product_name_lenght,
                c.price
            order by
                c.seller_id,
                c.product_name_lenght,
                c.price,
                isnull(len(c.review_comment_title), 0) + isnull(len(c.review_comment_message), 0) desc
        ) as rn
    from cte as c
),

tbl_keep_row as (
    select
        r.*,
        count(r.rn) over (
            partition by 
                r.seller_id,
                r.product_name_lenght,
                r.price
        ) as len_rn,
        /*
        if |rn| == 1:
            keep row 
        elif (0, n):
            remove row
        else
            keep row
        */
        case
            when count(r.rn) over (
                partition by 
                    r.seller_id,
                    r.product_name_lenght,
                    r.price
            ) = 1
                then 1
            when r.len_review_comment = 0 and r.rn != 1
                then 0
                else 1
        end as keep_row
    from tbl_rank as r
)

select
    k.*    
into #context_sellers
from tbl_keep_row as k
where k.keep_row = 1
order by
    k.seller_id,
    k.product_name_lenght,
    k.price,
    k.len_review_comment desc

select *
from #context_sellers

alter table #context_sellers
drop column len_review_comment, rn, len_rn, keep_row

-- after import
select
    cm.seller_id,
    mn.seller_gen_name,
    cm.seller_city,
    cm.seller_state,
    cm.business_segment,
    cm.business_type,
    cm.product_category_name,
    pt.product_category_name_english,
    cm.product_weight_g,
    cm.price
from #context_sellers as cm
left join sales.dim_seller_gen_names as mn
    on cm.seller_id = mn.seller_id
left join sales.dim_product_category_name_translation as pt
    on cm.product_category_name = pt.product_category_name



/*
there are 3095 distinct seller_ids
generate corresponding seller names
inferring from the csv provided

pay special attention to columns:
    business_segment,
    business_type,
    product_category_name,
    product_category_weight
    price,
    review_comment_title,
    review_comment_message

infer
    the type of business its in from cols: 
        business_segment,
        business_type,
    the type of products they sell
        product_category_name,
        product_category_weight
        price,
        review_comment_title,
        review_comment_message

from that generate seller names based on the type of products they have sold
the generated seller names must be
    creative
    realistic
    authentic

do not generate generic seller names
    with codenames
    that ends in ltd

you should return a csv file
with columns: seller_id, seller_gen_name
*/

/*
tried chatgpt, generated generic names
chose claude
link to chat: https://claude.ai/share/bce2de4d-2c2c-49b0-8800-197221f6f91b

claude: data/external/interim/claude_seller_names_260228.csv
chatgpt: data/external/interim/cgpt_seller_names_260328.csv
*/


