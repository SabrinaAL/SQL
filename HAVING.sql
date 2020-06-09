-- How many of the sales reps have more than 5 accounts that they manage?

SELECT s.name, COUNT(a.name) 
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
GROUP by s.name
HAVING COUNT(a.name) > 5;

-- How many accounts have more than 20 orders?
SELECT a.name, COUNT(o.id) 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP by a.name
HAVING COUNT(o.id) > 20
ORDER BY COUNT(o.id);

-- Which account has the most orders?

SELECT a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP by a.name
ORDER BY COUNT(o.id) DESC;



-- Which accounts spent more than 30,000 usd total across all orders?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

-- Which account has spent the most with us?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;

-- Which account has spent the least with us?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent 
LIMIT 1;


-- Which accounts used facebook as a channel to contact customers more than 6 times?

SELECT w.channel, a.id, COUNT(a.id) 
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.channel, a.id
HAVING w.channel LIKE 'facebook' AND COUNT(a.id) > 6
ORDER BY COUNT(a.id)


-- Which account used facebook most as a channel?

SELECT w.channel,a.name, a.id, COUNT(a.id) 
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.channel, a.id, a.name
HAVING w.channel LIKE 'facebook'
ORDER BY COUNT(a.id) DESC
LIMIT 1;

-- Which channel was most frequently used by most accounts?

SELECT w.channel,a.name, a.id, COUNT(a.id) 
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY w.channel, a.id, a.name
ORDER BY COUNT(a.id) DESC


-- Which channel was most frequently used by most accounts?

