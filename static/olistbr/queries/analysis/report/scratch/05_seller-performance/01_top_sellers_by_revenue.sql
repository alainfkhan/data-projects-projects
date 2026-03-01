USE olist_stg;

-- top sellers by revenue

SELECT TOP 10
    s.seller_id,
    SUM(s.price) AS total_product_revenue,
    SUM(s.freight_value) AS total_freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales AS s
    LEFT JOIN sales.dim_sellers AS m
        ON s.seller_id = m.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC

-- distinct sellers count = 3095
SELECT COUNT(DISTINCT m.seller_id)
FROM sales.dim_sellers AS m

-- no sellers have changed their location
SELECT DISTINCT m.*
FROM sales.dim_sellers AS m

/*
top sellers:
seller_id, total_product_revenue, total_freight_revenue, total_revenue
4869f7a5dfa277a7dca6462dcf3b52b2, 229237.6300, 20155.8100, 249393.4400
7c67e1448b00f6e969d365cea6b010ab, 187923.8900, 51612.5500, 239536.4400
53243585a1d6dc2643021fd1853d8905, 222776.0500, 13080.6300, 235856.6800
4a3ca9315b744ce9f8e9374361493884, 200326.1200, 35033.1800, 235359.3000
fa1c13f2614d7b5c4749cbc52fecda94, 192842.1300, 10019.5400, 202861.6700
da8622b14eb17ae2831f4ac5b9dab84a, 160236.5700, 24955.7500, 185192.3200
7e93a43ef30c4f03f38b393420bc753a, 172583.8800, 6254.5400, 178838.4200
1025f0e2d44d7041d6cf58b6550e0bfa, 138968.5500, 33892.1400, 172860.6900
7a67c85e85bb2ce8582c35f2203ad736, 141715.5400, 20891.7000, 162607.2400
955fee9216a65b617aa5c0531780ce60, 135159.7000, 25423.2000, 160582.9000
*/

-- what product categories do they sell?
SELECT
    LEFT(s.seller_id, 8) AS seller_id_prefix,
    pt.product_category_name_english,
    COUNT(DISTINCT s.order_id) AS order_count,
    SUM(s.price) AS total_product_revenue,
    SUM(s.freight_value) AS total_freight_revenue,
    SUM(s.price + s.freight_value) AS total_revenue
FROM sales.vw_sales AS s
    LEFT JOIN sales.dim_products AS p
        ON s.product_id = p.product_id
    LEFT JOIN sales.dim_product_category_name_translation AS pt
        ON p.product_category_name = pt.product_category_name
WHERE s.seller_id IN (
    '4869f7a5dfa277a7dca6462dcf3b52b2',
    '7c67e1448b00f6e969d365cea6b010ab',
    '53243585a1d6dc2643021fd1853d8905'
)
GROUP BY
    s.seller_id,
    pt.product_category_name_english
ORDER BY
    s.seller_id,
    pt.product_category_name_english,
    total_revenue DESC
