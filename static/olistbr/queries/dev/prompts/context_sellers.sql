USE olist;


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

WITH cte AS (
    SELECT DISTINCT
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
        ISNULL(LEN(r.review_comment_title), 0)
        + ISNULL(LEN(r.review_comment_message), 0) AS len_review_comment
    FROM sales.dim_sellers AS m
        LEFT JOIN sales.fact_order_items AS oi
            ON m.seller_id = oi.seller_id
        LEFT JOIN sales.fact_orders AS o
            ON oi.order_id = o.order_id
        LEFT JOIN sales.fact_order_reviews AS r
            ON o.order_id = r.order_id
        LEFT JOIN sales.dim_products AS p
            ON oi.product_id = p.product_id
        LEFT JOIN marketing.fact_closed_deals AS cd
            ON m.seller_id = cd.seller_id
    -- order by
    --     m.seller_id,
    --     p.product_name_lenght,
    --     oi.price,
    --     len_review_comment desc
),

tbl_rank AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                c.seller_id,
                c.product_name_lenght,
                c.price
            ORDER BY
                c.seller_id,
                c.product_name_lenght,
                c.price,
                ISNULL(LEN(c.review_comment_title), 0)
                + ISNULL(LEN(c.review_comment_message), 0) DESC
        ) AS rn
    FROM cte AS c
),

tbl_keep_row AS (
    SELECT
        r.*,
        COUNT(r.rn) OVER (
            PARTITION BY
                r.seller_id,
                r.product_name_lenght,
                r.price
        ) AS len_rn,
        /*
        if |rn| == 1:
            keep row
        elif (0, n):
            remove row
        else
            keep row
        */
        CASE
            WHEN COUNT(r.rn) OVER (
                PARTITION BY
                    r.seller_id,
                    r.product_name_lenght,
                    r.price
            ) = 1
                THEN 1
            WHEN r.len_review_comment = 0 AND r.rn != 1
                THEN 0
                ELSE 1
        END AS keep_row
    FROM tbl_rank AS r
)

SELECT k.*
INTO #context_sellers
FROM tbl_keep_row AS k
WHERE k.keep_row = 1
ORDER BY
    k.seller_id,
    k.product_name_lenght,
    k.price,
    k.len_review_comment DESC

SELECT *
FROM #context_sellers

ALTER TABLE #context_sellers
DROP COLUMN len_review_comment, rn, len_rn, keep_row

-- after import
SELECT
    cm.seller_id,
    mn.seller_gen_name,
    cm.seller_city,
    cm.seller_state,
    cm.business_segment,
    cm.business_type,
    cm.product_category_name,
    pt.product_category_name_english,
    cm.product_weight_g,
    cm.price,
    cm.review_comment_title,
    cm.review_comment_message
FROM #context_sellers AS cm
    LEFT JOIN sales.dim_seller_gen_names AS mn
        ON cm.seller_id = mn.seller_id
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON cm.product_category_name = pt.product_category_name

/*
the output of this query is in data/external/queries
*/

/* prompt:
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

can use this data to iterate and create better names
*/
