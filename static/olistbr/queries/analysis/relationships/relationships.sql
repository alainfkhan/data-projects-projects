USE olist;

-- ==================================================
-- orders - order_items (order_id)
-- 1-many
-- ==================================================
-- order_id_count = row_count
-- 99441 = 99441
-- 1
SELECT
    COUNT(DISTINCT o.order_id) AS order_id_count,
    COUNT(*) AS row_count
FROM sales.fact_orders AS o

-- order_id_count < row_count
-- 9866 < 112650
-- there are duplicate order_ids
-- many
SELECT
    COUNT(DISTINCT oi.order_id) AS order_id_count,
    COUNT(*) AS row_count
FROM sales.fact_order_items AS oi


-- ==================================================
-- sellers - closed_deals (seller_id)
-- 1-1 Optional (1-0/1)
-- ==================================================
-- sales.dim_sellers
-- seller_id_count = row_count
-- 3095 = 3095
SELECT
    COUNT(DISTINCT m.seller_id) AS seller_id_count,
    COUNT(*) AS row_count
FROM sales.dim_sellers AS m

-- marketing.fact_closed_deals
-- seller_id_count = row_count
-- 842 = 842
SELECT
    COUNT(DISTINCT cd.seller_id) AS seller_id_count,
    COUNT(*) AS row_count
FROM marketing.fact_closed_deals AS cd

-- 1108 orphans
-- seller_ids of closed_deals who dont appear in sellers
SELECT
    cd.*,
    m.*
FROM marketing.fact_closed_deals AS cd
    LEFT JOIN sales.dim_sellers AS m
        ON cd.seller_id = m.seller_id
WHERE m.seller_id IS NULL


-- ==================================================
-- marketing.fact_closed_deals - marketing.fact_marketing_qualified_leads (mql_id)
-- 1 Optional - 1 (0/1-1)
-- ==================================================

-- closed_deals
-- mql_id_count = row_count
-- 842 = 842
-- 1
SELECT
    COUNT(DISTINCT cd.mql_id) AS mql_id_count,
    COUNT(*) AS row_count
FROM marketing.fact_closed_deals AS cd

-- marketing_qualified_leads
-- mql_id_count = row_count
-- 8000 = 8000
-- 1
SELECT
    COUNT(DISTINCT mql.mql_id) AS mql_id_count,
    COUNT(*) AS row_count
FROM marketing.fact_marketing_qualified_leads AS mql

-- closed_deals mql_id is contained in mql mql_id

-- joins
SELECT
    mql.*,
    cd.*
FROM marketing.fact_marketing_qualified_leads AS mql
    LEFT JOIN marketing.fact_closed_deals AS cd
        ON mql.mql_id = cd.mql_id
