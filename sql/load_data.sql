-- ============================
-- LOAD DIMENSIONS
-- ============================

\COPY dim_customers
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

\COPY dim_products
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

\COPY dim_sellers
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- ============================
-- LOAD FACT TABLES
-- ============================

\COPY fact_orders
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

\COPY fact_order_items
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

\COPY fact_payments
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

\COPY fact_reviews
FROM 'C:/Users/cysd1/OneDrive/Desktop/Olist_E-Commerce/data/raw/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;
