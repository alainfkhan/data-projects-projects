USE olist;
GO

-- ==================================================
-- Create Schemas
-- ==================================================

CREATE SCHEMA sales;
GO

CREATE SCHEMA marketing;
GO

CREATE SCHEMA logistics;
GO

-- ==================================================
-- Create Tables
-- --v means verified
-- ==================================================

-- ==========
-- Sales
-- ==========

-- olist_customers_dataset.csv
CREATE TABLE sales.customers (
    customer_id CHAR(32) NOT NULL,              --v
    customer_unique_id CHAR(32) NOT NULL,       --v
    customer_zip_code_prefix CHAR(5),           --v
    customer_city NVARCHAR(50),                 --v max 32 -> chose 50, ascii only
    customer_state CHAR(2),                     --v
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);  --v

-- olist_orders_dataset.csv
CREATE TABLE sales.orders (
    order_id CHAR(32) NOT NULL,                 --v
    customer_id CHAR(32) NOT NULL,              --v
    order_status VARCHAR(20) NOT NULL,          --v max 11 -> chose 20
    order_purchase_timestamp DATETIME2,         --v
    order_approved_at DATETIME2,                --v
    order_delivered_carrier_date DATETIME2,     --v
    order_delivered_customer_date DATETIME2,    --v
    order_estimated_delivery_date DATETIME2,    --v
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES sales.customers (customer_id)
); --v

-- olist_products_dataset.csv
CREATE TABLE sales.products (
    product_id CHAR(32) NOT NULL,           --v no null
    product_category_name NVARCHAR(100),    --v max 46 -> chose 100, contains null
    product_name_lenght TINYINT,            --v [5,76], contains null
    product_description_lenght SMALLINT,    --v [4,3992], contains null
    product_photos_qty TINYINT,             --v [1,20], contains null
    product_weight_g INT,                   --v [0,40425], contains null
    product_length_cm TINYINT,              --v [7,105], contains null
    product_height_cm TINYINT,              --v [2,105], contains null
    product_width_cm TINYINT,               --v [6,118], contains null
    CONSTRAINT pk_products PRIMARY KEY (product_id)
); --v

-- olist_order_items_dataset.csv
CREATE TABLE sales.order_items (
    order_id CHAR(32) NOT NULL,             --v no null
    order_item_id TINYINT NOT NULL,         --v [1,21] no null
    product_id CHAR(32) NOT NULL,           --v no null
    seller_id CHAR(32) NOT NULL,            --v no null
    shipping_limit_date DATETIME2,          --v
    price DECIMAL(10, 2),                   --v [0.85,6735.00], no null
    freight_value DECIMAL(10, 2),           --v [0.00,409.68], no null
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id)
); --v

-- olist_order_payments_dataset.csv
CREATE TABLE sales.order_payments (
    order_id CHAR(32) NOT NULL,             --v no null
    payment_sequential TINYINT NOT NULL,    --v [1,29], no null
    payment_type NVARCHAR(20),              --v 
    payment_installments TINYINT,           --v [0,24]
    payment_value DECIMAL(10, 2)            --v [0.00,13664.08]
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential)
); --v

-- olist_order_reviews_dataset.csv
CREATE TABLE sales.order_reviews (
    review_id CHAR(32) NOT NULL,            --v no null
    order_id CHAR(32) NOT NULL,             --v no null
    review_score TINYINT,                   --v [1,5] no null
    review_comment_title NVARCHAR(50),      --v max 26 -> chose 50, above ascii, contains null
    review_comment_message NVARCHAR(MAX),   --v max 208 -> chose MAX, above ascii, contains null
    review_creation_date DATETIME2,         --v
    review_answer_timestamp DATETIME2,      --v
    CONSTRAINT pk_order_reviews PRIMARY KEY (review_id)
); --v

-- olist_sellers_dataset.csv
CREATE TABLE sales.sellers (
    seller_id CHAR(32) NOT NULL,                --v no null TODO: need to prove
    seller_zip_code_prefix CHAR(5) NOT NULL,    --v no null
    seller_city NVARCHAR(100),                  --v max 40 -> chose 100, above ascii, no null
    seller_state CHAR(2),                       --v 
    CONSTRAINT pk_sellers PRIMARY KEY (seller_id)
); --v

-- product_category_name_translation.csv
CREATE TABLE sales.product_category_name_translation (
    product_category_name NVARCHAR(50) NOT NULL,    --v max 46 -> chose 50, not above ascii, no null
    product_category_name_english NVARCHAR(50)      --v max 46 -> chose 50, not above ascii, no null
    CONSTRAINT pk_product_category_name_translation PRIMARY KEY (
        product_category_name
    )
); --v

-- ==========
-- Marketing
-- ==========

-- olist_marketing_qualified_leads_dataset.csv
CREATE TABLE marketing.marketing_qualified_leads (
    mql_id CHAR(32) NOT NULL,       --v no null
    first_contact_date DATE,        --v
    landing_page_id CHAR(32),       --v no null
    origin VARCHAR(30),             --v max 17 -> chose 30 has null, not above ascii
    CONSTRAINT pk_marketing_qualified_leads PRIMARY KEY (mql_id)
);

-- olist_closed_deals_dataset.csv
CREATE TABLE marketing.closed_deals (
    mql_id CHAR(32) NOT NULL,       --v no null
    seller_id CHAR(32) NOT NULL,    --v no null
    sdr_id CHAR(32) NOT NULL,       --v no null
    sr_id CHAR(32) NOT NULL,        --v no null
    won_date DATETIME2,             --v
    business_segment VARCHAR(50),   --v max 31, has null
    lead_type VARCHAR(30),          --v has null, max 15
    lead_behaviour_profile VARCHAR(20),    --v max 11, has null, not above ascii
    has_company BIT,                --v TODO: True=1, False=0
    has_gtin BIT,                   --v
    average_stock VARCHAR(10),      --v max 7
    business_type VARCHAR(20),      --v max 12
    declared_product_catalog_size SMALLINT,   --v [1, 2000]
    declared_monthly_revenue DECIMAL(12, 2),  --v [0.00,50000000.00]
    CONSTRAINT pk_closed_deals PRIMARY KEY (mql_id)
); --v

-- ==========
-- Logistics
-- ==========

-- olist_geolocation_dataset.csv
CREATE TABLE logistics.geolocation (
    geolocation_zip_code_prefix CHAR(5) NOT NULL,   --v
    geolocation_lat DECIMAL(16, 14),    --v max decimal(16,14)
    geolocation_lng DECIMAL(16, 14),    --v
    geolocation_city NVARCHAR(100),     --v max 38, above ascii, no null
    geolocation_state CHAR(2),          --v no null
); --v

/* scratch

SELECT * FROM sys.schemas;
SELECT * FROM sys.tables;

-- view tables in a schema
SELECT *
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id;

-- view table schema
EXEC sp_help 'sales.order_items';

*/
