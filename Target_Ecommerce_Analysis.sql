-- ============================================================
-- TARGET E-COMMERCE DATA ANALYSIS
-- ============================================================
-- Project: Brazilian E-Commerce Analysis
-- Dataset: Target / Olist E-Commerce Dataset
-- Tool: Google BigQuery SQL
--
-- Objective:
-- Analyze customer behavior, order trends, sales, freight,
-- delivery performance and payment patterns to generate
-- actionable business insights.
-- ============================================================


-- ============================================================
-- 1. DATASET UNDERSTANDING
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Data types of all columns in the customers table
-- ------------------------------------------------------------

SELECT
    table_name,
    column_name,
    data_type
FROM `scaler-thilak-rapido.Target.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name LIKE '%customers%';


-- ------------------------------------------------------------
-- 1.2 Time range during which orders were placed
-- ------------------------------------------------------------

SELECT
    MIN(order_purchase_timestamp) AS start_date,
    MAX(order_purchase_timestamp) AS end_date
FROM `Target.orders`;


-- ============================================================
-- 2. CUSTOMER & ORDER ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Number of unique cities and states from which customers
-- placed orders during the available period
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT c.customer_city) AS count_of_cities,
    COUNT(DISTINCT c.customer_state) AS count_of_states
FROM `Target.orders` o
JOIN `Target.customers` c
    USING (customer_id);


-- ------------------------------------------------------------
-- 2.2 Year-wise order volume
-- Used to identify the growth trend in orders
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY year
ORDER BY year;


-- ------------------------------------------------------------
-- 2.3 Year-wise order count using separate columns
-- ------------------------------------------------------------

SELECT
    COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2016)
        AS orders_2016,

    COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2017)
        AS orders_2017,

    COUNTIF(EXTRACT(YEAR FROM order_purchase_timestamp) = 2018)
        AS orders_2018
FROM `Target.orders`;


-- ============================================================
-- 3. MONTHLY SEASONALITY ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Monthly order volume by year
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    FORMAT_DATE(
        '%B',
        DATE(order_purchase_timestamp)
    ) AS month_name,
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY year, month, month_name
ORDER BY year, month;


-- ------------------------------------------------------------
-- 3.2 Month-wise comparison across years
-- Helps identify recurring seasonal patterns
-- ------------------------------------------------------------

SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    FORMAT_DATE(
        '%B',
        DATE(order_purchase_timestamp)
    ) AS month_name,

    COUNTIF(
        EXTRACT(YEAR FROM order_purchase_timestamp) = 2017
    ) AS orders_2017,

    COUNTIF(
        EXTRACT(YEAR FROM order_purchase_timestamp) = 2018
    ) AS orders_2018

FROM `Target.orders`
GROUP BY month, month_name
ORDER BY month;


-- ============================================================
-- 4. ORDER PLACEMENT TIME ANALYSIS
-- ============================================================

-- Business Question:
-- During which time of the day do customers mostly place orders?
--
-- Dawn      : 00:00 - 06:59
-- Morning   : 07:00 - 12:59
-- Afternoon : 13:00 - 18:59
-- Night     : 19:00 - 23:59
-- ------------------------------------------------------------

WITH order_times AS (
    SELECT
        order_id,
        EXTRACT(HOUR FROM order_purchase_timestamp) AS order_hour
    FROM `Target.orders`
)

SELECT
    COUNTIF(order_hour BETWEEN 0 AND 6) AS dawn_orders,
    COUNTIF(order_hour BETWEEN 7 AND 12) AS morning_orders,
    COUNTIF(order_hour BETWEEN 13 AND 18) AS afternoon_orders,
    COUNTIF(order_hour BETWEEN 19 AND 23) AS night_orders
FROM order_times;


-- ------------------------------------------------------------
-- 4.1 Order distribution by individual hour
-- Provides a more detailed view
-- ------------------------------------------------------------

SELECT
    EXTRACT(HOUR FROM order_purchase_timestamp) AS order_hour,
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.orders`
GROUP BY order_hour
ORDER BY order_hour;


-- ============================================================
-- 5. GEOGRAPHICAL ORDER ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 5.1 Month-on-month order volume by state and city
-- ------------------------------------------------------------

SELECT
    c.customer_state,
    c.customer_city,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    FORMAT_DATE(
        '%B',
        DATE(o.order_purchase_timestamp)
    ) AS month_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM `Target.orders` o
LEFT JOIN `Target.customers` c
    USING (customer_id)
GROUP BY
    c.customer_state,
    c.customer_city,
    year,
    month,
    month_name
ORDER BY
    c.customer_state,
    c.customer_city,
    year,
    month;


-- ------------------------------------------------------------
-- 5.2 Cities ranked by monthly order volume
-- ------------------------------------------------------------

WITH monthly_city_sales AS (
    SELECT
        c.customer_city,
        c.customer_state,
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM `Target.orders` o
    JOIN `Target.customers` c
        USING (customer_id)
    GROUP BY 1, 2, 3, 4
),

ranked_cities AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY year, month
            ORDER BY order_count DESC
        ) AS monthly_rank
    FROM monthly_city_sales
)

SELECT
    customer_city,
    customer_state,
    COUNTIF(monthly_rank = 1) AS months_ranked_first,
    ROUND(AVG(order_count), 2) AS average_monthly_orders
FROM ranked_cities
GROUP BY customer_city, customer_state
ORDER BY
    months_ranked_first DESC,
    average_monthly_orders DESC;


-- ============================================================
-- 6. CUSTOMER DISTRIBUTION
-- ============================================================

-- ------------------------------------------------------------
-- 6.1 Total registered customers vs active customers
-- by state and city
-- ------------------------------------------------------------

WITH customer_distribution AS (
    SELECT
        customer_state,
        customer_city,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM `Target.customers`
    GROUP BY customer_state, customer_city
),

active_customers AS (
    SELECT
        c.customer_state,
        c.customer_city,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM `Target.customers` c
    JOIN `Target.orders` o
        USING (customer_id)
    GROUP BY
        c.customer_state,
        c.customer_city
)

SELECT
    d.customer_state,
    d.customer_city,
    d.total_customers,
    COALESCE(a.active_customers, 0) AS active_customers
FROM customer_distribution d
LEFT JOIN active_customers a
    ON d.customer_state = a.customer_state
    AND d.customer_city = a.customer_city
ORDER BY
    total_customers DESC,
    active_customers DESC;


-- ------------------------------------------------------------
-- 6.2 State-wise customer distribution
-- ------------------------------------------------------------

SELECT
    customer_state,
    COUNT(DISTINCT customer_id) AS customer_count
FROM `Target.customers`
GROUP BY customer_state
ORDER BY customer_count DESC;


-- ============================================================
-- 7. SALES / PAYMENT VALUE ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 7.1 Year-over-year payment value growth
-- Comparing January-August across years
-- ------------------------------------------------------------

WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        ROUND(SUM(p.payment_value), 2) AS total_payment_value
    FROM `Target.payments` p
    JOIN `Target.orders` o
        USING (order_id)
    WHERE EXTRACT(MONTH FROM o.order_purchase_timestamp)
          BETWEEN 1 AND 8
    GROUP BY year
),

growth_analysis AS (
    SELECT
        year,
        total_payment_value,
        LAG(total_payment_value) OVER (
            ORDER BY year
        ) AS previous_year_value
    FROM yearly_sales
)

SELECT
    year,
    total_payment_value,
    previous_year_value,
    ROUND(
        100 * (
            total_payment_value - previous_year_value
        ) / NULLIF(previous_year_value, 0),
        2
    ) AS yoy_growth_percentage
FROM growth_analysis
WHERE previous_year_value IS NOT NULL
ORDER BY year;


-- ------------------------------------------------------------
-- 7.2 Total and average order value by state
-- ------------------------------------------------------------

WITH order_payment AS (
    SELECT
        o.order_id,
        p.payment_value,
        c.customer_state
    FROM `Target.payments` p
    JOIN `Target.orders` o
        USING (order_id)
    JOIN `Target.customers` c
        USING (customer_id)
)

SELECT
    customer_state,
    ROUND(SUM(payment_value), 2) AS total_sales,
    ROUND(
        SUM(payment_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM order_payment
GROUP BY customer_state
ORDER BY total_sales DESC;


-- ============================================================
-- 8. FREIGHT ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 8.1 Total and average freight value by state
-- ------------------------------------------------------------

WITH freight_data AS (
    SELECT
        o.order_id,
        oi.freight_value,
        c.customer_state
    FROM `Target.order_items` oi
    JOIN `Target.orders` o
        USING (order_id)
    JOIN `Target.customers` c
        USING (customer_id)
)

SELECT
    customer_state,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(
        SUM(freight_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_freight
FROM freight_data
GROUP BY customer_state
ORDER BY total_freight DESC;


-- ------------------------------------------------------------
-- 8.2 Top 5 states with highest average freight
-- ------------------------------------------------------------

WITH freight_by_state AS (
    SELECT
        c.customer_state,
        ROUND(
            SUM(oi.freight_value) /
            COUNT(DISTINCT oi.order_id),
            2
        ) AS average_freight
    FROM `Target.order_items` oi
    JOIN `Target.orders` o
        USING (order_id)
    JOIN `Target.customers` c
        USING (customer_id)
    GROUP BY c.customer_state
),

ranked_states AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_freight DESC
        ) AS rank
    FROM freight_by_state
)

SELECT
    customer_state,
    average_freight
FROM ranked_states
WHERE rank <= 5
ORDER BY rank;


-- ------------------------------------------------------------
-- 8.3 Top 5 states with lowest average freight
-- ------------------------------------------------------------

WITH freight_by_state AS (
    SELECT
        c.customer_state,
        ROUND(
            SUM(oi.freight_value) /
            COUNT(DISTINCT oi.order_id),
            2
        ) AS average_freight
    FROM `Target.order_items` oi
    JOIN `Target.orders` o
        USING (order_id)
    JOIN `Target.customers` c
        USING (customer_id)
    GROUP BY c.customer_state
),

ranked_states AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_freight
        ) AS rank
    FROM freight_by_state
)

SELECT
    customer_state,
    average_freight
FROM ranked_states
WHERE rank <= 5
ORDER BY rank;


-- ============================================================
-- 9. DELIVERY PERFORMANCE ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 9.1 Delivery time and difference from estimated delivery
--
-- Time_to_Deliver:
-- Purchase date → Actual delivery date
--
-- Date_Difference:
-- Actual delivery date - Estimated delivery date
--
-- Negative = Delivered before estimated date
-- Positive = Delivered after estimated date
-- ------------------------------------------------------------

SELECT
    order_id,

    DATE_DIFF(
        DATE(order_delivered_customer_date),
        DATE(order_purchase_timestamp),
        DAY
    ) AS time_to_deliver,

    DATE_DIFF(
        DATE(order_delivered_customer_date),
        DATE(order_estimated_delivery_date),
        DAY
    ) AS delivery_date_difference

FROM `Target.orders`
WHERE order_status = 'delivered';


-- ------------------------------------------------------------
-- 9.2 State-wise average delivery time
-- ------------------------------------------------------------

WITH delivery_data AS (
    SELECT
        o.order_id,
        c.customer_state,
        DATE_DIFF(
            DATE(o.order_delivered_customer_date),
            DATE(o.order_purchase_timestamp),
            DAY
        ) AS time_to_deliver
    FROM `Target.orders` o
    JOIN `Target.customers` c
        USING (customer_id)
    WHERE o.order_status = 'delivered'
)

SELECT
    customer_state,
    ROUND(AVG(time_to_deliver), 2) AS average_delivery_time
FROM delivery_data
GROUP BY customer_state
ORDER BY average_delivery_time DESC;


-- ------------------------------------------------------------
-- 9.3 Top 5 states with highest average delivery time
-- ------------------------------------------------------------

WITH delivery_data AS (
    SELECT
        c.customer_state,
        DATE_DIFF(
            DATE(o.order_delivered_customer_date),
            DATE(o.order_purchase_timestamp),
            DAY
        ) AS time_to_deliver
    FROM `Target.orders` o
    JOIN `Target.customers` c
        USING (customer_id)
    WHERE o.order_status = 'delivered'
),

state_delivery AS (
    SELECT
        customer_state,
        ROUND(AVG(time_to_deliver), 2) AS average_delivery_time
    FROM delivery_data
    GROUP BY customer_state
),

ranked_states AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_delivery_time DESC
        ) AS rank
    FROM state_delivery
)

SELECT
    customer_state,
    average_delivery_time
FROM ranked_states
WHERE rank <= 5
ORDER BY rank;


-- ------------------------------------------------------------
-- 9.4 Top 5 states with lowest average delivery time
-- ------------------------------------------------------------

WITH delivery_data AS (
    SELECT
        c.customer_state,
        DATE_DIFF(
            DATE(o.order_delivered_customer_date),
            DATE(o.order_purchase_timestamp),
            DAY
        ) AS time_to_deliver
    FROM `Target.orders` o
    JOIN `Target.customers` c
        USING (customer_id)
    WHERE o.order_status = 'delivered'
),

state_delivery AS (
    SELECT
        customer_state,
        ROUND(AVG(time_to_deliver), 2) AS average_delivery_time
    FROM delivery_data
    GROUP BY customer_state
),

ranked_states AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_delivery_time
        ) AS rank
    FROM state_delivery
)

SELECT
    customer_state,
    average_delivery_time
FROM ranked_states
WHERE rank <= 5
ORDER BY rank;


-- ------------------------------------------------------------
-- 9.5 States where orders were delivered earliest
-- compared with estimated delivery date
--
-- Positive days_early = delivered before estimated date
-- ------------------------------------------------------------

WITH delivery_performance AS (
    SELECT
        c.customer_state,
        DATE_DIFF(
            DATE(o.order_estimated_delivery_date),
            DATE(o.order_delivered_customer_date),
            DAY
        ) AS days_early
    FROM `Target.orders` o
    JOIN `Target.customers` c
        USING (customer_id)
    WHERE o.order_status = 'delivered'
),

state_performance AS (
    SELECT
        customer_state,
        ROUND(AVG(days_early), 2) AS average_days_early
    FROM delivery_performance
    WHERE days_early > 0
    GROUP BY customer_state
),

ranked_states AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY average_days_early DESC
        ) AS rank
    FROM state_performance
)

SELECT
    customer_state,
    average_days_early
FROM ranked_states
WHERE rank <= 5
ORDER BY rank;


-- ============================================================
-- 10. PAYMENT METHOD ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 10.1 Month-on-month order count by payment type
-- ------------------------------------------------------------

SELECT
    p.payment_type,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS order_count
FROM `Target.payments` p
JOIN `Target.orders` o
    USING (order_id)
GROUP BY payment_type, month
ORDER BY payment_type, month;


-- ------------------------------------------------------------
-- 10.2 Distribution of orders by payment installments
-- ------------------------------------------------------------

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS order_count
FROM `Target.payments`
GROUP BY payment_installments
ORDER BY payment_installments;


-- ------------------------------------------------------------
-- 10.3 Payment type distribution
-- ------------------------------------------------------------

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(
        100 * COUNT(DISTINCT order_id) /
        SUM(COUNT(DISTINCT order_id)) OVER (),
        2
    ) AS order_percentage
FROM `Target.payments`
GROUP BY payment_type
ORDER BY order_count DESC;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================