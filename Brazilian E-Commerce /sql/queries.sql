-- =====================================
-- E-commerce SQL Analysis
-- =====================================

-- Total revenue by year

SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    SUM(payment_value) AS total_revenue
FROM order_payments
JOIN orders 
    ON order_payments.order_id = orders.order_id
GROUP BY year
ORDER BY year;

-- Total revenue by month
SELECT 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS month,
    SUM(payment_value) AS revenue
FROM order_payments
JOIN orders 
    ON order_payments.order_id = orders.order_id
GROUP BY month
ORDER BY month;

-- Total orders by year

SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(DISTINCT orders.order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

--Average Order Value (AOV) by year
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    SUM(payment_value) AS revenue,
    COUNT(DISTINCT orders.order_id) AS orders,
    SUM(payment_value) / COUNT(DISTINCT orders.order_id) AS AOV
FROM orders
JOIN order_payments 
    ON orders.order_id = order_payments.order_id
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

--AVG items per order by year

SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(order_items.order_id) AS total_items,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    COUNT(order_items.order_id) * 1.0  / COUNT(DISTINCT orders.order_id) AS avg_items_per_order
FROM orders
JOIN order_items 
    ON orders.order_id = order_items.order_id
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;


-- Average product price by year
SELECT 
    EXTRACT(YEAR FROM orders.order_purchase_timestamp) AS year,
    AVG(order_items.price) AS avg_product_price
FROM orders
JOIN order_items 
    ON orders.order_id = order_items.order_id
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

-- Top product categories by revenue (overall)
SELECT 
    products.product_category_name AS category,
    SUM(order_payments.payment_value) AS total_revenue
FROM orders
JOIN order_items 
    ON orders.order_id = order_items.order_id
JOIN products 
    ON order_items.product_id = products.product_id
JOIN order_payments 
    ON orders.order_id = order_payments.order_id
WHERE order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC;


-- Top 3 categories by revenue by year

-- Top 3 categories by revenue per year

SELECT *
FROM (
    SELECT 
        EXTRACT(YEAR FROM orders.order_purchase_timestamp) AS year,
        products.product_category_name AS category,
        SUM(order_payments.payment_value) AS total_revenue,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM orders.order_purchase_timestamp)
            ORDER BY SUM(order_payments.payment_value) DESC
        ) AS rank
    FROM orders
    JOIN order_items 
        ON orders.order_id = order_items.order_id
    JOIN products 
        ON order_items.product_id = products.product_id
    JOIN order_payments 
        ON orders.order_id = order_payments.order_id
    WHERE order_status = 'delivered'
    GROUP BY year, category
) t
WHERE rank <= 3
ORDER BY year, rank;


-- Average delivery time in days

SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    AVG(DATE_PART('day', order_delivered_customer_date - order_purchase_timestamp)) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
GROUP BY year
ORDER BY year;


-- Delivery time vs Review score

SELECT 
    order_reviews.review_score,
    AVG(DATE_PART('day', orders.order_delivered_customer_date - orders.order_purchase_timestamp)) AS avg_delivery_days,
    COUNT(*) AS number_of_reviews
FROM orders
JOIN order_reviews
    ON orders.order_id = order_reviews.order_id
WHERE orders.order_status = 'delivered'
AND orders.order_delivered_customer_date IS NOT NULL
GROUP BY order_reviews.review_score
ORDER BY order_reviews.review_score;

-- Revenue by state

SELECT 
    customers.customer_state,
    SUM(order_payments.payment_value) AS revenue
FROM orders
JOIN customers 
    ON orders.customer_id = customers.customer_id
JOIN order_payments 
    ON orders.order_id = order_payments.order_id
WHERE order_status = 'delivered'
GROUP BY customers.customer_state
ORDER BY revenue DESC;

-- Orders by month

SELECT 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;