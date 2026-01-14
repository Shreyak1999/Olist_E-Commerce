WITH customer_orders AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(
            CASE 
                WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                THEN 1 ELSE 0 
            END
        ) AS on_time_orders,
        COUNT(r.review_id) AS orders_with_reviews
    FROM fact_orders o
    LEFT JOIN fact_reviews r 
        ON o.order_id = r.order_id
    GROUP BY o.customer_id
)
SELECT
    COUNT(customer_id) AS total_customers,
    SUM(total_orders) AS total_orders,
    SUM(delivered_orders) AS delivered_orders,
    SUM(on_time_orders) AS on_time_orders,
    SUM(orders_with_reviews) AS orders_with_reviews,
    ROUND(SUM(on_time_orders)::numeric / NULLIF(SUM(total_orders), 0) * 100, 2) AS on_time_pct,
    ROUND(SUM(orders_with_reviews)::numeric / NULLIF(SUM(total_orders), 0) * 100, 2) AS review_pct
FROM customer_orders;
