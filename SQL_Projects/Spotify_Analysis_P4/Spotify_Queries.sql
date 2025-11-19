
/*
			--	All The Questions -- 
	1. Retrieve the names of all tracks that have more than 1 billion streams.
	2. List all albums along with their respective artists.
	3. Get the total number of comments for tracks where licensed = TRUE.
	4. Find all tracks that belong to the album type single.
	5. Count the total number of tracks by each artist.
	6. Calculate the average danceability of tracks in each album.
	7. Find the top 5 tracks with the highest energy values.
	8. List all tracks along with their views and likes where official_video = TRUE.
	9. For each album, calculate the total views of all associated tracks.
	10. Retrieve the track names that have been streamed on Spotify more than YouTube.
	11. Find the top 3 most-viewed tracks for each artist using window functions.
	12. Write a query to find tracks where the liveness score is above the average.
	13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
	14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
	15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/




-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

-- SELECT 
-- 	artist,
-- 	track,
-- 	stream
-- FROM spotify
-- WHERE stream > 1000000000
-- ORDER BY 3;

SELECT
	track,
	MIN(artist),
	stream
FROM spotify
WHERE stream > 1000000000
GROUP BY track, stream
ORDER BY 3;



-- 2. List all albums along with their respective artists.
SELECT 
	album,
	artist
FROM spotify
GROUP BY album, artist
ORDER BY 2;
	


-- 3. Get the total number of comments for tracks where licensed = TRUE.
With su AS (SELECT 
	track,
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = TRUE 
GROUP BY track
ORDER BY 2 DESC)
SELECT SUM(total_comments) FROM su;
-- SELECT SUM(comments) FROM spotify WHERE licensed = TRUE  



-- 4. Find all tracks that belong to the album type single.
SELECT 
	track,
	album_type
FROM spotify
WHERE album_type = 'single';



-- 5. Count the total number of tracks by each artist.
SELECT 
	artist,
	COUNT(track) as num_of_tracks
FROM spotify
GROUP BY artist
ORDER BY 2 DESC;



-- 6. Calculate the average danceability of tracks in each album.
SELECT 
	album,
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY 2 DESC;



-- 7. Find the top 5 tracks with the highest energy values.
SELECT 
	track,
	energy
FROM spotify
ORDER BY 2 DESC
LIMIT 5;



-- 8. List all tracks along with their views and likes where official_video = TRUE.
SELECT 
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY 2 DESC;



-- 9. For each album, calculate the total views of all associated tracks.
SELECT
	album, 
	SUM(views) as total_views
FROM spotify
GROUP BY album
ORDER BY total_views DESC;



-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM 
(
SELECT 
	title,
	COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END), 0) as streamed_on_spotify,
	COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END), 0) as streamed_on_youtube
FROM spotify
GROUP BY title
)
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND streamed_on_youtube > 0



-- 11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH top_tracks AS 
(
SELECT 
	artist, 
	track, 
	SUM(views),
DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY artist, track
) 
SELECT *
FROM top_tracks
WHERE rank <= 3;



-- 12. Write a query to find tracks where the liveness score is above the average. 
SELECT 
	track,
	CAST(liveness AS DECIMAL(10, 5)),
	(SELECT CAST(AVG(liveness) AS DECIMAL (10, 5)) FROM spotify) as avg_liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY 2;



-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
-- SELECT 
-- 	album,
-- 	CAST(MAX(energy) AS DECIMAL (10, 3)) as max_energy,
-- 	CAST(MIN(energy) AS DECIMAL (10, 3)) as min_energy,
-- 	CAST(MAX(energy) - MIN(energy) AS DECIMAL (10, 3)) as difference
-- FROM spotify
-- GROUP BY album
-- HAVING MAX(energy) - MIN(energy) > 0

WITH energy_diff AS 
(
SELECT 
	album,
	CAST(MAX(energy) AS DECIMAL (10, 3)) as max_energy,
	CAST(MIN(energy) AS DECIMAL (10, 3)) as min_energy,
	CAST(MAX(energy) - MIN(energy) AS DECIMAL (10, 3)) as difference
FROM spotify
GROUP BY album
)
SELECT 
  album,
  max_energy - min_energy as energy_diff
FROM energy_diff;

  				

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT
	track, 
	CAST(SUM(energy/NULLIF(liveness, 0)) AS DECIMAL (10, 5)) as energy_liveness_raio
FROM spotify
GROUP BY track
HAVING SUM(energy/NULLIF(liveness, 0)) > 1.2
ORDER BY energy_liveness_raio;



--15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
WITH aggregated AS (
	SELECT
		title,
		SUM(likes) as total_likes,
		SUM(views) as total_views
	FROM spotify
	GROUP BY title
)
SELECT 
	title,
	SUM(total_likes) OVER(ORDER BY total_views)
FROM aggregated
ORDER BY 2 DESC;






