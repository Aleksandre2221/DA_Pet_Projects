
			--- All The Questions -- 
-- Q 1. Write a SQL query to find the total no of Olympic Games held as per the dataset. 
-- Q 2. Write a SQL query to list down all the Olympic Games held so far.
-- Q 3. SQL query to fetch total no of countries participated in each olympic games.
-- Q 4. Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.
-- Q 5. SQL query to return the list of countries who have been part of every Olympics games.
-- Q 6. SQL query to fetch the list of all sports which have been part of every summer olympics.
-- Q 7. Using SQL query, Identify the sport which were just played once in all of olympics.
-- Q 8. Write SQL query to fetch the total no of sports played in each olympics.
-- Q 9. Write SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
-- Q 10. Write a SQL query to get the ratio of male and female participants
-- Q 11. SQL query to fetch the top 5 athletes who have won the most gold medals.
-- Q 12. SQL Query to fetch the top 5 athletes who have won the most medals
-- Q 13. Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).
-- Q 14. Write a SQL query to list down the total gold, silver and bronze medals won by each country.
-- Q 15. Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.
-- Q 16. Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.
-- Q 17. Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals. 
	 -- Along with this, identify also the country with the most medals in each olympic games.
-- Q 18. Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.
-- Q 19. Write SQL Query to return the sport which has won India the highest no of medals.		
-- Q 20. Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 		
-- Q 21. Find the country that has won the highest number of medals in the Summer Olympic Games. 	
-- Q 22. List the top 5 athletes with the most medals won (even if multiple medals in the same year). 
-- Q 23. All Olympic Games where India won medals in Hockey 
-- Q 24. For each country, show the sport in which they won the most medals.
-- Q 25. Average age of medalists by medal type (Gold, Silver, Bronze)
-- Q 26. For each Olympic edition, show the number of medals won by Team USA
-- Q 27. Female athletes who won gold medals before 1950. List name, year, and sport.
-- Q 28. Countries that won at least one of each medal type: Gold, Silver, and Bronze.
-- Q 29. Average height and weight of athletes by sport
-- Q 30. Athletes with the same name but different nationalities
-- Q 31. The event with the highest total number of awarded medals (excluding 'NA').
-- Q 32. Sports practiced in both Summer and Winter Olympics
-- Q 33. Top 5 oldest athletes who won a medal
-- Q 34. Athletes who participated in more than 4 editions
-- Q 35. Medal-to-participation ratio by country




-- Q 1. Write a SQL query to find the total no of Olympic Games held as per the dataset. 
SELECT COUNT(DISTINCT games) FROM olympics_total;



-- Q 2. Write a SQL query to list down all the Olympic Games held so far.
SELECT DISTINCT year, season, city
FROM olympics_total
ORDER BY year;



-- Q 3. SQL query to fetch total no of countries participated in each olympic games.

-- VAR 1. My approach (very slow)
SELECT games, COUNT(DISTINCT noc) AS num_of_countries
FROM olympics_total
GROUP BY games;


-- VAR 2. The Best Approach
WITH all_countries AS
	(SELECT games, oreg.region 
	 FROM olympics_total AS ot
	 JOIN olympics_regions AS oreg
	 	ON ot.noc = oreg.noc
	 GROUP BY games, region)

SELECT games, COUNT(1) total_countries
FROM all_countries
GROUP BY games 
ORDER BY games




-- Q 4. Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

-- VAR 1. With - CTE
WITH 
	t1 AS 
		(SELECT games, COUNT(DISTINCT noc) AS num_of_countries
		 FROM olympics_total
		 GROUP BY games),
		 
	t2 AS
		(SELECT CONCAT(games, ' - ', num_of_countries) AS lowest_countries
		 FROM t1
		 WHERE num_of_countries = (SELECT MIN(num_of_countries) FROM t1)),
		 
	t3 AS 
		(SELECT CONCAT(games, ' - ', num_of_countries) AS highest_countries
		 FROM t1
		 WHERE num_of_countries = (SELECT MAX(num_of_countries) FROM t1))
		 
SELECT * FROM t2, t3;


-- VAR 2. With - SubQery
SELECT

	(SELECT CONCAT(games, ' - ', COUNT(DISTINCT team))
	 FROM olympics_total
	 GROUP BY games
	 ORDER BY COUNT(DISTINCT team)
	 LIMIT 1) AS lowest_countries,

	 (SELECT CONCAT(games, ' - ', COUNT(DISTINCT team))
	  FROM olympics_total
	  GROUP BY games
	  ORDER BY COUNT(DISTINCT team) DESC
	  LIMIT 1) AS highest_countries;



-- VAR 3. The Best Approach
WITH
	all_countries AS
		(SELECT games, oreg.noc
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS oreg 
		 	ON ot.noc = oreg.noc
		 GROUP BY games, oreg.noc),
		 
	countries_cnt AS 
		(SELECT games, COUNT(1) AS total_countries
		 FROM all_countries
		 GROUP BY games)
		 
SELECT DISTINCT
	CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries), ' - ',
		FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS lowest_countries,
	CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC), ' - ',
		FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) AS highest_countries
FROM countries_cnt;



-- Q 5. SQL query to return the list of countries who have been part of every Olympics games.
SELECT * FROM olympics_total


-- VAR 1. My approach
WITH 
	groupped_games AS
		(SELECT games, team, COUNT(DISTINCT team) as cnt
		 FROM olympics_total
		 GROUP BY games, team),

	countries_dist_cnt AS
		(SELECT DISTINCT team, SUM(cnt) OVER(PARTITION BY team) AS total_participated_games
	     FROM groupped_games)

SELECT *
FROM countries_dist_cnt
WHERE total_participated_games = (SELECT COUNT(DISTINCT games) FROM olympics_total);


-- VAR 2. Approccio di GPT - piu veloce e efficace
WITH 
	participations AS 
		(SELECT DISTINCT games, team 
		 FROM olympics_total),

	total_participations AS 
		(SELECT team, COUNT(*) AS total_games
		 FROM participations
		 GROUP BY team)

SELECT *
FROM total_participations
WHERE total_games = (SELECT COUNT(DISTINCT games) FROM olympics_total);


-- VAR 3. The best approcah

WITH 
	total_games AS 
		(SELECT COUNT(DISTINCT games) AS total_games
		 FROM olympics_total),

	all_countries AS 
		(SELECT games, oreg.region
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS oreg
		 	ON ot.noc = oreg.noc
		 GROUP BY games, region),

	participations AS 
		(SELECT region, COUNT(1) AS total_participations
		 FROM all_countries
		 GROUP BY region)

SELECT *
FROM participations AS p
JOIN total_games AS tg
	ON tg.total_games = p.total_participations 
	



-- Q 6. SQL query to fetch the list of all sports which have been part of every summer olympics.

-- VAR 1. My approach - With - CTE
WITH 
	summer_games AS
		(SELECT DISTINCT games, sport
		 FROM olympics_total
		 WHERE season = 'Summer'),

	summer_sports_cnt AS
		(SELECT sport, COUNT(*) AS cnt
		 FROM summer_games
		 GROUP BY sport)

SELECT *
FROM summer_sports_cnt
WHERE cnt = (SELECT COUNT(DISTINCT games) 
			 FROM olympics_total 
			 WHERE season = 'Summer');


-- VAR 2. VAR 2. With - JOIN
WITH
	summer_games_cnt AS 
		(SELECT COUNT(DISTINCT games) AS total_summer_games
		 FROM olympics_total
		 WHERE season = 'Summer'),

	summer_sports_cnt AS
		(SELECT DISTINCT games, sport
		 FROM olympics_total
		 WHERE season = 'Summer'
		 ORDER BY games),

	sport_groups AS
		(SELECT sport, COUNT(*) AS cnt
		 FROM summer_sports_cnt
		 GROUP BY sport)

SELECT *
FROM sport_groups AS sg
JOIN summer_games_cnt AS sgc
	ON sg.cnt = sgc.total_summer_games;
	



-- Q 7. Using SQL query, Identify the sport which were just played once in all of olympics.


-- VAR 1. My Approach
EXPLAIN ANALYZE
SELECT sport, COUNT(DISTINCT games), MIN(games)
FROM olympics_total
GROUP BY sport
HAVING COUNT(DISTINCT games) = 1


-- VAR 2. GPT Approch
EXPLAIN ANALYZE
WITH sport_games AS (
	SELECT sport, games
	FROM olympics_total
	GROUP BY sport, games
)
SELECT sport, COUNT(*) AS total_games, MIN(games) AS first_game
FROM sport_games
GROUP BY sport
HAVING COUNT(*) = 1;


-- VAR 3. The best approach
WITH 
	dist_sport_game AS 
		(SELECT DISTINCT sport, games 
		 FROM olympics_total),

	sport_cnt AS 
		(SELECT sport, COUNT(1) AS cnt
		 FROM dist_sport_game
		 GROUP BY sport)

SELECT sc.*, dsg.games
FROM sport_cnt AS sc
JOIN dist_sport_game AS dsg
	ON sc.sport = dsg.sport
WHERE cnt = 1;
	



-- Q 8. Write SQL query to fetch the total no of sports played in each olympics.

-- VAR 1. First Approach
SELECT games, COUNT(DISTINCT sport)
FROM olympics_total
GROUP BY games;


-- VAR 2. 
WITH
	games_sport AS 
		(SELECT DISTINCT games, sport
		 FROM olympics_total)

SELECT games, COUNT(*) AS total_sports
FROM games_sport
GROUP BY games
ORDER BY total_sports DESC;
	



-- Q 9. Write SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

-- VAR 1. My approach
WITH
	max_age AS
		(SELECT MAX(CAST(age AS INT)) AS max_age
		 FROM olympics_total
		 WHERE medal = 'Gold' AND age <> 'NA'),

	gold_medal AS 
		(SELECT *
		 FROM olympics_total
		 WHERE medal = 'Gold')

SELECT *
FROM gold_medal AS gm
JOIN max_age AS ma
	ON gm.age = CAST(ma.max_age AS VARCHAR(3))


-- VAR 2. Fastest Approach
WITH 
	age_cast AS 
		(SELECT name, sex, CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS INT) AS age, 
			team, games, city, sport, event, medal
		 FROM olympics_total),

	ranking AS 
		(SELECT *, RANK() OVER(ORDER BY age DESC) AS rnk
		 FROM age_cast
		 WHERE medal = 'Gold')

SELECT *
FROM ranking
WHERE rnk = 1
	



-- Q 10. Write a SQL query to get the ratio of male and female participants

-- VAR 1. My Approach
WITH 
	females AS (SELECT COUNT(*) * 1.0 AS cnt FROM olympics_total WHERE sex = 'F'),
	males AS (SELECT COUNT(*) * 1.0 AS cnt FROM olympics_total WHERE sex = 'M')
	
SELECT males.cnt / females.cnt
FROM males, females


-- VAR 2. GPT Approach - CASE
SELECT 
	SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) * 1.0 /
	NULLIF(SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END), 0) AS male_female_ratio
FROM olympics_total


-- VAR 3. GPT Approach - FILTER
SELECT 
	COUNT(*) FILTER(WHERE sex = 'M') * 1.0 /
	NULLIF(SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END), 0) AS male_female_ratio
FROM olympics_total


-- VAR 4. Expected Output
SELECT 
	CONCAT(
		'1:', 
		CAST(
			COUNT(*) FILTER(WHERE sex = 'M') * 1.0 /
			NULLIF(SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END), 0) 
		AS DECIMAL (10, 2)
		)
	) AS male_female_ratio
FROM olympics_total


-- VAR 5. The best approach
WITH
	t1 AS 
		(SELECT sex, COUNT(*) AS cnt
		 FROM olympics_total
		 GROUP BY sex),

	t2 AS 
		(SELECT *, 
			ROW_NUMBER() OVER(ORDER BY cnt) AS rn
		 FROM t1),

	min_cnt AS 
		(SELECT cnt FROM t2 WHERE rn = 1),

	max_cnt AS 
		(SELECT cnt FROM t2 WHERE rn = 2)
	
SELECT CONCAT('1:', ROUND(max_cnt.cnt::DECIMAL/min_cnt.cnt, 2)) AS ration
FROM min_cnt, max_cnt




-- Q 11. SQL query to fetch the top 5 athletes who have won the most gold medals.

-- VAR 1. My approach - IS NOT CORRECT
SELECT name, team, COUNT(*) AS total_medals
FROM olympics_total
WHERE medal = 'Gold'
GROUP BY name, team
ORDER BY total_medals DESC
LIMIT 5


-- VAR 2. The best approach
WITH
	gold_medals AS 
		(SELECT name, team, COUNT(*) AS total_gold_medals
		 FROM olympics_total
		 WHERE medal = 'Gold'
		 GROUP BY name, team),

	ranking AS 
		(SELECT *,
			DENSE_RANK() OVER(ORDER BY total_gold_medals DESC) AS rn
		 FROM gold_medals)

SELECT name, team, total_gold_medals 
FROM ranking
WHERE rn <= 5




-- Q 12. SQL Query to fetch the top 5 athletes who have won the most medals
WITH 
	total_medals AS 
		(SELECT name, team, COUNT(*) AS total_medals
		FROM olympics_total
		WHERE medal <> 'NA'
		GROUP BY name, team),

	top_five AS 
		(SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rk
		 FROM total_medals)

SELECT name, team, total_medals
FROM top_five
WHERE rk <= 5




-- Q 13. Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).

-- VAR 1. My approach - the best one
WITH
	top_countries AS 
		(SELECT reg.region, COUNT(*) AS total_medals
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg
		 	ON ot.noc = reg.noc
		 WHERE medal <> 'NA'
		 GROUP BY region),

	ranking AS 
		(SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rn
		 FROM top_countries)

SELECT region, total_medals
FROM ranking
WHERE rn <= 5



-- VAR 2. My approach - For rapid analysis
WITH
	top_countries AS 
		(SELECT team, COUNT(*) AS total_medals
		 FROM olympics_total
		 WHERE medal <> 'NA'
		 GROUP BY team),

	ranking AS 
		(SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rn
		 FROM top_countries)

SELECT team, total_medals
FROM ranking
WHERE rn <= 5




-- Q 14. Write a SQL query to list down the total gold, silver and bronze medals won by each country.

-- VAR 1. My First Approach - (260 ms)
WITH
	countries AS 
		(SELECT reg.region AS country, medal
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg
		 	ON ot.noc = reg.noc
		 WHERE ot.medal <> 'NA')

SELECT DISTINCT
	country,
	COUNT(medal) FILTER(WHERE medal = 'Gold') OVER(PARTITION BY country) AS gold,
	COUNT(medal) FILTER(WHERE medal = 'Silver') OVER(PARTITION BY country) AS silver,
	COUNT(medal) FILTER(WHERE medal = 'Bronze') OVER(PARTITION BY country) AS bronze
FROM countries
ORDER BY gold DESC


-- VAR 2. My Second Approach - The best - (153 ms)
WITH
	countries AS 
		(SELECT reg.region AS country, ot.medal
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg
		 	ON ot.noc = reg.noc
		 WHERE ot.medal <> 'NA')
SELECT
	country,
	COUNT(medal) FILTER(WHERE medal = 'Gold') AS gold,
	COUNT(medal) FILTER(WHERE medal = 'Silver') AS silver,
	COUNT(medal) FILTER(WHERE medal = 'Bronze') AS bronze
FROM countries
GROUP BY country
ORDER BY gold DESC



-- VAR 3. Not my approach - CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT country,
	COALESCE(gold, 0) AS gold,
	COALESCE(silver, 0) AS silver,
	COALESCE(bronze, 0) AS bronze
FROM CROSSTAB (
				'SELECT reg.region AS country, ot.medal, COUNT(1) AS total_medals
				FROM olympics_total AS ot
				JOIN olympics_regions AS reg ON ot.noc = reg.noc
				WHERE medal <> ''NA''
				GROUP BY reg.region, ot.medal
				ORDER BY reg.region, ot.medal',

				'values (''Gold''), (''Silver''), (''Bronze'')'
			  )
AS medals_per_country(country VARCHAR, Gold BIGINT, Silver BIGINT, Bronze BIGINT)
ORDER BY gold DESC;




-- Q 15. Write a SQL query to list down the  total gold, silver and bronze medals won by each country corresponding to each olympic games.

-- VAR 1. Fisrt Approach
 WITH 
	countries AS 
		(SELECT ot.games, reg.region AS country, ot.medal
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg
		 	ON ot.noc = reg.noc
		 WHERE ot.medal <> 'NA')
		 
SELECT games, country,
	COUNT(*) FILTER(WHERE medal = 'Gold') AS max_gold,
	COUNT(*) FILTER(WHERE medal = 'Silver') AS max_silver,
	COUNT(*) FILTER(WHERE medal = 'Bronze') AS max_bronze
FROM countries
GROUP BY games, country 
ORDER BY games, country



-- VAR 2. Second Approach - CROSSTAB
SELECT 
	SPLIT_PART(row_id, '|', 1) AS games,
	SPLIT_PART(row_id, '|', 2) AS country,
	COALESCE(gold, 0) AS max_gold,
	COALESCE(silver, 0) AS max_silver,
	COALESCE(bronze, 0) AS max_bronze
FROM CROSSTAB (
				$$
					SELECT 
						ot.games || '|' || reg.region AS row_id, 
						medal,
						COUNT(*) AS total_medals
					FROM olympics_total AS ot
					JOIN olympics_regions AS reg
						ON ot.noc = reg.noc
					WHERE medal <> 'NA'
					GROUP BY games, reg.region, medal
					ORDER BY row_id, medal
				$$,
				$$ VALUES ('Gold'), ('Silver'), ('Bronze') $$
) AS final(row_id VARCHAR, gold BIGINT, silver BIGINT, bronze BIGINT)




-- Q 16. Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.

-- VAR 1. 
WITH
	countries AS 
		(SELECT games, reg.region AS country, medal
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg
		 	ON ot.noc = reg.noc
		 WHERE medal <> 'NA'),

	medal_type AS 
		(SELECT games, country, 
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold,
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze 
		 FROM countries
		 GROUP BY games, country
		 ORDER BY games, country),

		 
	max_gold AS 
		(SELECT games, country, gold
		 FROM medal_type
		 WHERE (games, gold) IN (SELECT games, MAX(gold)
		 						 FROM medal_type
								 GROUP BY games)),

	max_silver AS 
		(SELECT games, country, silver
		 FROM medal_type 
		 WHERE (games, silver) IN (SELECT games, MAX(silver)
		 						   FROM medal_type
								   GROUP BY games)),

	max_bronze AS 
		(SELECT games, country, bronze
		 FROM medal_type 
		 WHERE (games, bronze) IN (SELECT games, MAX(bronze)
		 						   FROM medal_type
								   GROUP BY games))

SELECT mg.games,
	CONCAT(mg.country, ' - ', mg.gold) AS max_gold,
	CONCAT(ms.country, ' - ', ms.silver) AS max_silver,
	CONCAT(mb.country, ' - ', mb.bronze) AS max_bronze
FROM max_gold AS mg
JOIN max_silver AS ms ON mg.games = ms.games
JOIN max_bronze AS mb ON ms.games = mb.games



-- VAR 2.
WITH 
	country_medals AS 
		(SELECT games, reg.region AS country,
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold,
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg ON ot.noc = reg.noc
		 WHERE medal <> 'NA'
		 GROUP BY games, reg.region
		 ORDER BY games, country),

	gold_medals AS 
		(SELECT games, country, gold,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY gold DESC) AS rn
		 FROM country_medals),

	silver_medals AS 
		(SELECT games, country, silver,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY silver DESC) AS rn
		 FROM country_medals),

	bronze_medals AS 
		(SELECT games, country, bronze, 
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY bronze DESC) AS rn
		 FROM country_medals)

SELECT gm.games,
	CONCAT(gm.country, ' - ', gm.gold) AS max_gold,
	CONCAT(sm.country, ' - ', sm.silver) AS max_silver,
	CONCAT(bm.country, ' - ', bm.bronze) AS max_bronze
FROM gold_medals AS gm
JOIN silver_medals AS sm ON gm.games = sm.games
JOIN bronze_medals AS bm ON gm.games = bm.games
WHERE gm.rn = 1 AND sm.rn = 1 AND bm.rn = 1
ORDER BY gm.games



-- VAR 3. 
WITH 
	countries_medals AS 
		(SELECT games, reg.region AS country, 
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold,
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg ON ot.noc = reg.noc
		 WHERE medal <> 'NA'
		 GROUP BY games, reg.region
		 ORDER BY games, reg.region)

SELECT DISTINCT ON (games)
	games, 
	CONCAT(
			FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY gold DESC), 
			' - ',
			FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)
		) AS max_gold,

	CONCAT(
			FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY silver DESC), 
			' - ',
			FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)
		) AS max_silver,

	CONCAT(
			FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY bronze DESC), 
			' - ',
			FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)
		) AS max_bronze
FROM countries_medals
ORDER BY games




-- Q 17. Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals. 
-- 			Along with this, identify also the country with the most medals in each olympic games.
WITH
	countries AS 
		(SELECT games, reg.region AS country, medal
		 FROM olympics_total AS ot
		 JOIN olympics_regions AS reg ON ot.noc = reg.noc
		 WHERE medal <> 'NA'),

	countries_medals AS 
		(SELECT games, country,
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold,
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze
		 FROM countries
		 GROUP BY games, country),

	max_gold AS 
		(SELECT games, country, gold,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY gold DESC) AS rn
		 FROM countries_medals),

	max_silver AS 
		(SELECT games, country, silver,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY silver DESC) AS rn
		 FROM countries_medals),

	max_bronze AS 
		(SELECT games, country, bronze,
			ROW_NUMBER() OVER(PARTITION BY games ORDER BY bronze DESC) AS rn
		 FROM countries_medals),

	total_medals_ranked AS 
		(SELECT *, ROW_NUMBER() OVER(PARTITION BY games ORDER BY total_medals DESC) AS rn
		 FROM 
			(SELECT games, country, COUNT(*) as total_medals
			 FROM countries
			 GROUP BY games, country
			 ORDER BY games, country)
		  )
			
SELECT mg.games,
	CONCAT(mg.country, ' - ', mg.gold) AS max_gold,
	CONCAT(ms.country, ' - ', ms.silver) AS max_silver,
	CONCAT(mb.country, ' - ', mb.bronze) AS max_bronze,
	CONCAT(tmr.country, ' - ', tmr.total_medals) AS max_total_medals
FROM max_gold mg
JOIN max_silver ms ON mg.games = ms.games
JOIN max_bronze mb ON mg.games = mb.games
JOIN total_medals_ranked tmr ON mg.games = tmr.games
WHERE mg.rn = 1 AND ms.rn = 1 AND mb.rn = 1 AND tmr.rn = 1
ORDER BY games




-- Q 18. Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.
WITH
	filtred_countries AS
		(SELECT reg.region AS country,
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold, 
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze
		 FROM olympics_total ot
		 JOIN olympics_regions reg ON ot.noc = reg.noc
		 WHERE medal <> 'NA'
		 GROUP BY reg.region)
SELECT *
FROM filtred_countries
WHERE gold = 0 AND (silver > 0 OR bronze > 0) 
ORDER BY silver DESC




-- Q 19. Write SQL Query to return the sport which has won India the highest no of medals.		
SELECT sport, COUNT(NULLIF(medal, 'NA')) AS total_medals
FROM olympics_total ot
JOIN olympics_regions reg ON ot.noc = reg.noc
WHERE reg.region = 'India' AND medal <> 'NA'
GROUP BY sport
ORDER BY total_medals DESC
LIMIT 1




-- Q 20. Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 		
SELECT team, sport, games, COUNT(medal) AS total_medals
FROM olympics_total 
WHERE team = 'India' AND sport = 'Hockey' AND medal <> 'NA'
GROUP BY team, sport, games
ORDER BY total_medals DESC




-- Q 21. Find the country that has won the highest number of medals in the Summer Olympic Games. 	
SELECT team, COUNT(medal) AS total_medals
FROM olympics_total
WHERE season = 'Summer' AND medal <> 'NA'
GROUP BY team
ORDER BY total_medals DESC
LIMIT 1




-- Q 22. List the top 5 athletes with the most medals won (even if multiple medals in the same year). 

-- VAR. 1
SELECT name, team, COUNT(medal) AS total_medals
FROM olympics_total
WHERE medal <> 'NA'
GROUP BY name, team
ORDER BY total_medals DESC
LIMIT 5

-- VAR. 2
WITH 
	t1 AS 
		(SELECT name, team, COUNT(medal) AS total_medals
		 FROM olympics_total
		 WHERE medal <> 'NA'
		 GROUP BY name, team),

	t2 AS 
		(SELECT *, ROW_NUMBER() OVER(ORDER BY total_medals DESC) AS rn
		 FROM t1)

SELECT name, team, total_medals
FROM t2
WHERE rn <= 5




-- Q 23. All Olympic Games where India won medals in Hockey 
SELECT DISTINCT games, city, medal
FROM olympics_total
WHERE team = 'India' AND medal <> 'NA' AND sport = 'Hockey'
ORDER BY games




-- Q 24. For each country, show the sport in which they won the most medals.
WITH 
	medals_by_sport AS
					(SELECT reg.region AS country, sport, COUNT(medal) AS medals_by_sport
					 FROM olympics_total ot
					 JOIN olympics_regions reg ON ot.noc = reg.noc
					 GROUP BY reg.region, sport),

	sport_rank AS 
				(SELECT *, ROW_NUMBER() OVER(PARTITION BY country ORDER BY medals_by_sport DESC) AS rn
				 FROM medals_by_sport)

SELECT *
FROM sport_rank
WHERE rn = 1
ORDER BY medals_by_sport DESC




-- Q 25. Average age of medalists by medal type (Gold, Silver, Bronze)
SELECT medal, ROUND(AVG(age::INT), 2) AS avg_age
FROM olympics_total
WHERE age <> 'NA' AND medal <> 'NA'
GROUP BY medal




-- Q 26. For each Olympic edition, show the number of medals won by Team USA
SELECT year, COUNT(*) AS total_medals
FROM olympics_total
WHERE medal <> 'NA' AND team = 'United States'
GROUP BY year
ORDER BY total_medals




-- Q 27. Female athletes who won gold medals before 1950. List name, year, and sport.
SELECT name, year, sport
FROM olympics_total
WHERE medal <> 'Gold' AND year < 1950 AND sex = 'F'
ORDER BY year



-- Q 28. Countries that won at least one of each medal type: Gold, Silver, and Bronze.
WITH 
	countries AS 
		(SELECT reg.region AS country, medal
		 FROM olympics_total ot
		 JOIN olympics_regions reg ON ot.noc = reg.noc
		 WHERE medal <> 'NA'),
		 
	medal_count AS 
		(SELECT country,
			COUNT(*) FILTER(WHERE medal = 'Gold') AS gold, 
			COUNT(*) FILTER(WHERE medal = 'Silver') AS silver,
			COUNT(*) FILTER(WHERE medal = 'Bronze') AS bronze
		FROM countries
		GROUP BY country)

SELECT country
FROM medal_count
WHERE gold > 0 AND silver > 0 AND bronze > 0



-- Q 29. Average height and weight of athletes by sport
SELECT sport, 
	CAST(AVG(height::FLOAT) AS DECIMAL(10 ,1)) AS avg_height, 
	CAST(AVG(weight::FLOAT) AS DECIMAL(10 ,1)) AS avg_weight
FROM olympics_total
WHERE height <> 'NA' AND weight <> 'NA'
GROUP BY sport



-- Q 30. Athletes with the same name but different nationalities

-- VAR 1. My approach - 3s.251ms
WITH 
	countries AS 
		(SELECT DISTINCT(reg.region) AS country, name
		 FROM olympics_total ot
		 JOIN olympics_regions reg ON ot.noc = reg.noc)
		 
SELECT c1.name, COUNT(*)
FROM countries c1
JOIN countries c2 ON c1.name = c2.name AND c1.country <> c2.country
GROUP BY c1.name


-- VAR 2. GPT approach - 2s.381ms
SELECT name, COUNT(DISTINCT reg.region) AS country_count
FROM olympics_total ot
JOIN olympics_regions reg ON ot.noc = reg.noc
GROUP BY name
HAVING COUNT(DISTINCT reg.region) > 1;


-- VAR 3. The best approach - 0s.231ms
CREATE MATERIALIZED VIEW IF NOT EXISTS athlete_country AS 
SELECT DISTINCT reg.region, ot.name 
FROM olympics_total ot
JOIN olympics_regions reg ON ot.noc = reg.noc;

SELECT name, COUNT(*) AS team_count 
FROM athlete_country
GROUP BY name
HAVING COUNT(*) > 1
--DROP MATERIALIZED VIEW athlete_country



-- Q 31. The event with the highest total number of awarded medals (excluding 'NA').
SELECT event, COUNT(medal) AS total_medals
FROM olympics_total
WHERE medal <> 'NA'
GROUP BY event
ORDER BY total_medals DESC
LIMIT 1



-- Q 32. Sports practiced in both Summer and Winter Olympics

-- VAR 1. My approach - 300ms
WITH
	summer_sports AS 
		(SELECT DISTINCT sport
		 FROM olympics_total
		 WHERE season = 'Summer'),

	winter_sports AS 
		(SELECT DISTINCT sport
		 FROM olympics_total
		 WHERE season = 'Winter')
SELECT ws.sport AS sport
FROM winter_sports ws
JOIN summer_sports sp ON ws.sport = sp.sport


-- VAR 2. GPT approach - 700ms
SELECT sport
FROM olympics_total
GROUP BY sport
HAVING COUNT(DISTINCT season) > 1


-- VAR 3. GPT approach with INTERSECT - 300ms
SELECT DISTINCT sport
FROM olympics_total
WHERE season = 'Summer'

INTERSECT

SELECT DISTINCT sport
FROM olympics_total
WHERE season = 'Winter';



-- Q 33. Top 5 oldest athletes who won a medal
SELECT name, age, team, sport, year, medal
FROM olympics_total
WHERE medal <> 'NA' AND age <> 'NA'
ORDER BY age DESC
LIMIT 5



-- Q 34. Athletes who participated in more than 4 editions
SELECT id, name, COUNT(DISTINCT games) AS editions 
FROM olympics_total
GROUP BY id, name
HAVING COUNT(DISTINCT games) > 4



-- Q 35. Medal-to-participation ratio by country

-- VAR 1. My approach - 850ms
WITH
	countries AS 
		(SELECT reg.region AS country, medal
		 FROM olympics_total ot
		 JOIN olympics_regions reg ON ot.noc = reg.noc),
		 
	total_presences AS 
		(SELECT country, COUNT(*) AS total_part
		 FROM countries
		 GROUP BY country),

	medals_per_team AS 
		(SELECT country, COUNT(medal) AS total_medals
		 FROM countries
		 WHERE medal <> 'NA'
		 GROUP BY country)

SELECT tp.country, tp.total_part, mpt.total_medals, CAST(mpt.total_medals::FLOAT / tp.total_part AS DECIMAL(10, 3)) AS medal_part_ratio 
FROM total_presences tp
JOIN medals_per_team mpt ON tp.country = mpt.country
ORDER BY medal_part_ratio DESC


-- VAR 2. GPT approach - 250ms
SELECT 
	region AS country,
	COUNT(*) AS total_part,
	COUNT(NULLIF(medal, 'NA')) AS total_medals,
	ROUND(COUNT(NULLIF(medal, 'NA')) * 1.0 / COUNT(*), 3) AS medal_part_ratio  
FROM (
	SELECT *
	FROM olympics_total ot
	JOIN olympics_regions reg ON ot.noc = reg.noc
)
GROUP BY region
ORDER BY medal_part_ratio DESC



SELECT * FROM olympics_total;
SELECT * FROM olympics_regions;















