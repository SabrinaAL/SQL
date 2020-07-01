
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

-- Exercise Instructions
-- For this exercise, you're going to have to explore the data schema in the Postgres workspace in order to determine which pieces of data require Unique and Primary Key constraints. Then, you'll have to execute the appropriate ALTER TABLE statements to add these constraints to the data set.

-- Hint: There are 6 total constraints to be added.

ALTER TABLE "books" ADD PRIMARY KEY ("id");

ALTER TABLE "books" ADD UNIQUE ("isbn");

ALTER TABLE "authors" ADD PRIMARY KEY ("id");

ALTER TABLE "authors" ADD UNIQUE ("email_address");

ALTER TABLE "book_authors" ADD PRIMARY KEY ("book_id", "author_id");

ALTER TABLE "book_authors" ADD UNIQUE ("book_id", "contribution_rank");


-- Exercise Instructions
-- For this exercise, you're going to add some foreign key constraints to an existing schema, but you'll have to respect some business rules that were put in place:

-- As a first step, please explore the currently provided schema and understand the relationships between all the tables
-- Once that's done, please create all the foreign key constraints that are necessary to keep the referential integrity of the schema, with the following in mind:
-- When an employee who's a manager gets deleted from the system, we want to keep all the employees that were under him/her. They simply won't have a manager assigned to them.
-- We can't delete an employee as long as they have projects assigned to them
-- When a project gets deleted from the system, we won't need to keep track of the people who were working on it.

ALTER TABLE "employees"
  ADD CONSTRAINT "valid_manager"
  FOREIGN KEY ("manager_id") REFERENCES "employees" ("id") ON DELETE SET NULL;

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_employee"
  FOREIGN KEY ("employee_id") REFERENCES "employees" ("id");

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_project"
  FOREIGN KEY ("project_id") REFERENCES "projects" ("id") ON DELETE CASCADE;


  -- Given a table users with a date_of_birth column of type DATE, write the SQL to add a requirement for users to be at least 18 years old.

  ALTER TABLE "users"
  ADD CONSTRAINT "users_must_be_over_18" CHECK (
    CURRENT_TIMESTAMP - "date_of_birth" > INTERVAL '18 years'
  );




--   Exercise Instructions
-- In this exercise, you're going to manage a database schema that contains no constraints, allowing you to practice all the concepts that you learned in this lesson!

-- After exploring the schema, this is what you'll have to identify the following for each table, and add the appropriate constraints for them:

-- Identify the primary key for each table
-- Identify the unique constraints necessary for each table
-- Identify the foreign key constraints necessary for each table
-- In addition to the three types of constraints above, you'll have to implement some custom business rules:
-- Usernames need to have a minimum of 5 characters
-- A book's name cannot be empty
-- A book's name must start with a capital letter
-- A user's book preferences have to be distinct

  -- Primary and unique keys
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");

ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id");


-- Foreign keys
ALTER TABLE "user_book_preferences"
  ADD FOREIGN KEY ("user_id") REFERENCES "users",
  ADD FOREIGN KEY ("book_id") REFERENCES "books";


-- Usernames need to have a minimum of 5 characters
ALTER TABLE "users" ADD CHECK (LENGTH("username") >= 5);


-- A book's name cannot be empty
ALTER TABLE "books" ADD CHECK(LENGTH(TRIM("name")) > 0);


-- A book's name must start with a capital letter
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);


-- A user's book preferences have to be distinct
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preference");