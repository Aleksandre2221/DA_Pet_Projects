
			-- All The Questions -- 
-- 1. Count the number of Movies vs TV shows
-- 2. Find the most common rating for movies and TV shows
-- 3. List all movies released in a specific year (e.g. 2020)
-- 4. Find rhe top 5 countries with the most content on Netflix
-- 5. Identify the longesst movie or TV show duration
-- 6. Find content added in the last 5 years
-- 7. Find all the movies / TV shows by director 'Rajiv Chilaka'
-- 8. List all the Tv shows with more than 5 seasons
-- 9. Count the number of content items in each genre
-- 10. Find each year and the average number of content release by India on netflix. Return top 5 years with highest avg content release
-- 11. List all the movies that are Documentaries
-- 12. Find all content without director
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description filed. Label content containing these
-- keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

											

-- 1. Count the number of Movies vs TV shows

SELECT 
	type, 
	COUNT(*)  
FROM netflix
GROUP BY type;



-- 2. Find the most common rating for movies and TV shows

WITH ranked_ratings AS (
SELECT 	
	type, 
	rating,
	COUNT(rating) as count,
	ROW_NUMBER() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as rn
FROM netflix
GROUP BY type, rating
)
SELECT 
	type, 
	rating,
	count
FROM ranked_ratings
WHERE rn = 1;




-- 3. List all movies released in a specific year (e.g. 2020)

SELECT 
	title, 
	type,
	release_year 
FROM netflix
WHERE release_year = 2020
	  AND type = 'Movie';




-- 4. Find rhe top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ', ')) as country,
	COUNT(*)
FROM netflix
GROUP BY country
ORDER BY 2 DESC
LIMIT 5;



-- 5. Identify the longesst movie or TV show duration

SELECT
	title,
	CAST(REPLACE(duration, 'min', '') AS INTEGER) AS duration_minutes
FROM 
	netflix
WHERE
	type = 'Movie'
	AND duration IS NOT NULL
ORDER BY
	duration_minutes DESC
LIMIT 1;




-- 6. Find content added in the last 5 years

-- WITH year_transform AS 
-- (
-- SELECT 	
-- 	title,
-- 	CAST(SPLIT_PART(date_added, ',', 2) AS INTEGER) as year_of_addition
-- FROM netflix
-- )
-- SELECT *
-- FROM year_transform
-- WHERE year_of_addition >= 2020
-- ORDER BY 2;



SELECT 
	title,
	date_added
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years';





-- 7. Find all the movies / TV shows by director 'Rajiv Chilaka'

SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';





-- 8. List all the Tv shows with more than 5 seasons

SELECT 
	type,
	SPLIT_PART(duration, ' ', 1)::numeric as seasons
FROM netflix
WHERE 
	type = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::numeric > 5
ORDER BY 2;





-- 9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
	COUNT(title) as num_of_content
FROM netflix
GROUP BY genre
ORDER BY 2 DESC;




-- 10. Find each year and the average number of content release by India on netflix. Return top 5 years with highest avg content release

SELECT 
	country,
	release_year,
	COUNT(*)
FROM  netflix
WHERE  country ILIKE '%India%'
GROUP BY release_year, country
ORDER BY 3 DESC
LIMIT 5;




-- 11. List all the movies that are Documentaries

SELECT 
	type, 
	title,
	listed_in
FROM netflix
WHERE listed_in ILIKE '%Documentaries%' AND type = 'Movie';




-- 12. Find all content without director

SELECT * FROM netflix
WHERE director IS NULL;




-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT * 
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '11 years');




-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
	country, 
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as actor,
	COUNT(*)
FROM netflix
WHERE 
	 country ILIKE '%India%'
GROUP BY actor, country
ORDER BY 3 DESC
LIMIT 10;




-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description filed. Label content containing these
-- keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

WITH new_label AS
(
SELECT 
	*,
CASE
	WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
END as Label
FROM netflix
)
SELECT  
	Label,
	COUNT(*) as total_count
FROM new_label
GROUP BY Label


