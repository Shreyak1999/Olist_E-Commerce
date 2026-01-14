WITH seller_orders AS (
    SELECT
        oi.seller_id,
        o.order_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    FROM fact_order_items oi
    JOIN fact_orders o
        ON oi.order_id = o.order_id
),

seller_revenue AS (
    SELECT
        oi.seller_id,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM fact_order_items oi
    JOIN fact_orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
),

seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score)::numeric(10,2) AS avg_review_score
    FROM fact_order_items oi
    JOIN fact_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
),

seller_delivery AS (
    SELECT
        oi.seller_id,
        COUNT(o.order_id) AS total_orders,
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     <= o.order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) AS on_time_deliveries
    FROM fact_order_items oi
    JOIN fact_orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    s.seller_id,
    COALESCE(sr.total_revenue, 0) AS total_revenue,
    sd.total_orders,
    sd.on_time_deliveries,
    ROUND(
        sd.on_time_deliveries::numeric
        / NULLIF(sd.total_orders, 0) * 100,
        2
    ) AS on_time_delivery_pct,
    srw.avg_review_score
FROM seller_delivery sd
LEFT JOIN seller_revenue sr
    ON sd.seller_id = sr.seller_id
LEFT JOIN seller_reviews srw
    ON sd.seller_id = srw.seller_id
LEFT JOIN dim_sellers s
    ON sd.seller_id = s.seller_id
ORDER BY total_revenue DESC;