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
