# Netflix Movies and TV Shows data analysis Using SQL 

![Neflix_Logo](https://github.com/Rohit-katkar2003/Netflix_SQL_project/blob/main/6bc33fd111737a6ed70a1c5b3b58e2db.png)


# Netflix Data Analysis Project

## Overview

This project analyzes a dataset of Netflix titles to gain insights into the platform's content. The analysis includes exploring the types of content, ratings, release years, top countries for content, longest movies, recently added content, content by specific directors and actors, TV shows with multiple seasons, content distribution across genres, and content categorization based on keywords in descriptions.

## Project Structure

The project consists of a single SQL script (`netflix_analysis.sql`) that contains all the queries used for the analysis and this README file (`README.md`).

## Database and Table

The analysis is performed on a database named `Netflix_db` and a table named `netflix_titles`. The script assumes that this database and table already exist and are populated with Netflix data.
### 📦 Dataset Overview
We begin by understanding the dataset with basic exploratory queries:

### 🔍 Data Preview
View all records from the table to understand the structure and attributes.

### 🧮 Total Records
Count the total number of entries in the dataset.

### 🎬 Types of Content
Identify distinct content types such as "Movie" and "TV Show".

### 🎥 Unique Directors
Count how many unique directors are present in the dataset.

### 🌍 Countries Represented
Find how many different countries are included.

### 📅 Data Coverage
Check the time range of the data from the earliest to the most recent release year.

### ⭐ Movie Ratings
List all unique ratings and the number of times each rating appears.


## Queries Performed

The `netflix_analysis.sql` script includes the following queries:

```sql
-- Netflix project
USE Netflix_db;
```

```sql
-- Select all data from the netflix_titles table to inspect its contents.
-- Question: What does the raw data in the netflix_titles table look like?
SELECT * FROM netflix_titles;
```
-- Count the total number of rows in the netflix_titles table.
-- Question: How many total content items (movies and TV shows) are in the dataset?
SELECT COUNT(*) AS [total records in data]
FROM netflix_titles;

-- Select the distinct values from the 'type' column.
-- Question: What are the different types of content available on Netflix according to this data?
SELECT DISTINCT type
FROM netflix_titles;

-- Count the distinct non-null values in the 'director' column.
-- Question: How many unique directors have content listed in this dataset?
SELECT DISTINCT COUNT(director) AS [total directors in data]
FROM netflix_titles;

-- Count the distinct non-null values in the 'country' column.
-- Question: From how many different countries does the content in this dataset originate?
SELECT DISTINCT COUNT(country) AS [total countries in data]
FROM netflix_titles;

-- Find the minimum and maximum values in the 'release_year' column.
-- Question: What is the earliest and latest year of content release represented in this data?
SELECT MIN(release_year) AS [starting year],
       MAX(release_year) AS [ending year]
FROM netflix_titles;

-- Select distinct values from the 'rating' column and count the occurrences of each rating, ordered by count descending.
-- Question: What are the different content ratings present in the data, and how many items have each rating?
SELECT DISTINCT rating, COUNT(rating) AS [count rating]
FROM netflix_titles
GROUP BY rating
ORDER BY [count rating] DESC;

-------------------------------------------------------------------------------------------------------------------------------
-- Solving business problems

-- 1. Count the number of movies vs TV shows
-- Question: How many movies and how many TV shows are there in the dataset?
SELECT DISTINCT type,
       COUNT(type) AS [counts of type]
FROM netflix_titles
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
-- Question: For both movies and TV shows, what are the top 3 most frequent content ratings?
SELECT type, rating
FROM (SELECT type,
             rating,
             COUNT(rating) AS [count of ratings],
             DENSE_RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
      FROM netflix_titles
      GROUP BY type, rating) AS t1
WHERE ranking <= 3;


-- 3. List all the movies released in a specific year (e.g., 2020)
-- Question: Can you list all the movies that were released in the year 2020?
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
  AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
-- Question: Which are the top 5 countries that have contributed the most content (movies and TV shows) to Netflix?
SELECT TOP 5
       TRIM(new_country.value) AS country,
       COUNT(show_id) AS country_count
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',') AS new_country
GROUP BY new_country.value
ORDER BY country_count DESC;


-- 5. Identify the longest movie(s) (assuming duration is in minutes and greater than 300 minutes)
-- Question: What are the titles and durations of movies that are longer than 300 minutes?
SELECT title, duration, new_duration.value AS [minutes]
FROM netflix_titles
CROSS APPLY STRING_SPLIT(duration, ' ') AS new_duration
WHERE type = 'Movie'
  AND ISNUMERIC(new_duration.value) = 1
  AND CAST(new_duration.value AS INT) > 300;


-- 6. Find content added in the last 5 years (relative to the current date)
-- Question: How many movies and TV shows have been added to Netflix in the last 5 years?
SELECT COUNT(*) AS [Total content added in last 5 year]
FROM netflix_titles
WHERE YEAR(date_added) >= (SELECT YEAR(DATEADD(year, -5, GETDATE())));


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
-- Question: Can you list all the content (movies and TV shows) directed by 'Rajiv Chilaka'?
SELECT *
FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all TV SHOWS with more than 5 seasons
-- Question: Which TV shows in the dataset have more than 5 seasons?
SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND duration LIKE '%Seasons%'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- Alternative way to find TV shows with more than 5 seasons
-- Question: (Alternative) Which TV shows in the dataset have a duration indicating more than 5 seasons?
SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND LEFT(duration, 1) > '5'; -- Assuming duration starts with the number of seasons


-- 9. Count the number of content items in each genre
-- Question: How many movies and TV shows are categorized under each listed genre?
SELECT TRIM(l_split.value) AS [genre],
       COUNT(title) AS [number of content]
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',') AS l_split
GROUP BY TRIM(l_split.value)
ORDER BY [number of content] DESC;

-- 10. Find the yearly count and average percentage of content released by India on Netflix. Return top 5 years with the highest average content release!
-- Question: For content originating from India, what is the yearly count of additions to Netflix, and what percentage does that represent of the total Indian content added over time? Show the years with the top 5 highest percentages.
SELECT TOP 5
       c_split.value AS country,
       YEAR(date_added) AS year_added,
       COUNT(*) AS yearly_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles WHERE country LIKE '%India%'), 2) AS avg_content_percentage
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',') AS c_split
WHERE TRIM(c_split.value) = 'India'
GROUP BY YEAR(date_added), c_split.value
ORDER BY avg_content_percentage DESC;


-- Q.11) List all the movies that are documentary
-- Question: Can you list all the movies that are categorized as documentaries?
SELECT COUNT(*)
FROM netflix_titles
WHERE listed_in LIKE '%Documentaries%'
  AND type = 'Movie';


-- 12. Find all content without a director
-- Question: How many movies and TV shows in the dataset do not have a listed director?
SELECT COUNT(*) AS [content without director]
FROM netflix_titles
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years!
-- Question: How many movies featuring 'Salman Khan' have been released in the last 10 years?
SELECT COUNT(*)
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND type = 'Movie'
  AND TRY_CAST(release_year AS INT) >= (SELECT YEAR(GETDATE()) - 10);


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
-- Question: Among movies produced in India, which are the top 10 actors who have the most appearances?
SELECT TOP 10
       TRIM(c_split.value) AS actor,
       COUNT(*) AS [high_no_of_movie]
FROM netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',') AS c_split
WHERE country LIKE '%India%'
  AND type = 'Movie'
GROUP BY TRIM(c_split.value)
ORDER BY [high_no_of_movie] DESC;


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
-- Question: How many content items are categorized as 'Bad' (containing 'kill' or 'violence' in the description) and how many are 'Good' (not containing these keywords)?
WITH raw_table AS (
    SELECT *,
           CASE
               WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad_content'
               ELSE 'Good_Content'
           END AS category
    FROM netflix_titles
)
SELECT category,
       COUNT(*) AS [count of category]
FROM raw_table
GROUP BY category;
