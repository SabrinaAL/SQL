-- Steps to Complete
-- Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
-- The forest_area and land_area tables join on both country_code AND year.
-- The regions table joins these based on only country_code.
-- In the ‘forestation’ View, include the following:

-- All of the columns of the origin tables
-- A new column that provides the percent of the land area that is designated as forest.
-- Keep in mind that the column forest_area_sqkm in the forest_area table and the land_area_sqmi in the land_area table are in different units (square kilometers and square miles, respectively), so an adjustment will need to be made in the calculation you write (1 sq mi = 2.59 sq km).


DROP VIEW forestation;
CREATE VIEW forestation AS (SELECT f.country_code,	f.country_name,	f.year,	f.forest_area_sqkm,	l.total_area_sq_mi, 
	 r.region, r.income_group, 100*(f.forest_area_sqkm/(l.total_area_sq_mi*2.59)) forest_percent
  FROM forest_area f
  JOIN land_area l
  ON f.year = l.year AND f.country_code = l.country_code
  JOIN regions r
  ON r.country_code = l.country_code);


-- 1. GLOBAL SITUATION
-- Instructions:

-- Answering these questions will help you add information into the template.
-- Use these questions as guides to write SQL queries.
-- Use the output from the query to answer these questions.

-- a. What was the total forest area (in sq km) of the world in 1990? 
-- Please keep in mind that you can use the country record denoted as “World" in the region table.


SELECT forest_area_sqkm
FROM forestation
WHERE country_name = 'World' AND year = 1990


-- b. What was the total forest area (in sq km) of the world in 2016? 
-- Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT forest_area_sqkm
FROM forestation
WHERE country_name = 'World' AND year = 2016

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

SELECT t1.forest_area_sqkm, t1.year, LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) lag, (LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) - t1.forest_area_sqkm) diff_area

FROM (SELECT forest_area_sqkm, year
FROM forestation
WHERE (year = 1990 OR year = 2016) AND country_name = 'World'
ORDER BY year) t1 

-- d. What was the percent change in forest area of the world between 1990 and 2016?

SELECT t1.forest_area_sqkm, t1.year, LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) lag, 
(LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) - t1.forest_area_sqkm) diff_area, 
100*( (LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) - t1.forest_area_sqkm)/LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year)) per_change

FROM (SELECT forest_area_sqkm , year
FROM forestation
WHERE (year = 1990 OR year = 2016) AND country_name = 'World'
ORDER BY year) t1 

-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT country_name, year, total_area_sq_mi*2.59 total_area_sqkm
FROM forestation
WHERE year = 2016 AND (2.59*total_area_sq_mi <= 
(SELECT (LAG(t1.forest_area_sqkm) OVER ( ORDER BY t1.year) - t1.forest_area_sqkm) diff_area
FROM (SELECT forest_area_sqkm , year
FROM forestation
WHERE (year = 1990 OR year = 2016) AND country_name = 'World'
ORDER BY year) t1 
ORDER BY diff_area 
LIMIT 1))
ORDER BY 3 DESC 


-- 2. REGIONAL OUTLOOK
-- Instructions:

-- Answering these questions will help you add information into the template.
-- Use these questions as guides to write SQL queries.
-- Use the output from the query to answer these questions.

-- Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
-- Based on the table you created, ....

-- a. What was the percent forest of the entire world in 2016? 

SELECT 100*(forest_area_sqkm/(total_area_sq_mi*2.59)) sum_percent, region, year
FROM forestation
WHERE year = 2016 AND region = 'World'
ORDER BY 1 
-- Which region had the HIGHEST percent forest in 2016
-- answer: Latin America & Caribbean

SELECT COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) sum_percent, region
FROM forestation
WHERE year = 2016
GROUP BY 2
ORDER BY 1 DESC
LIMIT 1


-- and which had the LOWEST, to 2 decimal places?
-- answer:2.07 	Middle East & North Africa

SELECT CAST(COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) as DECIMAL(10,2)) sum_percent, region
FROM forestation
WHERE year = 2016
GROUP BY 2
ORDER BY 1 
LIMIT 1


-- b. What was the percent forest of the entire world in 1990? 
-- answer: 32.4222035575689

SELECT 100*(forest_area_sqkm/(total_area_sq_mi*2.59)) sum_percent, region
FROM forestation
WHERE year = 1990 AND region = 'World'
ORDER BY 1 


-- Which region had the HIGHEST percent forest in 1990, 
-- answer: 51.0299798667514	Latin America & Caribbean

SELECT COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) sum_percent, region
FROM forestation
WHERE year = 1990
GROUP BY 2
ORDER BY 1 DESC
LIMIT 1

-- and which had the LOWEST, to 2 decimal places?
-- answer: 1.78	Middle East & North Africa

SELECT CAST(COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) as DECIMAL(10,2)) sum_percent, region
FROM forestation
WHERE year = 1990
GROUP BY 2
ORDER BY 1 
LIMIT 1


-- c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?


WITH t90 AS (SELECT CAST(COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) as DECIMAL(10,2)) sum_percent, region
FROM forestation
WHERE year = 1990
GROUP BY 2
ORDER BY 1 DESC ),

t16 AS (SELECT CAST(COALESCE(100*(SUM(forest_area_sqkm)/(SUM(total_area_sq_mi*2.59))), 0) as DECIMAL(10,2)) sum_percent, region
FROM forestation
WHERE year = 2016
GROUP BY 2
ORDER BY 1 DESC )

SELECT t16.region region, t90.sum_percent fa_percent_90, t16.sum_percent fa_percent_16, (t90.sum_percent - t16.sum_percent) diff_FA_percent
FROM t90
JOIN t16 
ON t16.region = t90.region
ORDER BY diff_FA_percent DESC

-- 3. COUNTRY-LEVEL DETAIL
-- Instructions:

-- Answering these questions will help you add information into the template.
-- Use these questions as guides to write SQL queries.
-- Use the output from the query to answer these questions.

-- a. Which 5 countries saw the largest amount increase in forest area from 1990 to 2016? 
-- What was the difference in forest area for each?

WITH t90 AS (SELECT forest_area_sqkm, country_name
FROM forestation
WHERE year = 1990
ORDER BY 1 ),

t16 AS (SELECT forest_area_sqkm, country_name
FROM forestation
WHERE year = 2016
ORDER BY 1 )

SELECT t16.country_name country_name, COALESCE((t16.forest_area_sqkm - t90.forest_area_sqkm),0) diff_FA
FROM t90
JOIN t16 
ON t16.country_name = t90.country_name
ORDER BY diff_FA DESC
LIMIT 5



-- increased in forest area by percentage from 1990 to 2016. 


WITH t90 AS (SELECT forest_area_sqkm, country_name
FROM forestation
WHERE year = 1990
ORDER BY 1 ),

t16 AS (SELECT forest_area_sqkm, country_name
FROM forestation
WHERE year = 2016
ORDER BY 1 )

SELECT t16.country_name country_name, 100*((t16.forest_area_sqkm - t90.forest_area_sqkm)/t90.forest_area_sqkm) percent_FA
FROM t90
JOIN t16 
ON t16.country_name = t90.country_name
WHERE 100*((t16.forest_area_sqkm - t90.forest_area_sqkm)/t90.forest_area_sqkm) IS NOT NULL
ORDER BY percent_FA DESC
LIMIT 5


-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 

WITH t90 AS (SELECT forest_area_sqkm, country_name, region
FROM forestation
WHERE year = 1990
ORDER BY 1 ),

t16 AS (SELECT forest_area_sqkm, country_name, region
FROM forestation
WHERE year = 2016
ORDER BY 1 )

SELECT t16.country_name country_name, t16.region region, COALESCE((t90.forest_area_sqkm - t16.forest_area_sqkm),0) diff_FA
FROM t90
JOIN t16 
ON t16.country_name = t90.country_name
WHERE t16.country_name < 'World'
ORDER BY diff_FA DESC
LIMIT 5

-- What was the percent change to 2 decimal places for each?

WITH t90 AS (SELECT forest_area_sqkm, country_name, region
FROM forestation
WHERE year = 1990
ORDER BY 1 ),

t16 AS (SELECT forest_area_sqkm, country_name, region
FROM forestation
WHERE year = 2016
ORDER BY 1 )

SELECT t16.country_name country_name, t16.region region, 
CAST(COALESCE(100*(1-(t16.forest_area_sqkm/t90.forest_area_sqkm)), 0) as DECIMAL(10,2)) percent_FA
FROM t90
JOIN t16 
ON t16.country_name = t90.country_name
ORDER BY percent_FA DESC
LIMIT 5

-- c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH t1 AS (SELECT 
CASE 
WHEN forest_percent > 75 THEN 4
WHEN forest_percent <= 75 AND forest_percent > 50 THEN 3
WHEN forest_percent <= 50 AND forest_percent > 25 THEN 2
WHEN forest_percent <= 25 THEN 1 END percent_group, year, forest_percent, country_name
FROM forestation
WHERE forest_percent IS NOT NULL )

SELECT t1.percent_group, COUNT(t1.percent_group) num_group
FROM t1
WHERE t1.year = 2016
GROUP BY 1

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

WITH t1 AS (SELECT 
CASE 
WHEN forest_percent > 75 THEN 4
WHEN forest_percent <= 75 AND forest_percent > 50 THEN 3
WHEN forest_percent <= 50 AND forest_percent > 25 THEN 2
WHEN forest_percent <= 25 THEN 1
ELSE 1 END percent_group, year, forest_percent, country_name, region
FROM forestation
WHERE forest_percent IS NOT NULL)

SELECT t1.country_name, t1.region,  t1.forest_percent
FROM t1
WHERE t1.year = 2016 AND t1.percent_group = 4
ORDER BY 3 DESC


-- e. How many countries had a percent forestation higher than the United States in 2016?
-- answer: 94
SELECT COUNT(*)
FROM forestation
WHERE year = 2016 AND forest_percent > 
(SELECT forest_percent
FROM forestation
WHERE country_name = 'United States' AND year = 2016)


-- Some additional SQL Queries 



WITH t16 AS(SELECT COALESCE(SUM(forest_area_sqkm),0) fa_sum, country_name, year, income_group
FROM forestation
WHERE (year = 2016) AND region = 'Sub-Saharan Africa'
GROUP BY 2 , 3 ,4
ORDER BY year DESC),

t90 AS(SELECT COALESCE(SUM(forest_area_sqkm),0) fa_sum, country_name, year, income_group
FROM forestation
WHERE (year = 1990) AND region = 'Sub-Saharan Africa'
GROUP BY 2 , 3 ,4
ORDER BY year DESC)

SELECT t16.country_name, t16.income_group income_in_2016, t90.income_group income_in_1990, (t90.fa_sum - t16.fa_sum) difference
FROM t16
JOIN t90
ON t16.country_name = t90.country_name
ORDER BY difference DESC
