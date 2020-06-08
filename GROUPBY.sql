-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

SELECT account_id, MIN(occurred_at) AS earliest_order
FROM orders
GROUP BY account_id
ORDER BY account_id;

-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.

SELECT account_id, SUM(total_amt_usd) AS total_usd
FROM orders
GROUP BY account_id
ORDER BY account_id 


-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
-- Your query should return only three values - the date, channel, and account name.

SELECT channel, MAX(occurred_at) AS recent_events
FROM web_events
GROUP BY channel
ORDER BY channel 

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