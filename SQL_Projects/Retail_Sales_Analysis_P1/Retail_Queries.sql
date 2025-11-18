

          -- Data Cleaning

SELECT * FROM retail_sales
WHERE transactions_id IS NULL;


SELECT * FROM retail_sales
WHERE sale_date IS NULL;

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL
	OR customer_id IS NULL OR gender IS NULL OR age IS NULL
	OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL
	OR cogs IS NULL OR total_sale IS NULL;


DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL
	OR customer_id IS NULL OR gender IS NULL OR age IS NULL
	OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL
	OR cogs IS NULL OR total_sale IS NULL;





-- Data Exploration


-- How many sales we have?
SELECT COUNT(*) AS total_sale FROM retail_sales;


-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;


-- Which categories we have?
SELECT DISTINCT category FROM retail_sales;







          -- Data Analysis & Business Key Problems



-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';



-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and 
--the quantity sold is more than 4 in the month of Nov-2022:
SELECT * 
FROM retail_sales
WHERE 
	category = 'Clothing' 
	AND quantity = 4
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';



-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) as total_sold
FROM retail_sales
GROUP BY category;



-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' catgory.
SELECT CAST(AVG(age) AS DECIMAL (10,2)) as avg_age 
FROM retail_sales
WHERE category = 'Beauty';



-- Q.5 Write a SQL query to find all transactions where the total_sale is grater than 1000.
SELECT transactions_id
FROM retail_sales
WHERE total_sale > 1000;



-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT gender, category, COUNT(transactions_id) AS transactions_count
FROM retail_sales
GROUP BY category, gender;



-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
SELECT EXTRACT(MONTH FROM sale_date), CAST(AVG(total_sale) AS DECIMAL (10, 2)) AS avg_sold
FROM retail_sales
GROUP BY EXTRACT(MONTH FROM sale_date)
ORDER BY avg_sold DESC;



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT customer_id, SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;



-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT COUNT(DISTINCT customer_id) 
FROM retail_sales
WHERE 
	category = 'Clothing' 
	AND category = 'Beauty' 
	AND category = 'Electronics';




-- Q.10 Write a SQL query to create each shift and number of orders.
WITH shift_cte AS 
(
SELECT *,
CASE
	WHEN EXTRACT(HOUR FROM sale_time) <12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN EXTRACT(HOUR FROM sale_time) >17 THEN 'Evening'
END AS shift
FROM retail_sales
)
SELECT shift, COUNT(transactions_id) AS total_orders
FROM shift_cte
GROUP BY shift
ORDER BY total_orders DESC;



-- Q.11 Write a SQL query to find a day of the week with highest total sales.
SELECT 
	TO_CHAR(sale_date, 'day') AS "weekday", 
	SUM(total_sale) AS total_sold 
FROM retail_sales
GROUP BY "weekday"
ORDER BY 2 DESC;



--Q.12 Write a SQL query to calculate total profit for each category.
SELECT 
	category, 
	CAST(SUM(total_sale - cogs) AS DECIMAL (10, 2)) AS total_revenue 
FROM retail_sales
GROUP BY category;



--Q.13 Write a SQL query to find the number of unique customers who purchased for at least 2 different categories.
SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) >=2;



--Q.14 Write a SQL query to identify customers who spent more than the global average.
WITH global_avg AS 
(
    SELECT AVG(total_sale) AS avg_sale
    FROM retail_sales
)
SELECT customer_id
FROM retail_sales, global_avg
GROUP BY customer_id, avg_sale
HAVING AVG(total_sale) > avg_sale;



--Q.15 Write a SQL query to calculate the number of transactions and the average of total sales per gender, for customers under 40 years.
SELECT 
	gender, 
	COUNT(*) AS num_of_sales,
	CAST(AVG(total_sale) AS DECIMAL (10, 2)) AS avg_sales
FROM retail_sales
WHERE age < 40
GROUP BY gender;
