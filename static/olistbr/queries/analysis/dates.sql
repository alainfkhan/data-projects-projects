-- date analysis

USE olist_stg

-- list all tables
SELECT * FROM INFORMATION_SCHEMA.TABLES;


/* tables that include time
sales.fact_orders
sales.fact_order_items
sales.fact_order_reviews
marketing.fact_marketing_qualified_leads
marketing.fact_closed_deals

need to find timezone
    find peak, should be 1400-1600
    then should be brasilia time BRT
    brazil discontinued daylight savings time in april 2019
*/

-- find min and max date for each table
-- sales.fact_orders
SELECT
    MIN(o.order_purchase_timestamp) AS min_purchase_timestamp,              -- min 2026-09-04
    MIN(o.order_approved_at) AS min_approved_at,
    MIN(o.order_delivered_carrier_date) AS min_delivered_carrier_date,
    MIN(o.order_delivered_customer_date) AS min_delivered_customer_date,
    MIN(o.order_estimated_delivery_date) AS min_estimated_delivery_date,
    MAX(o.order_purchase_timestamp) AS max_purchase_timestamp,
    MAX(o.order_approved_at) AS max_approved_at,
    MAX(o.order_delivered_carrier_date) AS max_delivered_carrier_date,
    MAX(o.order_delivered_customer_date) AS max_delivered_customer_date,
    MAX(o.order_estimated_delivery_date) AS max_estimated_delivery_date     -- max 2018-11-12
FROM sales.fact_orders AS o;
GO

SELECT
    MIN(ot.shipping_limit_date) AS min_shipping_limit_date,                 -- min 2016-09-19
    MAX(ot.shipping_limit_date) AS max_shipping_limit_date                  -- max 2020-04-09
FROM sales.fact_order_items AS ot

SELECT
    MIN(r.review_creation_date) AS min_review_creation_date,                -- min 2016-10-02
    MIN(r.review_answer_timestamp) AS min_review_answer_timestamp,
    MAX(r.review_creation_date) AS max_review_creation_date,
    MAX(r.review_answer_timestamp) AS max_review_answer_timestamp           -- max 2018-10-29
FROM sales.fact_order_reviews AS r

SELECT
    MIN(mql.first_contact_date) AS min_first_contact_date,                  -- min 2017-06-14
    MAX(mql.first_contact_date) AS max_first_contact_date                   -- max 2018-05-31
FROM marketing.fact_marketing_qualified_leads AS mql


SELECT
    MIN(cd.won_date) AS min_won_date,                                       -- min 2017-12-05
    MAX(cd.won_date) AS max_won_date                                        -- max 2018-11-14
FROM marketing.fact_closed_deals AS cd

/*
table, min date, max date
sales.fact_orders, 2016-09-04, 2018-11-12
sales.fact_order_items, 2016-09-19, 2020-04-09
sales.fact_order_reviews, 2016-10-02, 2018-10-29
marketing.fact_marketing_qualified_leads, 2017-06-14, 2018-05-31
marketing.fact_closed_deals, 2017-12-05, 2018-11-14

abs min: 2016-09-04
abs max: 2020-04-09
choose range 2016-01-01 to 2020-12-31
*/
