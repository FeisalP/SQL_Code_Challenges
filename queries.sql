--return a query for posts performance on Facebook sorting by the most recent ones
--
-- start by returning data for the most recent date in the dataset
SELECT * 
FROM fanspercountry
ORDER BY date DESC
LIMIT 10;
--
--
-- using latest date '2018-10-16' as a condition to generate the required output 
SELECT * 
FROM fanspercountry
WHERE date >= '2018-10-16'
ORDER BY numberoffans DESC
LIMIT 10;
--
--
ALTER TABLE "FansPerCountry"
RENAME TO "fanspercountry"
--
--
ALTER TABLE fanspercountry
RENAME COLUMN "CountryCode" TO countrycode
--
--
SELECT * 
FROM "GlobalPage"
LIMIT 10;
--
--
-- look at the days with the greatest average new likes per day
-- sort the result
SELECT DISTINCT(new_likes), date
FROM "GlobalPage"
ORDER BY new_likes DESC
LIMIT 10;
--
--
-- what is the latest split of fans by gender in percentage?
SELECT * 
FROM "FansPerGenderAge"
LIMIT 10;
--
--
-- total number of fans for the latest date
SELECT sum(number_of_fans)
FROM "FansPerGenderAge"
WHERE date = '2018-10-16';
--
-- using the above query as a sub-query to obtain the percentage in the final query
-- the result is then rounded to 2 decimal places
SELECT 
	gender,
	SUM(number_of_fans), 
	ROUND(SUM(number_of_fans) * 100 / 
		(SELECT SUM(number_of_fans)
		FROM "FansPerGenderAge"
		WHERE date = '2018-10-16'),2)
FROM "FansPerGenderAge"
WHERE date = '2018-10-16'
GROUP BY gender;
--
--
-- INNER JOINS
--

