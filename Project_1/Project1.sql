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
  ON r.country_code = l.country_code)


-- 1. GLOBAL SITUATION
-- Instructions:

-- Answering these questions will help you add information into the template.
-- Use these questions as guides to write SQL queries.
-- Use the output from the query to answer these questions.

-- a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
-- answer: 82016472.036028

SELECT SUM(forest_area_sqkm) sum_area_1990
FROM forest_area
WHERE year = 1990
GROUP BY year

SELECT SUM(forest_area_sqkm) sum_area_1990
FROM forestation
WHERE year = 1990
GROUP BY year


-- b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
-- answer: 79825433.9505107

SELECT SUM(forest_area_sqkm) sum_area_1990
FROM forestation
WHERE year = 2016
GROUP BY year

-- c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
-- answer: 2191038.08551738

SELECT t1.sum_area, t1.year, LAG(t1.sum_area) OVER ( ORDER BY t1.year) lag, (LAG(t1.sum_area) OVER ( ORDER BY t1.year) - t1.sum_area) diff_area, 

FROM (SELECT SUM(forest_area_sqkm) sum_area, year
FROM forestation
WHERE year = 1990 OR year = 2016
GROUP BY 2
ORDER BY year) t1 

-- d. What was the percent change in forest area of the world between 1990 and 2016?

-- e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT country_name, year, forest_area_sqkm
FROM forest_area
WHERE year = 2016 AND (forest_area_sqkm >= 1999999 AND forest_area_sqkm <= 
(SELECT (LAG(t1.sum_area) OVER ( ORDER BY t1.year) - t1.sum_area) diff_area
FROM (SELECT SUM(forest_area_sqkm) sum_area, year
FROM forest_area
WHERE year = 1990 OR year = 2016
GROUP BY 2
ORDER BY year) t1 
ORDER BY diff_area 
LIMIT 1))


-- 2. REGIONAL OUTLOOK
-- Instructions:

-- Answering these questions will help you add information into the template.
-- Use these questions as guides to write SQL queries.
-- Use the output from the query to answer these questions.

-- Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
-- Based on the table you created, ....

-- a. What was the percent forest of the entire world in 2016? 
-- Which region had the HIGHEST percent forest in 2016
-- answer: 98.2576939676578,	Latin America & Caribbean

SELECT CAST(MAX(COALESCE(forest_percent, 0)) as DECIMAL(10,2)) max_forest_percent, region
FROM forestation
WHERE year = 2016
GROUP BY 2
LIMIT 1


-- and which had the LOWEST, to 2 decimal places?
-- answer:0.000535997085208853	Europe & Central Asia

SELECT CAST((forest_percent) as DECIMAL(10,2)), region
FROM forestation
WHERE year = 2016
ORDER BY 1 
LIMIT 1


-- b. What was the percent forest of the entire world in 1990? 

-- Which region had the HIGHEST percent forest in 1990, 
-- answer: 98.91	Latin America & Caribbean

-- and which had the LOWEST, to 2 decimal places?
-- answer: 0.00	Europe & Central Asia
SELECT CAST((forest_percent) as DECIMAL(10,2)), region
FROM forestation
WHERE year = 1990
ORDER BY 1 
LIMIT 1



-- c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?