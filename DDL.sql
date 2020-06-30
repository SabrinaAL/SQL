
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