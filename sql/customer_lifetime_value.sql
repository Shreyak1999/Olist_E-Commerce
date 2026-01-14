WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp
    FROM fact_orders o
    WHERE o.order_status = 'delivered'
),

order_revenue AS (
    SELECT
        d.customer_id,
        d.order_id,
        d.order_purchase_timestamp,
        SUM(p.payment_value) AS order_revenue
    FROM delivered_orders d
    JOIN fact_payments p
        ON d.order_id = p.order_id
    GROUP BY
        d.customer_id,
        d.order_id,
        d.order_purchase_timestamp
),

customer_clv AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_revenue) AS lifetime_revenue,
        MIN(order_purchase_timestamp) AS first_order_date,
        MAX(order_purchase_timestamp) AS last_order_date,
        EXTRACT(DAY FROM MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp)) AS customer_lifespan_days
    FROM order_revenue
    GROUP BY customer_id
)
SELECT
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(lifetime_revenue)::numeric, 2) AS avg_customer_lifetime_value,
    ROUND(AVG(total_orders)::numeric, 2) AS avg_orders_per_customer,
    ROUND(AVG(customer_lifespan_days)::numeric, 2) AS avg_customer_lifespan_days,
    ROUND(SUM(lifetime_revenue)::numeric, 2) AS total_revenue
FROM customer_clv;