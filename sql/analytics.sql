DROP TABLE IF EXISTS analytics.fact_orders;

CREATE TABLE analytics.fact_orders AS
WITH items AS (
    SELECT
        order_id,
        SUM(price) AS total_items_price,
        SUM(freight_value) AS total_freight,
        SUM(price + freight_value) AS total_order_items_value
    FROM clean.order_items
    GROUP BY order_id
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM clean.payments
    GROUP BY order_id
),

reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM clean.reviews
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.order_purchase_timestamp::date AS order_date,
    o.delivery_delay,

    i.total_items_price,
    i.total_freight,
    i.total_order_items_value,

    p.total_payment_value,
    r.avg_review_score

FROM clean.orders o
LEFT JOIN items i ON o.order_id = i.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id

WHERE o.order_purchase_timestamp >= '2017-01-01'
AND o.order_purchase_timestamp < '2018-09-01';


-- =========================
-- KPI GLOBAL
-- =========================

DROP TABLE IF EXISTS analytics.kpis;

CREATE TABLE analytics.kpis AS
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment_value) AS total_revenue,
    AVG(total_payment_value) AS avg_order_value
FROM analytics.fact_orders;



DROP TABLE IF EXISTS analytics.kpis_monthly;

CREATE TABLE analytics.kpis_monthly AS
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment_value) AS total_revenue,
    AVG(total_payment_value) AS avg_order_value
FROM analytics.fact_orders
GROUP BY 1
ORDER BY 1;


DROP TABLE IF EXISTS analytics.rfm_base;

CREATE TABLE analytics.rfm_base AS
SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    total_payment_value
FROM analytics.fact_orders;



-- =========================
-- RFM SCORES
-- =========================

DROP TABLE IF EXISTS analytics.rfm_scores;

CREATE TABLE analytics.rfm_scores AS
WITH rfm AS (
    SELECT
        customer_id,

        -- Recency : jours depuis dernier achat
        EXTRACT(DAY FROM (NOW() - MAX(order_purchase_timestamp))) AS recency,

        -- Frequency : nombre de commandes
        COUNT(DISTINCT order_id) AS frequency,

        -- Monetary : total dépensé
        SUM(total_payment_value) AS monetary

    FROM analytics.rfm_base
    GROUP BY customer_id
)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,

    -- scoring (1 à 5)
   NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
   NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
   NTILE(5) OVER (ORDER BY monetary DESC) AS m_score

FROM rfm;


-- =========================
-- RFM SEGMENTS
-- =========================

DROP TABLE IF EXISTS analytics.rfm_segments;

CREATE TABLE analytics.rfm_segments AS
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    -- FIX IMPORTANT : concat en texte lisible
    CONCAT(r_score, '-', f_score, '-', m_score) AS rfm_score,

    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END AS segment

FROM analytics.rfm_scores;

DROP TABLE IF EXISTS analytics.churn;

CREATE TABLE analytics.churn AS
WITH max_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date
    FROM analytics.fact_orders
),
last_order AS (
    SELECT
        customer_id,
        MAX(order_purchase_timestamp) AS last_order_date
    FROM analytics.fact_orders
    GROUP BY customer_id
)

SELECT
    l.customer_id,
    l.last_order_date,
    EXTRACT(DAY FROM (m.max_date - l.last_order_date)) AS days_since_last_order,

    CASE
        WHEN EXTRACT(DAY FROM (m.max_date - l.last_order_date)) > 180 THEN 1
        ELSE 0
    END AS is_churned

FROM last_order l
CROSS JOIN max_date m;

DROP TABLE IF EXISTS analytics.customer_summary;

CREATE TABLE analytics.customer_summary AS
SELECT
    r.customer_id,
    r.segment,
    r.recency,
    r.frequency,
    r.monetary,
    c.is_churned
FROM analytics.rfm_segments r
LEFT JOIN analytics.churn c
ON r.customer_id = c.customer_id;

DROP TABLE IF EXISTS analytics.product_performance;

CREATE TABLE analytics.product_performance AS
SELECT
    p.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price + oi.freight_value) AS revenue,
    AVG(oi.price) AS avg_price
FROM clean.order_items oi
JOIN clean.products p
ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY revenue DESC;

DROP TABLE IF EXISTS analytics.dim_date;


CREATE TABLE analytics.dim_date AS
SELECT
    d::date AS date,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(DAY FROM d) AS day,
    TO_CHAR(d, 'YYYY-MM') AS year_month,
    TO_CHAR(d, 'Mon YYYY') AS month_label,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(YEAR FROM d) * 100 + EXTRACT(MONTH FROM d) AS year_month_sort
FROM generate_series(
    (SELECT MIN(order_purchase_timestamp)::date FROM analytics.fact_orders),
    (SELECT MAX(order_purchase_timestamp)::date FROM analytics.fact_orders),
    interval '1 day'
) AS d;