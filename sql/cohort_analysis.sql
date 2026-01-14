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
    ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.cohort_index;