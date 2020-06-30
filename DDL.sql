
-- Create a schema that can accommodate a hotel reservation system. Your schema should have:

-- The ability to store customer data: first and last name, an optional phone number, and multiple email addresses.
-- The ability to store the hotel's rooms: the hotel has twenty floors with twenty rooms on each floor. In addition to the floor and room number, we need to store the room's livable area in square feet.
-- The ability to store room reservations: we need to know which guest reserved which room, and during what period.



CREATE TABLE "user_info" (
    "id" SERIAL,
  "first name" TEXT,
  "last name" TEXT,
    "phone_num" TEXT,
    "email" TEXT
    
);


CREATE TABLE "hotel_info" (
    "Room_id" SERIAL,
  "Room_num" VARCHAR(2),
    "Floor_num" VARCHAR(2),
    "Area_sqft" INTEGER
);


CREATE TABLE "reservation" (
  "id" INTEGER,
    "Room_id" INTEGER,
    "Reverve_time" TIME

);