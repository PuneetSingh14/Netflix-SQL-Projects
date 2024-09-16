--Netflix Project
CREATE TABLE netflix (
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

SELECT
     COUNT(*) as Total_content
FROM netflix;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(*) as Total_no_count
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM 
(
	SELECT
		type,
		rating,
		COUNT(*) as total_count,
		DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
		FROM netflix
		GROUP BY 1,2
) AS T1
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE 
	type = 'Movie' 
	and
	release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	New_country,
	Total_content
FROM
    (
		SELECT
		-- Separate the Country
		UNNEST(STRING_TO_ARRAY(country,',')) AS New_country,
		count(*) AS Total_content
		FROM netflix
		GROUP BY 1
	) AS T1
WHERE New_country IS NOT NULL	
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

-- SELECT duration, split_part(duration,' ',1)::int FROM netflix where type ='Movie'
SELECT 
	*,
	SPLIT_PART(duration, ' ', 1)::INT AS Total_duration
FROM netflix
WHERE type = 'Movie' AND SPLIT_PART(duration, ' ', 1)::INT IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC

-- 6. Find content added in the last 5 years

SELECT 
		*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY')>= current_date - INTERVAL '5 YEAR';		

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *,
		UNNEST(STRING_TO_ARRAY(director, ',')) as New_director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT 
	*,
	SPLIT_PART(duration,' ',1)::INT
FROM netflix
WHERE SPLIT_PART(duration,' ',1)::INT > 5
and 
type = 'TV Show';

-- 9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS GENRE,
	count(*) AS Total_content
FROM netflix
GROUP BY 1;

'''10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!'''

SELECT
EXTRACT (YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) AS year,
COUNT(*),
round((count(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100),2) AS Avg_content_release
FROM netflix
WHERE country = 'India'
GROUP BY 1;

-- 11. List all movies that are documentaries

SELECT
*
FROM netflix
WHERE type = 'Movie'
AND
listed_in ILIKE '%documentaries%';

-- 12. Find all content without a director

SELECT 
*
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT
*
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS Actors,
	COUNT(*) AS No_of_movies`
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

'''15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.'''

WITH new_table AS
	(
	SELECT *,
			CASE WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad'
			ELSE 'Good' END AS Category
	FROM netflix
	)
SELECT 
Category,
count(*) as Total_content
FROM new_table
GROUP BY 1;
