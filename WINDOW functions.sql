-- Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
-- Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.

SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at DESC) AS running_total
FROM orders

-- Now, modify your query from the previous quiz to include partitions. 
-- Still create a running total of standard_amt_usd (in the orders table) over order time, but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. 
-- Your final table should have three columns: 
-- One with the amount being added for each row, one for the truncated date, and a final column with the running total within each year.

SELECT standard_amt_usd, DATE_TRUNC('year', occurred_at),  
SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at)  ORDER BY occurred_at DESC) AS running_total
FROM orders

-- Select the id, account_id, and total variable from the orders table, 
-- then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. 
-- Your final table should have these four columns.

SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders


-- Now, create and use an alias to shorten the following query (which is different from the one in Derek's previous video) that has multiple window functions. 
-- Name the alias account_year_window, which is more descriptive than main_window in the example above.

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)