
-- Create a schema that can accommodate a hotel reservation system. Your schema should have:

-- The ability to store customer data: first and last name, an optional phone number, and multiple email addresses.
-- The ability to store the hotel's rooms: the hotel has twenty floors with twenty rooms on each floor. In addition to the floor and room number, we need to store the room's livable area in square feet.
-- The ability to store room reservations: we need to know which guest reserved which room, and during what period.


CREATE TABLE "customers" (
  "id" SERIAL,
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "phone_number" VARCHAR
);

CREATE TABLE "customer_emails" (
  "customer_id" INTEGER,
  "email_address" VARCHAR
);

CREATE TABLE "rooms" (
  "id" SERIAL,
  "floor" SMALLINT,
  "room_no" SMALLINT,
  "area_sqft" SMALLINT
);

CREATE TABLE "reservations" (
  "id" SERIAL,
  "customer_id" INTEGER,
  "room_id" INTEGER,
  "check_in" DATE,
  "check_out" DATE
);



-- It was found out that email addresses can be longer than 50 characters. We decided to remove the limit on email address lengths to keep things simple.
-- We'd like the course ratings to be more granular than just integers 0 to 10, also allowing values such as 6.45 or 9.5
-- We discovered a potential issue with the registrations table that will manifest itself as the number of new students and new courses keeps increasing. Identify the issue and fix it.

ALTER TABLE "students" ALTER COLUMN "email_address" SET DATA TYPE VARCHAR;

ALTER TABLE "courses" ALTER COLUMN "rating" SET DATA TYPE REAL;

ALTER TABLE "registrations" ALTER COLUMN "student_id" SET DATA TYPE INTEGER;
ALTER TABLE "registrations" ALTER COLUMN "course_id" SET DATA TYPE INTEGER;



-- TRUNCATE TABLE keeps the table structure intact, but removes all the data in the table. 
-- If you add the optional RESTART IDENTITY to the command, a SERIAL column's sequence will have its next value reset to 1.

-- Finally, the COMMENT command allows you to add a text comment on a table's column. 
-- If describing a table using \d table_name, you won't see the comments. 
-- You'd have to use \d+ in order to see the comments that were defined on a table.

-- Exercise Instructions¶
-- In this exercise, you'll be asked to migrate a table of denormalized data into two normalized tables. The table called denormalized_people contains a list of people, but there is one problem with it: the emails column can contain multiple emails, violating one of the rules of first normal form. What more, the primary key of the denormalized_people table is the combination of the first_name and last_name columns. Good thing they're unique for that data set!

-- In a first step, you'll have to migrate the list of people without their emails into the normalized people table, which contains an id SERIAL column in addition to first_name and last_name.

-- Once that is done, you'll have to craft an appropriate query to migrate the email addresses of each person to the normalized people_emails table. Note that this table has columns person_id and email, so you'll have to find a way to get the person_id corresponding to the first_name + last_name combination of the denormalized_people table.

-- Hint #1: You'll need to use the Postgres regexp_split_to_table function to split up the emails
-- Hint #2: You'll be using INSERT...SELECT queries to achieve the desired result
-- Hint #3: If you're not certain about your INSERT query, use simple SELECTs until you have the correct output. Then, use that same SELECT inside an INSERT...SELECT query to finalize the exercise.


-- Migrate people
INSERT INTO "people" ("first_name", "last_name")
  SELECT "first_name", "last_name" FROM "denormalized_people";


  -- Migrate people's emails using the correct ID
INSERT INTO "people_emails"
SELECT
  "p"."id",
  REGEXP_SPLIT_TO_TABLE("dn"."emails", ',')
FROM "denormalized_people" "dn"
JOIN "people" "p" ON (
  "dn"."first_name" = "p"."first_name"
  AND "dn"."last_name" = "p"."last_name"
);


-- Exercise Instructions
-- For this exercise, you're being asked to fix a people table that contains some data annoyances due to the way the data was imported:

-- All values of the last_name column are currently in upper-case. We'd like to change them from e.g. "SMITH" to "Smith". Using an UPDATE query and the right string function(s), make that happen.

-- Instead of dates of birth, the table has a column born_ago, a TEXT field of the form e.g. '34 years 5 months 3 days'. 
-- We'd like to convert this to an actual date of birth. In a first step, use the appropriate DDL command to add a date_of_birth column of the appropriate data type. Then, using an UPDATE query, set the date_of_birth column to the correct value based on the value of the born_ago column. 
-- Finally, using another DDL command, remove the born_ago column from the table.

-- Update the last_name column to be capitalized
UPDATE "people" SET "last_name" =LOWER("last_name");

UPDATE "people" SET "last_name" =INITCAP("last_name");


-- Another solution for the problem above

UPDATE "people" SET "last_name" =
  SUBSTR("last_name", 1, 1) ||
  LOWER(SUBSTR("last_name", 2));

-- Change the born_ago column to date_of_birth
ALTER TABLE "people" ADD column "date_of_birth" DATE;

UPDATE "people" SET "date_of_birth" = 
  (CURRENT_TIMESTAMP - "born_ago"::INTERVAL)::DATE;



ALTER TABLE "people" DROP COLUMN "born_ago";


-- Exercise Instructions
-- For this exercise, you'll be given a table called user_data, and asked to make some changes to it. In order to make sure that your changes happen coherently, you're asked to turn off auto-commit, and create your own transaction around all the queries you will run.

-- Here are the changes you will need to make:

-- Due to some obscure privacy regulations, all users from California and New York must be removed from the data set.
-- For the remaining users, we want to split up the name column into two new columns: first_name and last_name.
-- Finally, we want to simplify the data by changing the state column to a state_id column.
-- First create a states table with an automatically generated id and state abbreviation.
-- Then, migrate all the states from the dataset to that table, taking care to not have duplicates.
-- Once all the states are migrated and have their unique ID, add a state_id column to the user_data table.
-- Use the appropriate query to make the state_id of the user_data column match the appropriate ID from the new states table.
-- Remove the now redundant state column from the user_data table.

-- Do everything in a transaction
BEGIN;


-- Remove all users from New York and California
DELETE FROM "user_data" WHERE "state" IN ('NY', 'CA');


-- Split the name column in first_name and last_name
ALTER TABLE "user_data"
  ADD COLUMN "first_name" VARCHAR,
  ADD COLUMN "last_name" VARCHAR;

UPDATE "user_data" SET
  "first_name" = SPLIT_PART("name", ' ', 1),
  "last_name" = SPLIT_PART("name", ' ', 2);

ALTER TABLE "user_data" DROP COLUMN "name";


-- Change from state to state_id
CREATE TABLE "states" (
  "id" SMALLSERIAL,
  "state" CHAR(2)
);

INSERT INTO "states" ("state")
  SELECT DISTINCT "state" FROM "user_data";

ALTER TABLE "user_data" ADD COLUMN "state_id" SMALLINT;

UPDATE "user_data" SET "state_id" = (
  SELECT "s"."id"
  FROM "states" "s"
  WHERE "s"."state" = "user_data"."state"
);

ALTER TABLE "user_data" DROP COLUMN "state";