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
    customer_id CHAR(32) NOT NULL,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix CHAR(5),
    customer_city VARCHAR(50),                 -- max 32
    customer_state CHAR(2),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);

-- olist_orders_dataset.csv
CREATE TABLE sales.orders (
    order_id CHAR(32) NOT NULL,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(20),               -- max 11
    order_purchase_timestamp DATETIME2,
    order_approved_at DATETIME2,
    order_delivered_carrier_date DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATE,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES sales.customers (customer_id)
);

-- olist_products_dataset.csv
CREATE TABLE sales.products (
    product_id CHAR(32) NOT NULL,
    product_category_name VARCHAR(50),      -- max 46
    product_name_lenght TINYINT,            -- [5,76]
    product_description_lenght SMALLINT,    -- [4,3992]
    product_photos_qty TINYINT,             -- [1,20]
    product_weight_g INT,                   -- [0,40425]
    product_length_cm TINYINT,              -- [7,105]
    product_height_cm TINYINT,              -- [2,105]
    product_width_cm TINYINT,               -- [6,118]
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);

-- olist_order_items_dataset.csv
CREATE TABLE sales.order_items (
    order_id CHAR(32) NOT NULL,
    order_item_id TINYINT NOT NULL,         -- [1,21]
    product_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    shipping_limit_date DATETIME2,
    price SMALLMONEY,                       -- [0.85,6735.00]
    freight_value SMALLMONEY,               -- [0.00,409.68]
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id)
        REFERENCES sales.orders (order_id)
);

-- olist_order_payments_dataset.csv
CREATE TABLE sales.order_payments (
    order_id CHAR(32) NOT NULL,
    payment_sequential TINYINT NOT NULL,    -- [1,29]
    payment_type VARCHAR(20),               -- max 11 
    payment_installments TINYINT,           -- [0,24]
    payment_value SMALLMONEY,               -- [0.00,13664.08]
    CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential)
);

-- olist_order_reviews_dataset.csv
CREATE TABLE sales.order_reviews (
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score TINYINT,                   -- [1,5]
    review_comment_title NVARCHAR(30),      -- max 26
    review_comment_message NVARCHAR(210),   -- max 208
    review_creation_date DATETIME2,
    review_answer_timestamp DATETIME2,
    CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id)
);

-- olist_sellers_dataset.csv
CREATE TABLE sales.sellers (
    seller_id CHAR(32) NOT NULL,
    seller_zip_code_prefix CHAR(5) NOT NULL,
    seller_city NVARCHAR(50),                   -- max 40
    seller_state CHAR(2),
    CONSTRAINT pk_sellers PRIMARY KEY (seller_id)
);

-- product_category_name_translation.csv
CREATE TABLE sales.product_category_name_translation (
    product_category_name VARCHAR(50) NOT NULL,             -- max 46
    product_category_name_english VARCHAR(50) NOT NULL,     -- max 46
    CONSTRAINT pk_product_category_name_translation PRIMARY KEY (
        product_category_name
    )
);

-- ==========
-- Marketing
-- ==========

-- olist_marketing_qualified_leads_dataset.csv
CREATE TABLE marketing.marketing_qualified_leads (
    mql_id CHAR(32) NOT NULL,
    first_contact_date DATE,
    landing_page_id CHAR(32),
    origin VARCHAR(20),             -- max 17
    CONSTRAINT pk_marketing_qualified_leads PRIMARY KEY (mql_id)
);

-- olist_closed_deals_dataset.csv
CREATE TABLE marketing.closed_deals (
    mql_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    sdr_id CHAR(32) NOT NULL,
    sr_id CHAR(32) NOT NULL,
    won_date DATETIME2,
    business_segment VARCHAR(40),               -- max 31
    lead_type VARCHAR(20),                      -- max 15
    lead_behaviour_profile VARCHAR(20),         -- max 11
    has_company BIT,
    has_gtin BIT,
    average_stock VARCHAR(10),                  -- max 7
    business_type VARCHAR(20),                  -- max 12
    declared_product_catalog_size SMALLINT,     -- [1, 2000]
    declared_monthly_revenue MONEY,             -- [0.00,50000000.00]
    CONSTRAINT pk_closed_deals PRIMARY KEY (mql_id)
);

-- ==========
-- Logistics
-- ==========

-- olist_geolocation_dataset.csv
CREATE TABLE logistics.geolocation (
    geolocation_zip_code_prefix CHAR(5) NOT NULL,
    geolocation_lat GEOGRAPHY,          -- ~ [decimal(21, 20), decimal(16, 14)]
    geolocation_lng GEOGRAPHY,          -- ~ [decimal(17, 14), decimal(16, 15)]
    geolocation_city NVARCHAR(40),     -- max 38
    geolocation_state CHAR(2),
);
