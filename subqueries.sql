-- Average number of events per channel each day

SELECT AVG(sub.events) AS AVG, sub.channel
FROM (SELECT DATE_TRUNC('day', w.occurred_at) AS day, w.channel, COUNT(*) AS events
FROM web_events w
GROUP BY 1, 2
ORDER BY events DESC) sub
GROUP BY sub.channel
ORDER BY 1 DESC

-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;


-- For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

SELECT t1.sum, t1.region_name, COUNT(o.id)
FROM
(SELECT SUM(o.total_amt_usd) sum, r.name region_name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 1) t1
JOIN region r
ON r.name = t1.region_name
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE r.name = t1.region_name
GROUP BY 1, 2



-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?


SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GåçROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)



-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
SELECT COUNT(*), w.channel
FROM web_events w
JOIN accounts a 
ON a.id = w.account_id
JOIN (SELECT t.sum, t.name_acc
FROM (SELECT SUM(o.total_amt_usd) sum, a.name name_acc, w.id id_web, w.channel channel
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN web_events w
ON w.account_id = a.id
GROUP BY 2, 3 ,4
ORDER BY 1 DESC
LIMIT 1 ) t) t1
ON t1.name_acc = a.name
GROUP BY 2
ORDER BY 1 


-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp


-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;


-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

WITH t2 AS (SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1), 
     t3 AS (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC)

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM t3
JOIN t2
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

-- For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH t1 AS 
(SELECT SUM(o.total_amt_usd) sum, r.name region_name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON s.region_id = r.id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 1)

SELECT t1.sum, t1.region_name, COUNT(o.id)
FROM t1
JOIN region r
ON r.name = t1.region_name
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE r.name = t1.region_name
GROUP BY 1, 2

-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?

WITH t1 AS (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1)


SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT t1.total 
                   FROM t1)


-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

WITH t1 AS (SELECT t.sum, t.name_acc
FROM (SELECT SUM(o.total_amt_usd) sum, a.name name_acc, w.id id_web, w.channel channel
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN web_events w
ON w.account_id = a.id
GROUP BY 2, 3 ,4
ORDER BY 1 DESC
LIMIT 1 ) t)


SELECT COUNT(*), w.channel
FROM web_events w
JOIN accounts a 
ON a.id = w.account_id
JOIN t1
ON t1.name_acc = a.name
GROUP BY 2
ORDER BY 1

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH t1 AS (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10)
SELECT AVG(tot_spent)
FROM t1

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;