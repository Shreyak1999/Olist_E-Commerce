CREATE OR REPLACE VIEW seller_performance AS
SELECT
    s.seller_id,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS on_time_deliveries,
    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     <= o.order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        )::numeric
        / NULLIF(COUNT(DISTINCT o.order_id), 0) * 100,
        2
    ) AS on_time_delivery_pct,
    AVG(r.review_score)::numeric(10,2) AS avg_review_score
FROM fact_order_items oi
JOIN fact_orders o ON oi.order_id = o.order_id
LEFT JOIN fact_reviews r ON o.order_id = r.order_id
JOIN dim_sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id;

CREATE OR REPLACE VIEW monthly_revenue AS
WITH order_revenue AS (
    SELECT
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_revenue
    FROM fact_order_items oi
    GROUP BY oi.order_id
),
orders_with_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        o.order_status,
        r.order_revenue
    FROM fact_orders o
    JOIN order_revenue r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
),
monthly_revenue AS (
    SELECT
        order_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS active_customers,
        SUM(order_revenue) AS total_revenue,
        AVG(order_revenue) AS avg_order_value
    FROM orders_with_revenue
    GROUP BY order_month
),
revenue_growth AS (
    SELECT
        order_month,
        total_orders,
        active_customers,
        total_revenue,
        avg_order_value,
        ROUND(
            (
                (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
                / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0)
            )::numeric * 100,
            2
        ) AS revenue_growth_pct
    FROM monthly_revenue
)
SELECT
    order_month,
    total_orders,
    active_customers,
    ROUND(total_revenue::numeric, 2) AS total_revenue,
    ROUND(avg_order_value::numeric, 2) AS avg_order_value,
    revenue_growth_pct
FROM revenue_growth
ORDER BY order_month;


CREATE OR REPLACE VIEW view_customer_retention_cohorts AS
WITH customer_first_order AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS cohort_month
    FROM fact_orders
    GROUP BY customer_id
),
customer_orders AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        c.cohort_month,
        (
            EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_purchase_timestamp), c.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_purchase_timestamp), c.cohort_month))
        ) AS cohort_index
    FROM fact_orders o
    JOIN customer_first_order c
        ON o.customer_id = c.customer_id
),
cohort_counts AS (
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM customer_orders
    GROUP BY cohort_month, cohort_index
),
cohort_sizes AS (
    SELECT
        cohort_month,
        customer_count AS cohort_size
    FROM cohort_counts
    WHERE cohort_index = 0
)
SELECT
    c.cohort_month,
    c.cohort_index,
    c.customer_count,
    s.cohort_size,
    ROUND(
        c.customer_count::numeric / NULLIF(s.cohort_size, 0) * 100,
        2
    ) AS retention_pct
FROM cohort_counts c
JOIN cohort_sizes s
    ON c.cohort_month = s.cohort_month;