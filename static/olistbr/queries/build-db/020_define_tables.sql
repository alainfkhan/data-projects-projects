-- ==================================================
-- Create Tables
-- dim_<table> or fact_<table>
-- pk_<child>
-- fk_<child>_<parent>__<col>
-- ==================================================

-- ==========
-- Sales
-- ==========

-- Dimension tables ==========

-- olist_customers_dataset.csv
CREATE TABLE sales.dim_customers (              -- no nulls
    customer_id CHAR(32) NOT NULL,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix CHAR(5) NOT NULL,
    customer_city VARCHAR(50),                  -- max 32
    customer_state CHAR(2),

    CONSTRAINT pk_dim_customers
        PRIMARY KEY (customer_id)
);

CREATE TABLE sales.dim_sellers (                -- no nulls
    seller_id CHAR(32) NOT NULL,
    seller_zip_code_prefix CHAR(5) NOT NULL,
    seller_city NVARCHAR(50) NOT NULL,          -- max 40
    seller_state CHAR(2) NOT NULL

    CONSTRAINT pk_dim_sellers
        PRIMARY KEY (seller_id)
);

-- product_category_name_translation.csv
CREATE TABLE sales.dim_product_category_name_translation (  -- no nulls
    product_category_name VARCHAR(50) NOT NULL,             -- max 46
    product_category_name_english VARCHAR(50) NOT NULL,     -- max 39

    CONSTRAINT pk_dim_product_category_name_translation
        PRIMARY KEY (product_category_name)
);

-- olist_products_dataset.csv
CREATE TABLE sales.dim_products (           -- nulls: tail
    product_id CHAR(32) NOT NULL,
    product_category_name VARCHAR(50),      -- max 46
    product_name_lenght TINYINT,            -- [5, 76]
    product_description_lenght SMALLINT,    -- [4, 3992]
    product_photos_qty TINYINT,             -- [1, 20]
    product_weight_g INT,                   -- [0, 40425]
    product_length_cm TINYINT,              -- [7, 105]
    product_height_cm TINYINT,              -- [2, 105]
    product_width_cm TINYINT,               -- [6, 118]

    CONSTRAINT pk_dim_products
        PRIMARY KEY (product_id),
    CONSTRAINT
    fk_dim_products_dim_product_category_name_translation__product_category_name
        FOREIGN KEY (product_category_name)
            REFERENCES
                sales.dim_product_category_name_translation
                (product_category_name)

);

-- Fact tables ==========

-- olist_orders_dataset.csv
CREATE TABLE sales.fact_orders (                        -- nulls
    order_id CHAR(32) NOT NULL,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,                  -- max 11
    order_purchase_timestamp DATETIME2 NOT NULL,
    order_approved_at DATETIME2,
    order_delivered_carrier_date DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATETIME2 NOT NULL,   -- min DATE

    CONSTRAINT pk_fact_orders
        PRIMARY KEY (order_id),
    CONSTRAINT fk_fact_orders_dim_customers__customer_id
        FOREIGN KEY (customer_id)
            REFERENCES sales.dim_customers (customer_id)
);

-- olist_order_items_dataset.csv
CREATE TABLE sales.fact_order_items (       -- no nulls
    order_id CHAR(32) NOT NULL,
    order_item_id TINYINT NOT NULL,         -- [1, 21]
    product_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    shipping_limit_date DATETIME2 NOT NULL,
    price DECIMAL(9, 4) NOT NULL,           -- [0.85, 6735.00] max decimal(6, 2)
    freight_value DECIMAL(9, 4) NOT NULL,   -- [0.00, 409.68] max decimal(5, 2)

    CONSTRAINT pk_fact_order_items
        PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_fact_order_items_fact_orders__order_id
        FOREIGN KEY (order_id)
            REFERENCES sales.fact_orders (order_id),
    CONSTRAINT fk_fact_order_items_dim_products__product_id
        FOREIGN KEY (product_id)
            REFERENCES sales.dim_products (product_id),
    CONSTRAINT fk_fact_order_items_dim_sellers__seller_id
        FOREIGN KEY (seller_id)
            REFERENCES sales.dim_sellers (seller_id)
);

-- olist_order_payments_dataset.csv
CREATE TABLE sales.fact_order_payments (    -- no nulls
    order_id CHAR(32) NOT NULL,
    payment_sequential TINYINT NOT NULL,    -- [1, 29]
    payment_type VARCHAR(20) NOT NULL,      -- max 11 
    payment_installments TINYINT NOT NULL,  -- [0, 24]
    payment_value DECIMAL(9, 4) NOT NULL,   -- [0.00, 13664.08] max decimal(7, 2)

    CONSTRAINT pk_fact_order_payments
        PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_fact_order_payments_fact_orders__order_id
        FOREIGN KEY (order_id)
            REFERENCES sales.fact_orders (order_id)
);

-- olist_order_reviews_dataset.csv
CREATE TABLE sales.fact_order_reviews (     -- nulls: title, message
    review_id CHAR(32) NOT NULL,
    order_id CHAR(32) NOT NULL,
    review_score TINYINT NOT NULL,          -- [1,5]
    review_comment_title NVARCHAR(30),      -- max 26
    review_comment_message NVARCHAR(210),   -- max 208
    review_creation_date DATETIME2 NOT NULL,-- max date
    review_answer_timestamp DATETIME2 NOT NULL,

    CONSTRAINT pk_fact_order_reviews
        PRIMARY KEY (review_id, order_id),
    CONSTRAINT fk_fact_order_reviews_fact_orders__order_id
        FOREIGN KEY (order_id)
            REFERENCES sales.fact_orders (order_id),
    CONSTRAINT chk_review_score CHECK (review_score BETWEEN 1 AND 5)
);

-- ==========
-- Marketing
-- ==========

-- olist_marketing_qualified_leads_dataset.csv
CREATE TABLE marketing.fact_marketing_qualified_leads ( -- nulls: origin
    mql_id CHAR(32) NOT NULL,
    first_contact_date DATE NOT NULL,   -- actual date
    landing_page_id CHAR(32) NOT NULL,
    origin VARCHAR(20),                 -- max 17

    CONSTRAINT pk_fact_marketing_qualified_leads
        PRIMARY KEY (mql_id)
);

-- olist_closed_deals_dataset.csv
CREATE TABLE marketing.fact_closed_deals (      -- not null: ids, won_date, rev
    mql_id CHAR(32) NOT NULL,
    seller_id CHAR(32) NOT NULL,
    sdr_id CHAR(32) NOT NULL,
    sr_id CHAR(32) NOT NULL,
    won_date DATETIME2 NOT NULL,
    business_segment VARCHAR(40),               -- max 31
    lead_type VARCHAR(20),                      -- max 15
    lead_behaviour_profile VARCHAR(20),         -- max 11
    has_company BIT,
    has_gtin BIT,
    average_stock VARCHAR(10),                  -- max 7
    business_type VARCHAR(20),                  -- max 12
    declared_product_catalog_size DECIMAL(9, 4),-- [1.0, 2000.0] max decimal(5, 1)
    declared_monthly_revenue DECIMAL(19, 4),    -- [0.00,50000000.00] max decimal(9, 1)

    CONSTRAINT pk_fact_closed_deals
        PRIMARY KEY (mql_id),
    CONSTRAINT fk_fact_closed_deals_fact_marketing_qualified_leads__mql_id
        FOREIGN KEY (mql_id)
            REFERENCES marketing.fact_marketing_qualified_leads (mql_id)
);

-- ==========
-- Logistics
-- ==========

-- olist_geolocation_dataset.csv
-- lat/lng is max 17sf
-- lat/lng at decimal(9,6) has error ~11cm sufficient
CREATE TABLE logistics.dim_geolocation (
    geolocation_sk INT IDENTITY (1, 1) NOT NULL,
    geolocation_zip_code_prefix CHAR(5) NOT NULL,
    geolocation_lat DECIMAL(9, 6),    -- max decimal(21,20)
    geolocation_lng DECIMAL(9, 6),    -- max decimal(17,16)
    geolocation_city NVARCHAR(40),      -- max 38
    geolocation_state CHAR(2),

    CONSTRAINT pk_dim_geolocation
        PRIMARY KEY (geolocation_sk),
    CONSTRAINT uq_dim_geolocation_zip_lat_lng
        UNIQUE (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng)
);
