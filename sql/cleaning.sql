-- =========================
-- CLEAN CUSTOMERS
-- =========================

DROP TABLE IF EXISTS clean.customers;

CREATE TABLE clean.customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM raw.raw_customers
WHERE customer_id IS NOT NULL;


-- =========================
-- CLEAN ORDERS
-- =========================

DROP TABLE IF EXISTS clean.orders;

CREATE TABLE clean.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    
    -- conversion en timestamp propre
    order_purchase_timestamp::timestamp,
    order_delivered_customer_date::timestamp,
    order_estimated_delivery_date::timestamp,

    -- feature utile (retard livraison)
    (order_delivered_customer_date::timestamp - order_estimated_delivery_date::timestamp) AS delivery_delay

FROM raw.raw_orders
WHERE order_id IS NOT NULL;

-- =========================
-- CLEAN ORDER ITEMS
-- =========================

DROP TABLE IF EXISTS clean.order_items;

CREATE TABLE clean.order_items AS
SELECT
    order_id,
    product_id,
    seller_id,
    price,
    freight_value,

    -- valeur totale ligne
    (price + freight_value) AS total_price

FROM raw.raw_order_items
WHERE order_id IS NOT NULL;

-- =========================
-- CLEAN PRODUCTS
-- =========================

DROP TABLE IF EXISTS clean.products;

CREATE TABLE clean.products AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english
FROM raw.raw_products p
LEFT JOIN raw.raw_category_translation t
ON p.product_category_name = t.product_category_name;


-- =========================
-- CLEAN PAYMENTS
-- =========================

DROP TABLE IF EXISTS clean.payments;

CREATE TABLE clean.payments AS
SELECT
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM raw.raw_payments;


-- =========================
-- CLEAN REVIEWS
-- =========================

DROP TABLE IF EXISTS clean.reviews;

CREATE TABLE clean.reviews AS
SELECT
    review_id,
    order_id,
    review_score,
    review_creation_date::timestamp
FROM raw.raw_reviews;