CREATE DATABASE IF NOT EXISTS cart_abandonment_analysis;
USE cart_abandonment_analysis;

CREATE TABLE cart_items (
	cart_item_id VARCHAR(50) PRIMARY KEY NOT NULL,
	session_id VARCHAR(50),
	visitor_id VARCHAR(50),
	product_id VARCHAR(50),
	added_at DATETIME,
	quantity INT,
	cart_item_status VARCHAR(50)
);

CREATE TABLE events (
	event_id VARCHAR(50) PRIMARY KEY NOT NULL,
	session_id VARCHAR(50),
	visitor_id VARCHAR(50),
	event_timestamp DATETIME,
	sequence_step INT,
	event_type VARCHAR(50),
    product_id VARCHAR(50),
    transaction_id VARCHAR(50) NULL
);

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY NOT NULL,
	product_name VARCHAR(50),
	category VARCHAR(50),
	brand VARCHAR(50),
	unit_cost DECIMAL(10,2),
	unit_price DECIMAL(10,2),
    active_flag INT
);

CREATE TABLE sessions (
	session_id VARCHAR(50) PRIMARY KEY NOT NULL,
	visitor_id VARCHAR(50),
	session_start DATETIME,
	device_type VARCHAR(50),
	traffic_source VARCHAR(50),
	session_status VARCHAR(50)
);

CREATE TABLE transactions (
	transaction_id VARCHAR(50) PRIMARY KEY NOT NULL,
	session_id VARCHAR(50),
	visitor_id VARCHAR(50),
	transaction_date DATE,
	order_value DECIMAL(10,2),
	payment_method VARCHAR(50)
);

CREATE TABLE visitors (
	visitor_id VARCHAR(50) PRIMARY KEY NOT NULL,
	first_seen_date DATE,
	device_type VARCHAR(50),
	traffic_source VARCHAR(50),
	country VARCHAR(50)
);

LOAD DATA LOCAL INFILE
'path/cart_items_clean.csv'
INTO TABLE cart_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    cart_item_id,
    session_id,
    visitor_id,
    product_id,
    @added_at,
    quantity,
    cart_item_status
)
SET added_at = STR_TO_DATE(TRIM(@added_at), '%d-%m-%Y %H:%i');

LOAD DATA LOCAL INFILE
'path/events_clean.csv'
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    event_id,
    session_id,
    visitor_id,
    @event_timestamp,
    sequence_step,
    event_type,
    product_id,
    @transaction_id
)
SET
    event_timestamp = STR_TO_DATE(TRIM(@event_timestamp), '%d-%m-%Y %H:%i'),
    transaction_id = NULLIF(TRIM(@transaction_id), '');

LOAD DATA LOCAL INFILE
'path/products_clean.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	product_id, 
    product_name,
    category, brand, 
    unit_cost, 
    unit_price, 
    active_flag
);

LOAD DATA LOCAL INFILE
'path/sessions_clean.csv'
INTO TABLE sessions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    session_id,
    visitor_id,
    @session_start,
    device_type,
    traffic_source,
    session_status
)
SET session_start = STR_TO_DATE(TRIM(@session_start), '%d-%m-%Y %H:%i');

LOAD DATA LOCAL INFILE 
'path/transactions_clean.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	transaction_id, 
    session_id, 
    visitor_id, 
    @transaction_date, 
    order_value, 
    payment_method)
SET 
	transaction_date = STR_TO_DATE(TRIM(@transaction_date), '%d-%m-%Y');

LOAD DATA LOCAL INFILE
'path/visitors_clean.csv'
INTO TABLE visitors
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    visitor_id,
    @first_seen_date,
    device_type,
    traffic_source,
    country
)
SET first_seen_date = STR_TO_DATE(TRIM(@first_seen_date), '%d-%m-%Y');

-- cart_items
SELECT COUNT(*) FROM cart_items; -- 5365 total rows
SELECT COUNT(DISTINCT(cart_item_id)) FROM cart_items; -- 5365 distinct cart_item_id's

-- events
SELECT COUNT(*) FROM events; -- 17450 total rows
SELECT COUNT(DISTINCT(event_id)) FROM events; -- 17450 distinct event_id's

-- products
SELECT COUNT(*) FROM products; -- 180 total rows
SELECT COUNT(DISTINCT(product_id)) FROM products; -- 180 distinct product_id's

-- sessions
SELECT COUNT(*) FROM sessions; -- 3500 total rows
SELECT COUNT(DISTINCT(session_id)) FROM sessions; -- 3500 distinct session_id's

-- transactions
SELECT COUNT(*) FROM transactions; -- 830 total rows
SELECT COUNT(DISTINCT(transaction_id)) FROM transactions; -- 830 distinct transaction_id's

-- visitors
SELECT COUNT(*) FROM visitors; -- 1800 total rows
SELECT COUNT(DISTINCT(visitor_id)) FROM visitors; -- 1800 distinct visitor_id's


-- ---------- BUSINESS ANALYSIS ---------- --
-- Q1: Which products have the highest total cart value?
SELECT
	p.product_id AS Product_ID,
    p.product_name AS Product_Name,
    p.category AS Product_Category,
    COUNT(DISTINCT(e.session_id)) AS Cart_Sessions,
    SUM(c.quantity) AS Total_Quantity,
    ROUND(SUM(c.quantity * p.unit_price),2) AS Cart_Value
FROM
	products p
    JOIN
    events e ON e.product_id = p.product_id
    JOIN
    cart_items c ON c.session_id = e.session_id
GROUP BY
	Product_ID,
    Product_Name,
    Product_Category
ORDER BY Cart_Value DESC
Limit 10;

-- Q2: Which traffic sources have a purchase conversion rate above 20%?
SELECT
	s.traffic_source AS Traffic_Source,
    COUNT(DISTINCT s.session_id) AS Total_Sessions,
    COUNT(DISTINCT t.session_id) AS Purchase_Sessions,
    ROUND(
		COUNT(DISTINCT t.session_id) / 
        COUNT(DISTINCT s.session_id) * 100, 2
	) AS Purchase_Conversion_Rate
FROM
	sessions s
    LEFT JOIN
    transactions t ON t.session_id = s.session_id
GROUP BY Traffic_Source
HAVING Purchase_Conversion_Rate > 20
ORDER BY Purchase_Conversion_Rate DESC;

-- Q3: Which product categories have the highest average order value?
SELECT
	p.category AS Product_Category,
    COUNT(DISTINCT t.transaction_id) AS Total_Transactions,
    ROUND(AVG(t.order_value), 2) AS Avg_Order_Value
FROM
	products p
    JOIN
    events e ON e.product_id = p.product_id
    JOIN
    transactions t ON t.session_id = e.session_id
WHERE e.event_type = 'transaction'
GROUP BY Product_Category
ORDER BY Avg_Order_Value DESC;

-- Q4: Which countries generate the highest average revenue per visitor?
SELECT
	v.country AS Country,
    COUNT(DISTINCT v.visitor_id) AS Total_Visitors,
    COUNT(DISTINCT t.transaction_id) AS Total_Transactions,
    ROUND(COALESCE(SUM(t.order_value), 0), 2) AS Total_Revenue,
    ROUND(
		COALESCE(SUM(t.order_value), 0)
        / COUNT(DISTINCT v.visitor_id),
        2
	) AS Revenue_Per_Visitor
FROM
	visitors v
    LEFT JOIN
	transactions t ON t.visitor_id = v.visitor_id
GROUP BY Country
ORDER BY Revenue_Per_Visitor DESC;

-- Q5: Which products have cart activity but no recorded purchase activity?
SELECT
    p.product_id AS Product_ID,
    p.product_name AS Product_Name,
    p.category AS Product_Category,
    COUNT(DISTINCT c.session_id) AS Cart_Sessions,
    SUM(c.quantity) AS Total_Quantity_Added,
    ROUND(
        SUM(c.quantity * p.unit_price),
        2
    ) AS Estimated_Cart_Value
FROM
	products p
	JOIN
	cart_items c ON p.product_id = c.product_id
	LEFT JOIN
	events e ON c.session_id = e.session_id AND c.product_id = e.product_id AND e.event_type = 'transaction'
GROUP BY
    Product_ID,
    Product_Name,
    Product_Category
ORDER BY Estimated_Cart_Value DESC
LIMIT 10;

-- Q6: How does monthly revenue change compared with the previous month?
WITH Monthly_Sales AS (
    SELECT
        DATE_FORMAT(transaction_date, '%Y-%m') AS Sales_Month,
        COUNT(transaction_id) AS Total_Transactions,
        SUM(order_value) AS Monthly_Revenue
    FROM transactions
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
),
Revenue_Comparison AS (
    SELECT
        Sales_Month,
        Total_Transactions,
        Monthly_Revenue,
        LAG(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Revenue
    FROM Monthly_Sales
)
SELECT
    Sales_Month,
    Total_Transactions,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,
    ROUND(Previous_Month_Revenue, 2) AS Previous_Month_Revenue,
    ROUND(
        Monthly_Revenue - Previous_Month_Revenue,
        2
    ) AS Revenue_Change
FROM Revenue_Comparison
ORDER BY Sales_Month;

-- Q7: What is the revenue ranking of each traffic source?
WITH source_revenue AS (
    SELECT
        s.traffic_source AS Traffic_Source,
        COUNT(DISTINCT s.session_id) AS Total_Sessions,
        COUNT(DISTINCT t.transaction_id) AS Total_Transactions,
        COALESCE(SUM(t.order_value), 0) AS Total_Revenue
    FROM sessions s
    LEFT JOIN transactions t
        ON s.session_id = t.session_id
    GROUP BY s.traffic_source
)
SELECT
    Traffic_Source,
    Total_Sessions,
    Total_Transactions,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    DENSE_RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Revenue_Rank
FROM source_revenue
ORDER BY Revenue_Rank;

-- Q8: Which devices have the most abandoned cart sessions?
WITH cart_sessions AS (
    SELECT
        s.session_id,
        s.device_type,
        MAX(
            CASE
                WHEN e.event_type = 'addtocart' THEN 1
                ELSE 0
            END
        ) AS Has_Cart,
        MAX(
            CASE
                WHEN e.event_type = 'transaction' THEN 1
                ELSE 0
            END
        ) AS Has_Purchase
    FROM sessions s
    INNER JOIN events e
        ON s.session_id = e.session_id
    GROUP BY s.session_id, s.device_type
)
SELECT
    device_type AS Device_Type,
    COUNT(*) AS Cart_Sessions,
    SUM(
        CASE WHEN Has_Purchase = 0 THEN 1 ELSE 0 END
    ) AS Abandoned_Cart_Sessions,
    ROUND(
        SUM(CASE WHEN Has_Purchase = 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS Abandonment_Rate
FROM cart_sessions
WHERE Has_Cart = 1
GROUP BY device_type
ORDER BY Abandonment_Rate DESC;

-- Q9: Which visitors have spent more than the average spending per visitor?
WITH visitor_spending AS (
    SELECT
        v.visitor_id,
        v.country,
        COUNT(t.transaction_id) AS Total_Transactions,
        SUM(t.order_value) AS Total_Spending
    FROM visitors v
    INNER JOIN transactions t
        ON v.visitor_id = t.visitor_id
    GROUP BY v.visitor_id, v.country
)
SELECT
    visitor_id,
    country,
    Total_Transactions,
    ROUND(Total_Spending, 2) AS Total_Spending
FROM visitor_spending
WHERE Total_Spending > (
    SELECT AVG(Visitor_Total)
    FROM (
        SELECT SUM(order_value) AS Visitor_Total
        FROM transactions
        GROUP BY visitor_id
    ) AS Visitor_Averages
)
ORDER BY Total_Spending DESC;

-- Q10: Which products are priced above their category's average price?
WITH product_pricing AS (
    SELECT
        product_id,
        product_name,
        category,
        unit_price,
        AVG(unit_price) OVER (
            PARTITION BY category
        ) AS Category_Average_Price,
        RANK() OVER (
            PARTITION BY category
            ORDER BY unit_price DESC
        ) AS Category_Price_Rank
    FROM products
)
SELECT
    product_id,
    product_name,
    category,
    unit_price,
    ROUND(Category_Average_Price, 2)
        AS Category_Avg_Price,
    Category_Price_Rank
FROM product_pricing
WHERE unit_price > Category_Average_Price
ORDER BY category, Category_Price_Rank;

