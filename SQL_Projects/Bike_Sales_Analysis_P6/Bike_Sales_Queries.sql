
				-------------------------------   Bike Sales Dataset  ------------------------------


/**  🗃️ SQL — 20 Medium-Difficult Questions:

 1. Who are the top 5 customers with the highest total spending?
 2. What is the average profit margin per product and per category?
 3. Calculate the average time between order date and shipping date for each store.
 4. What is the monthly sales trend in the last available year?
 5. Which products had at least 3 returned orders?
 6. How many orders were placed by customers who live in a different state than the store?
 7. Find the average number of products per order, by sales channel.
 8. What is the quarterly sales growth rate for each store?
 9. Which salespeople achieved at least 90% of their target (if available in the data)?
 10. Which customers purchased products from at least 4 different categories?
 11. What are the top 10 products with the highest unit margin (price - cost)?
 12. Calculate customer retention month by month (customers with at least 2 purchases).
 13. What is the average number of days between two consecutive purchases per customer?
 14. For each category, what is the percentage of products sold out of total inventory?
 15. Find the average order value per state.
 16. Which salespeople sold products only in certain months of the year?
 17. What is the average number of orders handled per salesperson?
 18. Find the correlation between product price and quantity sold (numerical output).
 19. Calculate how many orders consist exclusively of items that each have a discount greater than 10%, excluding any orders that contain at least one item with a discount of 10% or less.
 20. List customers who purchased the same product more than once.
 
**/




 -- Q 1. Who are the top 5 customers with the highest total spending? (ONLY Completed Orders)

	-- Approach 1. Considering ONLY - Completed - Orders 
SELECT c.customer_id, c.first_name, c.last_name, 
	ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount))
		, 0) AS total_spends
FROM customers c 
JOIN orders o ON o.customer_id = c.customer_id 
JOIN order_item oi ON oi.order_id =o.order_id  
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spends DESC
LIMIT 5;


	-- Approach 2. Considering all orders except - Rejected 
SELECT c.customer_id, c.first_name, c.last_name, 
	ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount))
		, 0) AS total_spends
FROM customers c 
JOIN orders o ON o.customer_id = c.customer_id 
JOIN order_item oi ON oi.order_id = o.order_id  
WHERE o.order_status <> 'Rejected'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spends DESC
LIMIT 5;





-- Q 2. What is the average revenue per product and per category?
SELECT category_name, p.product_name, 
	ROUND(
			AVG(oi.quantity * oi.list_price * (1 - oi.discount))
		, 2) avg_revenue
FROM order_item oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY ROLLUP (c.category_name, p.product_name)  
ORDER BY category_name;





-- Q 3. Calculate the average time between order date and shipping date for each store.
SELECT s.store_id, s.store_name, 
	ROUND(
			AVG((o.shipped_date - o.order_date))
		, 2) avg_shipping_time
FROM orders o 
JOIN stores s ON s.store_id = o.store_id
WHERE o.shipped_date IS NOT NULL
GROUP BY s.store_id, s.store_name;





-- Q 4. What is the monthly sales trend in the last available year? 

	-- Approach 1. Excluding - Rejected Orders
WITH last_year AS (
	SELECT order_id, order_status, DATE_TRUNC('month', order_date)::date order_month
	FROM orders 
	WHERE order_date > (SELECT MAX(order_date) - INTERVAL '1 year' FROM orders)
)
SELECT ly.order_month, 
	SUM(oi.quantity) qty_sold, 
	ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount))
		, 0) revenue
FROM order_item oi 
JOIN last_year ly ON oi.order_id = ly.order_id 
WHERE ly.order_status <> 'Rejected'
GROUP BY ly.order_month
ORDER BY ly.order_month;


	-- Approach 2. Inluding - Rejected Orders
WITH last_year AS (
	SELECT order_id, order_status, DATE_TRUNC('month', order_date)::date order_month
	FROM orders 
	WHERE order_date > (SELECT MAX(order_date) - INTERVAL '1 year' FROM orders)
	)
SELECT ly.order_month, 
	SUM(oi.quantity) qty_sold, 
	ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount))
		, 0) revenue
FROM order_item oi 
JOIN last_year ly ON oi.order_id = ly.order_id 
GROUP BY ly.order_month
ORDER BY ly.order_month;





-- Q 5. Which products had at least 3 returned orders?
SELECT p.product_name, COUNT(*) orders_returned
FROM orders o 
JOIN order_item oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'Rejected'
GROUP BY p.product_name
HAVING COUNT(*) >= 3
ORDER BY orders_returned DESC;





-- Q 6. How many orders were placed by customers who live in a different state than the store?
SELECT COUNT(*)
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN stores s ON s.store_id = o.store_id
WHERE c.state <> s.state;





-- Q 7. Find the average number of products per order
SELECT 
	ROUND(
			COUNT(*) * 1.0 / COUNT(DISTINCT order_id) 
		, 2) avg_products_per_order
FROM order_item; 





-- Q 8. What is the quarterly sales growth rate for each store?
WITH sales_per_quarter AS (
	SELECT s.store_name, DATE_TRUNC('quarter', o.order_date)::date quarter,
		ROUND(
				SUM(oi.quantity * oi.list_price * (1 - oi.discount))
			 , 0) total_revenue 
	FROM orders o
	JOIN order_item oi ON oi.order_id = o.order_id
	JOIN stores s ON s.store_id = o.store_id
	GROUP BY s.store_name, DATE_TRUNC('quarter', o.order_date)
)
SELECT *, 
	ROUND(
			(total_revenue - LAG(total_revenue) OVER(PARTITION BY store_name ORDER BY quarter)) * 100.0 / 
			 	NULLIF(LAG(total_revenue) OVER(PARTITION BY store_name ORDER BY quarter), 0)
		, 2) sales_growth_rate
FROM sales_per_quarter;





-- Q 9. Which salespeople achieved at least 90% of their target (if available in the data)?
WITH staff_sales_info AS (
	SELECT s.staff_id, s.first_name, s.last_name, s.sales_target,
		ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))
			 , 0) total_sold,
		ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount)) * 100 / s.sales_target
			, 2) sold_target_ratio
	FROM orders o
	JOIN order_item oi ON oi.order_id = o.order_id 
	JOIN staffs s ON s.staff_id = o.staff_id
	WHERE o.order_status <> 'Rejected'
	GROUP BY s.staff_id
) 
SELECT * 
FROM staff_sales_info 
WHERE sold_target_ratio >= 90;





 -- Q 10. Which customers purchased products from at least 4 different categories? 

 	-- ONLY Completed orders -- 
SELECT cust.customer_id, cust.first_name, cust.last_name,
	COUNT(DISTINCT p.category_id) no_of_categories,
	STRING_AGG(DISTINCT cat.category_name, ', ') AS category_names
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN customers cust ON cust.customer_id = o.customer_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.order_status = 'Completed'
GROUP BY cust.customer_id, cust.first_name, cust.last_name
HAVING COUNT(DISTINCT p.category_id) >= 4; 





-- Q 11. What are the 3 brands with the highest average revenue per order?
WITH sales_per_brand AS (
	SELECT b.brand_id, b.brand_name,
		COUNT(DISTINCT oi.order_id) total_orders,
		ROUND(
			SUM(oi.quantity * oi.list_price * (1 - oi.discount))
			, 0) total_revenue
	FROM order_item oi
	JOIN products p ON p.product_id = oi.product_id
	JOIN brands b ON b.brand_id = p.brand_id
	GROUP BY b.brand_id, b.brand_name
)
SELECT *,
	ROUND(
			total_revenue / total_orders
		, 2) avg_revenue_per_oorder
FROM sales_per_brand
ORDER BY avg_revenue_per_oorder DESC
LIMIT 3;





-- Q 12. Calculate customer retention month by month for each year.
WITH monthly_activity AS (
	SELECT DISTINCT customer_id,
		DATE_TRUNC('month', order_date)::date order_month
	FROM orders 
)
SELECT pma.order_month, 
	COUNT(DISTINCT pma.customer_id) previous_customers,
	COUNT(DISTINCT cma.customer_id) retained_customers,
	ROUND(
		COUNT(DISTINCT cma.customer_id) * 100.0 / COUNT(DISTINCT pma.customer_id) 
		, 1) retention_rate
FROM monthly_activity pma
LEFT JOIN monthly_activity cma 
	ON (pma.order_month + INTERVAL '1 month') = cma.order_month
	AND pma.customer_id = cma.customer_id
GROUP BY pma.order_month
ORDER BY pma.order_month;





 -- Q 13. What is the average number of days between two consecutive purchases per customer?

	-- Approach 1. avg order interval per each customer
WITH date_diff AS (
	SELECT customer_id, order_date,
		order_date - LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) date_diff
	FROM orders
)
SELECT customer_id, 
	ROUND(AVG(date_diff), 0) avg_order_interval
FROM date_diff 
WHERE date_diff IS NOT NULL 
GROUP BY customer_id
ORDER BY avg_order_interval


	-- Approach 2. global avg order interval
WITH date_diff AS (
	SELECT customer_id, order_date,
		order_date - LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS date_diff
	FROM orders
)
SELECT 
	ROUND(AVG(date_diff), 0) AS avg_order_interval_all_customers
FROM date_diff
WHERE date_diff IS NOT NULL





-- Q 14. For each category, show the total sales, the total inventory, and the percentage of products sold relative to the total inventory
WITH
	inventory AS (
		SELECT product_id, SUM(quantity) total_inventory 
		FROM stocks 
		GROUP BY product_id
	),
	sales AS (
		SELECT product_id, SUM(quantity) total_sold 
		FROM order_item 
		GROUP BY product_id
)
SELECT c.category_name, 
	SUM(s.total_sold) total_sold,
	SUM(i.total_inventory) total_inventory,
	ROUND(
			SUM(s.total_sold) * 100.0 / SUM(i.total_inventory)
		, 2) sold_out_pct
FROM inventory i 
JOIN sales s ON s.product_id = i.product_id
JOIN products p ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY sold_out_pct DESC;





-- Q 15. Find the average order value per state (Only Completed Orders). 
WITH order_revenue AS (
    SELECT o.order_id, o.customer_id,
           SUM(oi.list_price * oi.quantity * (1 - oi.discount)) revenue
    FROM orders o
    JOIN order_item oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id, o.customer_id
)
SELECT c.state,
       ROUND(AVG(o_rev.revenue)::numeric, 2) avg_order_value
FROM order_revenue o_rev
JOIN customers c ON c.customer_id = o_rev.customer_id
GROUP BY c.state
ORDER BY c.state;





-- Q 16. Which salespeople sold products only in certain months of the year?
SELECT s.staff_id, s.first_name, s.last_name, 
	STRING_AGG(DISTINCT TO_CHAR(o.order_date, 'Month'), ', ') month_sold 
FROM orders o 
JOIN staffs s ON o.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name 
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM o.order_date)) < 12
ORDER BY staff_id;





-- Q 17. What is the average number of orders handled per salesperson?
SELECT ROUND(COUNT(*) / COUNT(DISTINCT staff_id), 2) avg_orders_per_staff
FROM orders; 





-- Q 18. Find the correlation between product price and quantity sold (numerical output).
SELECT corr(total_sold, list_price) pearson_corr
FROM (
	SELECT product_id, SUM(quantity) total_sold, list_price
	FROM order_item
	GROUP BY product_id, list_price
) sub;





-- Q 19. Calculate how many orders consist exclusively of items that each have a discount greater than 10%, 
		-- excluding any orders that contain at least one item with a discount of 10% or less.
SELECT COUNT(*) AS total_orders
FROM (
    SELECT order_id
    FROM order_item
    GROUP BY order_id
    HAVING MAX(discount) <= 0.1
) sub;





-- Q 20. List customers who purchased the same product more than twice.
SELECT c.customer_id, c.first_name, c.last_name, oi.item_id, COUNT(*) purchase_count
FROM order_item oi 
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name, oi.item_id
HAVING COUNT(*) > 2
ORDER BY purchase_count DESC; 






SELECT * FROM brands; 
SELECT * FROM categories; 
SELECT * FROM staffs; 
SELECT * FROM stocks; 
SELECT * FROM stores; 
SELECT * FROM customers; 
SELECT * FROM order_item; 
SELECT * FROM orders; 
SELECT * FROM products;






























