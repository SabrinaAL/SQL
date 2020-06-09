-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.

SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;


-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
-- Your query should return only three values - the date, channel, and account name.

SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;

-- Find the total number of times each type of channel from the web_events was used. 
-- Your final table should have two columns - the channel and the number of times the channel was used.

SELECT channel, COUNT(channel) AS total_use
FROM web_events
GROUP BY channel
ORDER BY COUNT(channel) 

-- Who was the primary contact associated with the earliest web_event?

SELECT MIN(w.occurred_at) AS recent_events, a.primary_poc
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY a.primary_poc
ORDER BY MIN(w.occurred_at) 
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd. 
-- Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.

SELECT a.name, MIN(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY MIN(o.total_amt_usd);

-- Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. 
-- Order from fewest reps to most reps.

SELECT r.name, COUNT(s.name)
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY COUNT(s.name);


-- For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.

SELECT a.name, AVG(o.standard_qty) standard_average, AVG(o.gloss_qty) gloss_average, AVG(o.poster_qty) poster_average
FROM accounts a
JOIN orders o
ON a.id = o. account_id
GROUP BY a.name
ORDER by a.name

-- For each account, determine the average amount spent per order on each paper type. 
-- Your result should have four columns - one for the account name and one for the average amount spent on each paper type.


SELECT a.name, AVG(o.standard_amt_usd) standard_average, AVG(o.gloss_amt_usd) gloss_average, AVG(o.poster_amt_usd) poster_average
FROM accounts a
JOIN orders o
ON a.id = o. account_id
GROUP BY a.name
ORDER by a.name


-- Determine the number of times a particular channel was used in the web_events table for each sales rep. 
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.

SELECT s.name, w.channel, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY COUNT(w.channel) DESC


-- Determine the number of times a particular channel was used in the web_events table for each region. 
-- Your final table should have three columns - the region name, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first. 

SELECT r.name, w.channel, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY COUNT(w.channel) DESC


