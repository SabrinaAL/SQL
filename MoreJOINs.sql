-- You’re not likely to use FULL JOIN (which can also be written as FULL OUTER JOIN) too often, but the syntax is worth practicing anyway. LEFT JOIN and RIGHT JOIN each return unmatched rows from one of the tables—FULL JOIN returns unmatched rows from both tables. FULL JOIN is commonly used in conjunction with aggregations to understand the amount of overlap between two tables.

-- Say you're an analyst at Parch & Posey and you want to see:

-- each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
-- but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)
-- This type of question is rare, but FULL OUTER JOIN is perfect for it. In the following SQL Explorer, write a query with FULL OUTER JOIN to fit the above described Parch & Posey scenario (selecting all of the columns in both of the relevant tables, accounts and sales_reps) then answer the subsequent multiple choice quiz.

SELECT *
FROM accounts a
FULL OUTER JOIN sales_reps s
ON s.id = a.sales_rep_id

-- Inequality operators (a.k.a. comparison operators) don't only need to be date times or numbers, they also work on strings! You'll see how this works by completing the following quiz, which will also reinforce the concept of joining with comparison operators.

-- In the following SQL Explorer, write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:

-- accounts.primary_poc < sales_reps.name
-- The query results should be a table with three columns: the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name (e.g. Samuel Racine). Then answer the subsequent multiple choice question.
SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name

-- One of the most common use cases for self JOINs is in cases where two events occurred, one after another. As you may have noticed in the previous video, using inequalities in conjunction with self JOINs is common.

-- Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same interval analysis except for the web_events table. Also:

-- change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
-- add a column for the channel variable in both instances of the table in your query
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at



SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w1.occurred_at > w2.occurred_at
  AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w1.occurred_at


-- Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table. 
-- If you do this correctly, your query results should have a count of 2 for each name.

SELECT COUNT(name) count_name, name
FROM (SELECT *
FROM accounts

UNION ALL

SELECT *
FROM accounts) double_accounts
GROUP BY name