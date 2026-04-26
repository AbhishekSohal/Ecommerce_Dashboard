
/*Total revenue and order count by category*/
SELECT 
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales
WHERE status NOT IN ('Cancelled', 'cancelled')
GROUP BY category
ORDER BY total_revenue DESC;


/* Top 10 states by revenue */
SELECT 
    ship_state,
    COUNT(*) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales
WHERE status NOT IN ('Cancelled', 'cancelled')
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 10;

/*% Order Shipped vs Cancelled vs Returned etc*/
SELECT 
    status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM amazon_sales
GROUP BY status
ORDER BY total_orders DESC;

/*Month wise revenue*/
SELECT 
    DATE_FORMAT(STR_TO_DATE(date, '%m-%d-%y'), '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    ROUND(SUM(amount), 2) AS total_revenue
FROM amazon_sales
WHERE status NOT IN ('Cancelled', 'cancelled')
    AND date IS NOT NULL
GROUP BY month
ORDER BY month ASC;

/* Amazon fulfilment vs Merchant fulfilment*/
/* Which has lower cancellation rates*/
SELECT 
    fulfilment,
    COUNT(*) AS total_orders,
    ROUND(SUM(CASE WHEN status IN ('Cancelled', 'cancelled') 
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate,
    ROUND(AVG(amount), 2) AS avg_order_value
FROM amazon_sales
GROUP BY fulfilment
ORDER BY total_orders DESC;

/*B2B vs B2C order comparison*/
SELECT 
    b2b,
    COUNT(*) AS total_orders,
    ROUND(AVG(amount), 2) AS avg_order_value,
    ROUND(SUM(amount), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN status IN ('Cancelled', 'cancelled') 
              THEN 1  ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate
FROM amazon_sales
GROUP BY b2b
ORDER BY total_orders DESC;

/*Top 3 cities by revenue in each state*/
SELECT * FROM (
    SELECT 
        ship_state,
        ship_city,
        ROUND(SUM(amount), 2) AS city_revenue,
        RANK() OVER (PARTITION BY ship_state ORDER BY SUM(amount) DESC) AS city_rank
    FROM amazon_sales
    WHERE status NOT IN ('Cancelled', 'cancelled')
        AND ship_state IN ('MAHARASHTRA', 'KARNATAKA', 'TAMIL NADU', 'TELANGANA', 'UTTAR PRADESH')
    GROUP BY ship_state, ship_city
) ranked
WHERE city_rank <= 3
ORDER BY ship_state, city_rank;







