
-- Netflix project  
use Netflix_db; 

select * from netflix_titles; 

-- total content the table contains 
SELECT 
	COUNT(*) [total records in data] 
FROM netflix_titles;

-- different types of type in movies 

SELECT 
	DISTINCT type 
from netflix_titles;  


-- how many directors which made movies according to data 
select 
	distinct count(director)[total directors in data] 
from netflix_titles; 

-- how many countries data we have? 
select  
	distinct count(country) [total countries in data]
from netflix_titles;

-- which period of data we have? 
select  
	min(release_year)[starting year] , 
	max(release_year)[ending year] 
from netflix_titles; -- we have data in between 1925 to 2021 

-- which are different rating given to movies in data? 
select 
	 distinct rating , count(rating) [count rating]
from netflix_titles 
group by rating 
order by [count rating] DESC; 

-------------------------------------------------------------------------------------------------------------------------------
-- solving business problems 

-- 1. Count the number of movies vs TV shows 
select  
	 distinct type , 
	 count(type) [counts of type] 
from netflix_titles 
group by type;


-- 2. Find the most common rating for movies and TV shows  

select type , rating 
from(select  
		type , 
		rating ,
		count(rating) [count of ratings] , 
		DENSE_RANK() OVER(PARTITION by type ORDER BY COUNT(*) DESC) as ranking
	from netflix_titles 
	group by type, rating ) as t1 
where ranking = 3; 


-- 3. list all the movies realeased in specific year (e.g 2020) 

select * from netflix_titles 
where  
	type = 'Movie'
	AND 
	release_year = 2020 


-- 4. Find the top 5 countries with the most content on netflix 

SELECT  top 5
    trim(new_country.value) AS country, 
    COUNT(show_id) AS country_count
FROM netflix_titles 
CROSS APPLY STRING_SPLIT(country, ',') AS new_country 
GROUP BY new_country.value 
order by country_count DESC;
 

-- 5. Identify longest movie 

select title , duration,new_duration.value [minutes]
from netflix_titles 
cross apply STRING_SPLIT(duration, ' ') as new_duration
where type='movie' AND 
	  ISNUMERIC(new_duration.value) = 1 AND 
	  new_duration.value>300; 


-- 6. Find content added in the last 5 years 

SELECT count(*)[Total content added in last 5 year]
FROM netflix_titles 
WHERE year(date_added) >= (
						SELECT year(DATEADD(year, -5, GETDATE()))
						  ); 


-- 7. find all the movies/TV shows by director 'Rajiv chilaka' ? 
select *  
from netflix_titles 
where 
	director LIKE '%Rajiv chilaka%' ; 


-- 8. List all TV SHOWS with more than 5 seasons


select *  
from netflix_titles 
cross apply string_split(duration , ' ') as d_split 
where type = 'TV Show' and 
		ISNUMERIC(d_split.value) =1 and 
	d_split.value>5;
   

select * 
from netflix_titles
where type = 'TV Show' 
		AND 
	duration>= '5 Seasons';
 

-- 9. Count the number of content items in each genre 

select * from netflix_titles;

select trim(l_split.value)[genre] , 
	   count(title)[number of content]
from netflix_titles 
cross apply string_split(listed_in , ',') as l_split 
group by trim(l_split.value)
order by [number of content] DESC;

-- 10. Find the each year and average number of content realease by India on netflix. return top 5 year with highest avg content release !

select * from netflix_titles; 


SELECT 
    c_split.value AS country,
    YEAR(date_added) AS year_added,
    COUNT(*) AS yearly_count,round(
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles WHERE country LIKE '%India%') , 2) AS avg_content_percentage
FROM  netflix_titles
CROSS APPLY  STRING_SPLIT(country, ',') AS c_split  
WHERE c_split.value = 'India'
GROUP BY YEAR(date_added), c_split.value
ORDER BY year_added;


-- Q.11) List all the movies that are documentary 


select count(*) from netflix_titles 
where listed_in like '%Documentaries%' AND type = 'Movie'


-- 12. Find all content without a director 
select count(*)[content without director]
from netflix_titles 
where director is null ; 



-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 year! 

select *  
from netflix_titles
where	
	cast like '%Salman Khan%' AND 
	try_cast(release_year AS int) >=(
									select year(getdate())-10
									);



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India. 

select top 10  
	c_split.value , count(*) [high_no_of_movie]
from netflix_titles
	cross apply string_split(cast , ',') as c_split 
where country like '%India%'
group by c_split.value  
order by [high_no_of_movie] desc
;


-- 15. Categorized the content based on the presence of the keywords 'kill' and 'violence' in the description field. label content containing these keywords as 'Bad' and all other content as 'Good'.  Count how many items fall into each category. 
select * from netflix_titles;


with raw_table 
as (
select *  , 
		CASE 
		WHEN description like '%kill%' or 
		description like '%violence%' THEN 'Bad_content'
			else 'Good_Content'
		END category
from netflix_titles
) 
select 
	category , 
	count(*)[count of categry] 
from raw_table 
group by category;
