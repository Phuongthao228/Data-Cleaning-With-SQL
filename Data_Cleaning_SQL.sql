SELECT * FROM customer_orders
-- 1. Standardize the order_status column
SELECT order_status,
CASE 
	WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
	WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
	WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
	WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
	WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
END AS cleaned_order_status
FROM customer_orders
-- 2. Standardize the product_name column
SELECT product_name,
CASE 
	WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
	WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
	WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
	WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
	WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
	ELSE 'Other'
END AS cleaned_product_name
FROM customer_orders
-- 3. Clean quantity column
SELECT quantity,
CASE 
	WHEN LOWER(quantity) ='two' THEN 2
	ELSE CAST(quantity as INT)
END AS cleaned_quantity
FROM customer_orders
-- 4. Handle missing values in customer_name
SELECT customer_name, email,
CASE 
	WHEN customer_name ='Null'
	THEN
    CONCAT(
        UPPER(LEFT(TRIM(email),1)),
        LOWER(SUBSTRING(TRIM(email),2,CHARINDEX('@',TRIM(email))-2)))
	ELSE customer_name
END AS cleaned_customer_name
FROM customer_orders;
-- 5. Standardize the country column
SELECT country,
CASE 
	WHEN LOWER(country) LIKE '%uk%' THEN 'United Kingdom'
	WHEN LOWER(country) LIKE '%canada%' THEN 'Canada'
	WHEN LOWER(country) LIKE '%india%' THEN 'India'
	WHEN LOWER(country) LIKE '%spain%' THEN 'Spain'
	WHEN LOWER(country) LIKE '%us%' THEN 'United States'
	ELSE country
END AS cleaned_country
FROM customer_orders
-- 6. Remove duplicate orders
SELECT *
FROM
	(SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY LOWER(Email), LOWER(product_name)
			ORDER BY order_id
		) AS rn
	FROM customer_orders) as sub
WHERE rn=1
-- 7. Final clean data
WITH Cleaned_data as (
	SELECT order_id,
-- customer_name
	CASE 
		WHEN customer_name ='Null'
		THEN CONCAT(UPPER(LEFT(TRIM(email),1)),LOWER(SUBSTRING(TRIM(email),2,CHARINDEX('@',TRIM(email))-2)))
		ELSE customer_name
	END AS customer_name,
	email,
	order_date,
-- product_name
	CASE 
		WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
		WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
		WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
		WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
		WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
		ELSE 'Other'
	END AS product_name,
-- quantity
	CASE 
		WHEN LOWER(quantity) ='two' THEN 2
		ELSE CAST(quantity AS INT)
	END AS quantity,
-- price
	price,
-- country
	CASE 
		WHEN LOWER(country) LIKE '%uk%' THEN 'United Kingdom'
		WHEN LOWER(country) LIKE '%canada%' THEN 'Canada'
		WHEN LOWER(country) LIKE '%india%' THEN 'India'
		WHEN LOWER(country) LIKE '%spain%' THEN 'Spain'
		WHEN LOWER(country) LIKE '%us%' THEN 'United States'
		ELSE country
	END AS country,
-- order_status
	CASE 
		WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
		WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
		WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
		WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
		WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
	END AS order_status
FROM customer_orders
),

-- remove duplicate
Final_table AS(
SELECT * FROM (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY LOWER(Email), LOWER(product_name)
			ORDER BY order_id
		) AS rn
	FROM Cleaned_data
) deduplicate_data
WHERE rn=1)
SELECT * FROM Final_table