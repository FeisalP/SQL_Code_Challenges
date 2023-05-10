-- return a query for posts performance on Facebook sorting by the most recent ones
--
-- start by returning data for the most recent date in the dataset
SELECT * 
FROM fanspercountry
ORDER BY date DESC
LIMIT 10;
--
--
-- using the latest date '2018-10-16' as a condition to generate the required output 
SELECT * 
FROM fanspercountry
WHERE date >= '2018-10-16'
ORDER BY numberoffans DESC
LIMIT 10;
--
--
--
--
--
SELECT * 
FROM global_page
LIMIT 10;
--
--
-- look at the days with the greatest average new likes per day
-- sort the result
SELECT DISTINCT(new_likes), date
FROM global_page
ORDER BY new_likes DESC
LIMIT 10;
--
--
-- what is the latest split of fans by gender in percentage?
SELECT * 
FROM fans_per_gender_age
LIMIT 10;
--
--
-- total number of fans for the latest date
SELECT sum(number_of_fans)
FROM fans_per_gender_age
WHERE date = '2018-10-16';
--
-- using the above query as a sub-query to obtain the percentage in the final query
-- the result is then rounded to 2 decimal places
SELECT 
	gender,
	SUM(number_of_fans), 
	ROUND(SUM(number_of_fans) * 100 / 
		(SELECT SUM(number_of_fans)
		FROM fans_per_gender_age
		WHERE date = '2018-10-16'),2)
FROM fans_per_gender_age
WHERE date = '2018-10-16'
GROUP BY gender;
--
--
-- QUESTION
-- what is the latest top 10 countries with respect to the penetration ratio?
--
-- Penetration ratio of a country is defined as the 
-- number of fans divided by the population
--
-- the data can be extracted by joining two tables:
-- 'fans_per_country' & 'pop_stats'
SELECT * 
FROM fans_per_country;
--
SELECT * 
FROM pop_stats;
--
-- join the two tables on the country_code column
SELECT * 
FROM fans_per_country AS fpc
JOIN pop_stats AS pst
ON fpc.country_code = pst.country_code
ORDER BY date DESC
LIMIT 10;
--
-- data the latest date: '2018-10-16'
-- the output indicates their are duplicate rows
--
SELECT 
	fpc.date, 
	pst.country_name, 
	ROUND(SUM(DISTINCT fpc.number_of_fans) * 100 /pst.population, 2) AS penetration_ratio
FROM fans_per_country AS fpc
	JOIN pop_stats AS pst
	ON fpc.country_code = pst.country_code
WHERE fpc.date = '2018-10-16'
GROUP BY fpc.date, pst.country_name, pst.population
ORDER BY penetration_ratio DESC
LIMIT 10;
--
--
-- QUESTION:
-- what is the bottom 10 countries with the largest populations but 
-- lowest number of fans
--
SELECT * 
FROM pop_stats;

SELECT * 
FROM fans_per_city;
--
--
-- joining the two tables pop_stats and fans_per_city 
-- data the latest date: '2018-10-16'
-- order by number of fans
-- limit result to 10 rows
SELECT fpc.city, pst.population, fpc.number_of_fans  
FROM pop_stats AS pst
JOIN fans_per_city AS fpc
ON pst.country_code = fpc.country_code
WHERE fpc.date = (SELECT MAX(date) FROM fans_per_city)
and pst.population > 20000000
GROUP BY fpc.city, pst.population, fpc.number_of_fans
ORDER BY fpc.number_of_fans
LIMIT 10;
--
--
-- QUESTION:
-- what are the top 10 cities and countries with the highest number of fans?
--
-- join the two tables fans_per_city and pop_stats
--
SELECT city, country_name, SUM(number_of_fans) AS total_fans   
FROM pop_stats AS pst
JOIN fans_per_city AS cit
ON pst.country_code = cit.country_code
GROUP BY city, country_name
ORDER BY total_fans DESC
LIMIT 30;
--
--
-- QUESTION:
-- what is the GDP for each country from the country_stats table.
-- Extract the GDP country by country for each year along with the average GDP
--
SELECT 
	date, 
	country_id, 
	gdp, 
	AVG(gdp) OVER (PARTITION BY country_id) AS avg_gdp_per_country 
FROM country_stats
;
--
--
-- QUESTION:
-- filter the data for the most successful athletes per region
-- create subsets for each region
-- sort and rank the results by the number of medals each athlete has won
--
--
SELECT *
FROM athletes
ORDER BY id asc
LIMIT 10;
--
SELECT *
FROM country_regions
LIMIT 10;
--
-- use the join clause to get the required output from the games_stats, atheletes, and 
-- country_regions tables
SELECT *
FROM games_stats AS gs
JOIN athletes AS ath
ON gs.athlete_id = ath.id
join country_regions AS cr
ON gs.country_id = cr.id
LIMIT 10;
--
--
-- extract region, athlete_id, aggregated medals won by the athlete from that region
-- partition the data by region and order by the number of total gold medals in descending order
SELECT 
	gs.athlete_id,
	cr.region, 
	SUM(gs.gold) AS gold_count,
	ROW_NUMBER()
	OVER (PARTITION BY cr.region
	ORDER BY SUM(gs.gold) DESC) AS gold_medal_rank
FROM games_stats AS gs
JOIN athletes AS ath
ON gs.athlete_id = ath.id
JOIN country_regions AS cr
ON gs.country_id = cr.id
GROUP BY gs.athlete_id, cr.region
LIMIT 100;
--
--
-- QUESTION
-- divide every athlete from each sport into three buckets of
-- BMI and provide a count of athletes that belong to each bucket
--
-- set the three BMI groups as <0.25, 0.25 - 0.30, and > 0.3
--
-- viewing the relevant tables to use for this query
SELECT *
FROM athletes
LIMIT 50;
--
SELECT *
FROM games
LIMIT 50;
--
SELECT *
FROM games_stats
LIMIT 50;
--
-- calculating the bmi for every athlete using the athlete table
SELECT 
	id, 
	age, 
	height, 
	weight, 
	ROUND((weight/height^2*100)::NUMERIC,2) AS bmi
FROM athletes
WHERE height IS NOT NULL
AND weight IS NOT NULL
ORDER BY bmi DESC
LIMIT 25;
--
-- joining the output with the games table and display the sport column
-- the distinct clause is added to the id field to remove duplicates
SELECT 
		DISTINCT id, 
		sport, 
		age, 
		height, 
		weight,
		ROUND((weight/height^2*100)::NUMERIC,2) AS bmi
FROM athletes
JOIN games_stats
ON athletes.id = games_stats.athlete_id
WHERE height IS NOT NULL
AND weight IS NOT NULL
ORDER BY bmi DESC;
--
-- using the CASE WHEN statement to group bmi in three different buckets
SELECT 
		DISTINCT id, 
		sport, 
		age, 
		height, 
		weight,
		ROUND((weight/height^2*100)::NUMERIC,2) AS bmi,
	CASE 
		WHEN ROUND((weight/height^2*100)::NUMERIC,2) < 0.25 THEN 'underweight'
		WHEN ROUND((weight/height^2*100)::NUMERIC,2) BETWEEN 0.25 AND 0.30 THEN 'healthy_weight'
		ELSE 'overweight'
		END bmi_group
FROM athletes
JOIN games_stats
ON athletes.id = games_stats.athlete_id
WHERE height IS NOT NULL
AND weight IS NOT NULL
ORDER BY bmi_group;
-- providing a count of athletes that belong to each bmi group
-- followed by a group by clause
-- to obtain the required output
SELECT 
	sport,
	COUNT(DISTINCT id) AS athlete_count,
	CASE 
		WHEN ROUND((weight/height^2*100)::NUMERIC,2) < 0.25 THEN 'underweight'
		WHEN ROUND((weight/height^2*100)::NUMERIC,2) BETWEEN 0.25 AND 0.30 THEN 'healthy_weight'
		ELSE 'overweight' 
	END AS bmi_group
FROM athletes
JOIN games_stats
ON athletes.id = games_stats.athlete_id
WHERE height IS NOT NULL
AND weight IS NOT NULL
GROUP BY sport, bmi_group
ORDER BY sport, athlete_count DESC;
--NOTE: a count distinct is applied to the id column in order to count unique values
--
--
-- QUESTION
-- provide a 6-day moving average of stocks
--
SELECT *
FROM stock_price
LIMIT 10;
--
-- using the stock_price table and selecting the closing price data
-- use the OVER clauses to set up the window
-- order by date
-- use ROWS to get the rows between the preceding five rows and the current row
SELECT 
	date, 
	close,
	ROUND(AVG(close)
	OVER (ORDER BY date ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)::NUMERIC,2) AS avg_closing_price
FROM stock_price;
--
-- QUESTION
-- find the average post per week and return which days of the week are best for posting on facebook
-- Calculate the engagement (engaged_fans divided by reach) 
-- grouped for everyday of a week and sorted in the descending order
--
-- reviewing the post_insights table to be used for this query
SELECT * 
FROM post_insights
LIMIT 10;
-- 
-- calculate the Engagement with AVG(engaged_fans * 100 / reach)
-- use DATE_PART to extract the day of week
-- ORDER BY engagement in descending order to display the highest post engagement 
SELECT 
	ROUND(AVG(engaged_fans * 100/reach),2) AS engagement,
	DATE_PART('dow', CAST(created_time as date)) AS day_of_week
FROM post_insights
GROUP BY day_of_week
ORDER BY engagement DESC
LIMIT 10;
--
-- use the CASE WHEN statement to convert the numerical dow to display 
-- the actual name of the day 
SELECT  
	ROUND(AVG(engaged_fans * 100/reach),2) AS engagement,
	CASE DATE_PART('dow', CAST(created_time as date))
		WHEN 0 THEN 'Sunday'
		WHEN 1 THEN 'Monday'
		WHEN 2 THEN 'Tuesday'
		WHEN 3 THEN 'Wednesday'
		WHEN 4 THEN 'Thursday'
		WHEN 5 THEN 'Friday'
		WHEN 6 THEN 'Saturday'
		END AS day_of_week
FROM post_insights
GROUP BY day_of_week
ORDER BY engagement DESC
LIMIT 10;
--
--
-- QUESTION
-- format the raw data to fix 'LATIN AMER.&CARIB' by removing the "." and replacing "&" with 'and'
-- trim down any extra spaces
--
SELECT *
FROM country_regions
LIMIT 10;
--
-- use REPLACE() to replace all periods and '&' from the string
-- use TRIM() function to remove extra spaces in the string
-- return the orginal region along with the formatted regional names
SELECT region,
TRIM(REPLACE(region, '. &', ' and')) AS cleaned_region_name
FROM country_regions
WHERE region='LATIN AMER. & CARIB    '
GROUP BY region;
--
-- try these with a duplicated table so the existing one is not amended
UPDATE 
	country_regions
SET
	region = REPLACE(region,'LATIN AMER.&CARIB','LATIN AMERICA AND CARIBBEAN');
--
--
-- QUESTION
-- find and replace null values in the games table with something more meaningful
-- find the rows with NULL values in the medal column
--
SELECT *
FROM games
WHERE medal IS NULL;
--
-- impute those with an NA string using the COASLESCE() clause
SELECT sport, athlete_id,
COALESCE(medal, 'NA')
FROM games;
--
--
-- QUESTION
-- segregate the data for men's and women's games
-- use regular expressions to match a substring from 
-- an event to extract data for all men's events
-- same technique will apply for all women's events
--
SELECT *
FROM games_stats
LIMIT 10;
--
-- use the REGEXP_MATCHES to match a substring with the event string
-- to then segregate the selection from the women's event
SELECT *,
REGEXP_MATCHES(event, 'Men') AS mens_events
FROM games_stats;











