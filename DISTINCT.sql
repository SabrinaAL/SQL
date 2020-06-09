-- Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT DISTINCT id, name
FROM accounts;


-- Have any sales reps worked on more than one account?

SELECT DISTINCT id, name
FROM sales_reps;