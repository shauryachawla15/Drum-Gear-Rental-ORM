/*

-- NOTE: Table structure (Gear, Rental, Customer, etc.) was defined in Milestone 2.
-- This file only contains business logic as per Milestone 3 requirements.

----------------------------------------------------------
Milestone 3: Business Requirements and Implementation
----------------------------------------------------------
-- Table of Contents
-- 1. Table of Contents
-- 2. Cover Page
-- 3. Business Requirements Implementation Overview
-- 4. SQL-Based Business Requirements
-- 5. Demonstration Queries & Results
-- 6. Conclusion


-- Cover Page
-- Project Title: Drum Gear Rental & Sales System
-- Student Name: Shaurya Chawla
-- SFSU Email: schawla@sfsu.edu
-- Version: 3.0
--Milestone: Milestone 3 —Business Requirements and Implementation 
--Submitted: 07/11/2025
/*
----------------------------------------------------------
Business Requirements Implementation Overview
----------------------------------------------------------

-- In this milestone, I implemented 10 advanced business requirements for the Drum Gear Rental & Sales System. These requirements are aligned with the unique features from Milestone 1, addressing gear availability, rentals, customer handling, and payment automation just like the Guitar center and Sweet Water music stores Database system in the USA.
-- The implementation uses SQL components such as triggers, stored procedures, functions, and scheduled events to improve business automation, security, and performance. Each requirement addresses a real-world challenge and includes an explanation of the problem, assumptions made, an implementation plan, and a working SQL solution.


---------------------------------------------------------------------------------------
SQL-Based Business Requirements (Summarized List) with Demonstration Queries & Results
---------------------------------------------------------------------------------------
/* 1.Prevent Out-of-Stock Rentals:

-- Purpose
 -- To ensure that the customers cannot rent gear that is out of stock, protecting the business from over-promising unavailable inventory.

-- Description
-- When a customer attempts to rent a gear item, the system must check if the gear is currently available in inventory. If the gear quantity is zero or less, the system should prevent the rental transaction from being processed.

-- Challenge
-- Without this safeguard, it is possible for users to rent gear that isn’t in stock, leading to inventory mismatches, operational confusion, and customer dissatisfaction. This problem must be caught at the database level for full reliability.

-- Assumptions
 -- There is a table named Gear with a quantity column representing current stock.
 -- Rentals are added to a table named Rental, where each rental references a gear_id.
 -- A gear item with quantity <= 0 is considered unavailable.

-- Implementation Plan

Create a BEFORE INSERT trigger on the Rental table.
-- In the trigger, check the Gear.quantity for the inserted gear_id.
-- If the quantity is zero or less, block the insertion using SIGNAL SQLSTATE.

 --Sql Implementation:
-- Adding a gear with 0 quantity

INSERT INTO Gear (gear_id, name, quantity) VALUES (101, 'Crash Cymbal', 0);
-- Try to create a rental for that gear
INSERT INTO Rental (rental_id, customer_id, gear_id, rental_date)
-- VALUES (1, 1, 101, CURDATE());


-- Expected Result:
   Error: Gear is out of stock and cannot be rented. (from the SIGNAL in your trigger) */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 2. Auto-Decrease Gear Quantity After Rental:

-- Purpose
 -- To automatically reduce the quantity of a gear item in stock after a successful rental is placed.

-- Description
 -- Every time a new rental is inserted, the quantity of the rented gear in the Gear table should automatically decrease by 1. This helps maintain real-time inventory without needing manual updates.

-- Challenge
-- Without automation, admins or staff would have to manually adjust inventory after each rental, which is error-prone and inefficient. These risks overselling or inaccurate stock levels.

-- Assumptions
 -- The Rental table logs each rental with a reference to gear_id.
 -- The Gear table holds the stock quantity for each item.
 -- The rental is valid and gear was in stock before (requirement R1 already ensures this).

-- Implementation Plan

 -- Create an AFTER INSERT trigger on the Rental table.
 -- When a new rental is added, subtract 1 from the corresponding gear's quantity.
 -- Ensure no negative quantity is allowed (handled already in R1).

-- SQL Implementation:

DELIMITER $$
CREATE TRIGGER update_gear_quantity_after_rental
-- AFTER INSERT ON Rental
-- FOR EACH ROW
-- BEGIN
-- UPDATE Gear
-- SET quantity = quantity - 1
-- WHERE gear_id = NEW.gear_id;
-- END$$
DELIMITER ;



-- Demonstration: Auto-Decrease Gear Quantity:

-- Assume gear 201 has quantity 5
INSERT INTO Gear (gear_id, name, quantity) VALUES (201, 'Snare Drum', 5);
-- Customer rents gear 201
INSERT INTO Rental (rental_id, customer_id, gear_id, rental_date)
-- VALUES (2, 1, 201, CURDATE());
-- Check inventory
-- SELECT quantity FROM Gear WHERE gear_id = 201;


-- Expected Result:
--  quantity should now be 4 (automatically reduced). */


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* 3. Register New Customer with Defaults:

-- Purpose:
-- To simplify the customer onboarding process by allowing staff/admins to register a new customer with basic info and assign default values where optional details are not provided.

-- Description
-- The system should allow creation of a new customer profile using a stored procedure. If optional fields like phone or address are not provided, the procedure should auto-assign nulls safely, while ensuring the email is unique.

-- Challenge
-- Manual customer creation can be error-prone and repetitive. Also, failing to handle missing values can break future processes (like billing or rentals). This procedure ensures smooth, standard registration logic.

-- Assumptions
-- The Customer table has:
-- customer_id (PK)
-- first_name, last_name
-- email (must be unique)
-- phone (optional)
-- address (optional)
-- A default value "Not Provided" will be inserted if phone/address are not included.

-- Implementation Plan

Create a procedure with IN parameters for first_name, last_name, and email.
-- Optional fields (phone, address) will accept null and be filled with default text.
-- Ensure no duplicate email is allowed inside the procedure.

-- SQL Implementation:
DELIMITER $$
CREATE PROCEDURE RegisterNewCustomer(
-- IN p_fname VARCHAR(50),
-- IN p_lname VARCHAR(50),
-- IN p_email VARCHAR(100),
-- IN p_phone VARCHAR(20),
-- IN p_address VARCHAR(255)
-- )
-- BEGIN
-- -- Check if email already exists
-- IF EXISTS (
-- SELECT 1 FROM Customer WHERE email = p_email
-- ) THEN
-- SIGNAL SQLSTATE '45000'
-- SET MESSAGE_TEXT = 'Email already registered.';
-- ELSE
-- -- Insert new customer with default fallback for optional fields
        INSERT INTO Customer (first_name, last_name, email, phone, address)
-- VALUES (
-- p_fname,
-- p_lname,
-- p_email,
-- IFNULL(p_phone, 'Not Provided'),
-- IFNULL(p_address, 'Not Provided')
-- );
-- END IF;
-- END$$
DELIMITER ;



-- Demonstration: Register New Customer:


-- Register a customer with all fields
CALL RegisterNewCustomer('Shaurya', 'Chawla', 'shauryachawla15@gmail.com', '9876543210', 'Paschim Vihar');
-- Register a customer with missing phone/address
CALL RegisterNewCustomer('Rahul', 'Verma', 'rahulv@example.com', NULL, NULL);
-- Check inserted data
-- SELECT * FROM Customer;


-- Expected Result:
-- Second customer should show phone and address as "Not Provided". */

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 4. Complete Rental and Record Payment:

-- Purpose
-- To mark a gear rental as returned and automatically update the payment status and return date in the database.

-- Description
-- When a customer returns gear, the rental status should be updated to 'Returned', the current date should be logged, and payment recorded. This operation needs to be safe and encapsulated in a single procedure to prevent partial updates.

-- Challenge
-- Updating multiple fields across a table in one go, while ensuring that only active rentals are affected, which then requires a clean transactional handling. This avoids issues like double returns or invalid updates.

-- Assumptions
-- The Rental table has:
-- rental_id
-- gear_id
-- customer_id
-- rental_date
-- return_date
-- status (e.g., 'Active', 'Returned')
-- payment_status ('Pending', 'Paid')
-- Only rentals with status 'Active' can be returned.

-- Implementation Plan
Create a stored procedure CompleteRental with IN parameter for rental_id.
-- Check if the rental is active.
-- If yes, set status to 'Returned', set return_date to CURDATE(), and payment_status to 'Paid'.

-- SQL Implementation:

DELIMITER $$
CREATE PROCEDURE CompleteRental(
-- IN p_rental_id INT
-- )
-- BEGIN
-- DECLARE rental_status VARCHAR(20);
-- -- Get current status of the rental
-- SELECT status INTO rental_status
-- FROM Rental
-- WHERE rental_id = p_rental_id;
-- -- Check if it's already returned
-- IF rental_status = 'Returned' THEN
-- SIGNAL SQLSTATE '45000'
-- SET MESSAGE_TEXT = 'This rental has already been returned.';
-- ELSE
-- -- Update return status and payment
-- UPDATE Rental
-- SET
-- status = 'Returned',
-- return_date = CURDATE(),
-- payment_status = 'Paid'
-- WHERE rental_id = p_rental_id;
-- END IF;
-- END$$
DELIMITER ;


-- Demonstration: Mark Rental as Returned:

-- Mark rental ID 2 as returned
CALL CompleteRental(2);
-- Verify status
-- SELECT * FROM Rental WHERE rental_id = 2;


-- Expected Result:
-- Rental status updated to 'Returned', return_date = today, payment_status = 'Paid'.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 5. Generate Monthly Sales Summary Automatically:

-- Purpose
-- To automate the monthly reporting by generating a summary of all rentals completed in the past month, including total revenue and number of transactions.

-- Description
-- The business needs a monthly record of how much money was made through gear rentals and how many rentals were completed. This report should be generated automatically on the first day of every month, without manual effort.

-- Challenge
-- Manual reporting is time-consuming and error-prone. Automating this process using scheduled events ensures that the business has reliable metrics consistently.

-- Assumptions
-- The Rental table has:
-- rental_id
-- rental_date
-- return_date
-- status
-- payment_status
-- amount_paid (assumed to exist for simplicity)
-- A MonthlyReport table exists with:
-- report_id (PK, auto-increment)
-- month
-- year
-- total_revenue
-- total_rentals
-- generated_on (timestamp)


-- Implementation Plan

Create the MonthlyReport table.
-- Write an event that runs on the 1st of each month.
-- The event calculates total revenue and rental count from the last month.
-- The result is inserted into MonthlyReport.


-- SQL Implementation:

-- Step 1: Create MonthlyReport Table
CREATE TABLE IF NOT EXISTS MonthlyReport (
-- report_id INT AUTO_INCREMENT PRIMARY KEY,
-- month INT,
-- year INT,
-- total_revenue DECIMAL(10,2),
-- total_rentals INT,
-- generated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- Step 2: Enable Event Scheduler
-- SET GLOBAL event_scheduler = ON;

-- Step 3: Create Monthly Event
DELIMITER $$
CREATE EVENT IF NOT EXISTS GenerateMonthlyRentalSummary
-- ON SCHEDULE EVERY 1 MONTH
-- STARTS TIMESTAMP(CURDATE() + INTERVAL 1 DAY) -- Starts tomorrow
-- DO
-- BEGIN
-- DECLARE v_month INT;
-- DECLARE v_year INT;
-- SET v_month = MONTH(CURDATE() - INTERVAL 1 MONTH);
-- SET v_year = YEAR(CURDATE() - INTERVAL 1 MONTH);
    INSERT INTO MonthlyReport (month, year, total_revenue, total_rentals)
-- SELECT
-- v_month,
-- v_year,
-- IFNULL(SUM(amount_paid), 0),
-- COUNT(*)
-- FROM Rental
-- WHERE status = 'Returned'
-- AND MONTH(return_date) = v_month
-- AND YEAR(return_date) = v_year;
-- END$$
DELIMITER ;


-- Demonstration: Manually Triggering for Testing:

-- Simulate running it early for test
CALL GenerateMonthlyRentalSummary();
-- SELECT * FROM MonthlyReport;


-- Expected Result:
-- A new row in MonthlyReport showing total revenue and rental count for last month.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 6. Check Gear Availability (Reusable Function):

-- Purpose
-- To allow the staff or the system to check whether a specific gear item is available for rental based on its current stock quantity.

-- Description
-- Before a rental request is accepted, the system should verify if the gear is in stock. This logic should be centralized in a function that can be reused in procedures, views, or app logic.

-- Challenge
-- You don't want to duplicate gear-checking logic in every place (triggers, procedures, frontend calls). A reusable function ensures consistency and cleaner design.

-- Assumptions
-- The Gear table has:
-- gear_id
-- name
-- quantity
-- If quantity > 0, the gear is available.


-- Implementation Plan

Create a deterministic function IsGearAvailable that returns a BOOLEAN.
-- It will accept a gear_id and return TRUE if quantity > 0, else FALSE.
-- This function can be used in procedures like RegisterRental, or checks before insert.


-- SQL Implementation:

DELIMITER $$
CREATE FUNCTION IsGearAvailable(p_gear_id INT)
-- RETURNS BOOLEAN
-- DETERMINISTIC
-- BEGIN
-- DECLARE v_quantity INT;
-- SELECT quantity INTO v_quantity
-- FROM Gear
-- WHERE gear_id = p_gear_id;
-- RETURN v_quantity > 0;
-- END$$
DELIMITER ;



-- Demonstration: Check Gear Availability:

-- Gear exists and has quantity
-- SELECT IsGearAvailable(201); -- Returns TRUE
-- Gear exists but has 0 quantity
-- SELECT IsGearAvailable(101); -- Returns FALSE
-- Gear doesn’t exist
-- SELECT IsGearAvailable(999); -- NULL


-- Expected Result:
-- Function returns 1 (TRUE) or 0 (FALSE) — which can be reused in logic like preventing rentals. */


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 7. Prevent Double Booking of Gear:

-- Purpose
-- To prevent the same gear item from being rented by multiple customers on the same day.

-- Description
-- The system must reject a new rental if the gear is already booked (has an active rental) for the same date. This helps avoid double booking, confusion and ensures fair gear usage.

-- Challenge
-- If multiple users or admins try to rent the same gear on the same day or within overlapping windows, the database must catch and reject it before the rental is processed.

-- Assumptions
-- Rentals are single-day based for simplicity.
-- The Rental table includes:
-- rental_id
-- gear_id
-- rental_date
-- status (e.g., 'Active', 'Returned')
-- We only block gear that’s still 'Active' for that date.


-- Implementation Plan

Create a BEFORE INSERT trigger on the Rental table.
-- Check if the same gear is already rented out on the given date with 'Active' status.
-- If found, block the new rental using SIGNAL.


-- SQL Implementation:

DELIMITER $$
CREATE TRIGGER prevent_double_booking
-- BEFORE INSERT ON Rental
-- FOR EACH ROW
-- BEGIN
-- DECLARE v_exists INT;
-- SELECT COUNT(*) INTO v_exists
-- FROM Rental
-- WHERE gear_id = NEW.gear_id
-- AND rental_date = NEW.rental_date
-- AND status = 'Active';
-- IF v_exists > 0 THEN
-- SIGNAL SQLSTATE '45000'
-- SET MESSAGE_TEXT = 'Double booking error: Gear is already rented for this date.';
-- END IF;
-- END$$
DELIMITER ;


-- Demonstration: Preventing Double Booking:

-- Existing rental on July 9
INSERT INTO Rental (rental_id, customer_id, gear_id, rental_date, status)
-- VALUES (100, 1, 501, '2025-07-09', 'Active');
-- Try booking same gear on same day again
INSERT INTO Rental (rental_id, customer_id, gear_id, rental_date, status)
-- VALUES (101, 2, 501, '2025-07-09', 'Active');


-- Expected Result:
-- Second insert fails with: Double booking error: Gear is already rented for this date. */


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 8. Apply Loyalty Discount to Repeat Customers:

-- Purpose
-- To reward the repeated customers with a rental discount after a set number of successful rentals.

-- Description
-- The system should automatically apply a 10% discount to customers who have completed at least 5 rentals. This will promote customer retention and recognize loyal buyers.

-- Challenge
-- Tracking rental history and applying conditional discounts during rental checkout — all while ensuring customers don’t cheat the system — requires conditional logic and data lookup.

-- Assumptions
-- Rental table has:
-- rental_id
-- customer_id
-- amount_paid
-- status (should be 'Returned' to count as complete)
-- Gear table includes a base_rental_price field.
-- You’ll calculate amount_paid dynamically before insert.


-- Implementation Plan

Create a procedure CreateRentalWithLoyalty.
-- Before inserting rental, check how many completed rentals customer has.
-- If ≥ 5, apply 10% discount to gear price.
Insert rental with discounted price in amount_paid.


-- SQL Implementation:

DELIMITER $$
CREATE PROCEDURE CreateRentalWithLoyalty(
-- IN p_customer_id INT,
-- IN p_gear_id INT,
-- IN p_rental_date DATE
-- )
-- BEGIN
-- DECLARE v_completed_rentals INT;
-- DECLARE v_base_price DECIMAL(10,2);
-- DECLARE v_final_price DECIMAL(10,2);
-- -- Count completed rentals
-- SELECT COUNT(*) INTO v_completed_rentals
-- FROM Rental
-- WHERE customer_id = p_customer_id AND status = 'Returned';
-- -- Get base price of the gear
-- SELECT base_rental_price INTO v_base_price
-- FROM Gear
-- WHERE gear_id = p_gear_id;
-- -- Apply 10% discount if customer is loyal
-- IF v_completed_rentals >= 5 THEN
-- SET v_final_price = v_base_price * 0.9; -- 10% off
-- ELSE
-- SET v_final_price = v_base_price;
-- END IF;
-- -- Insert new rental
    INSERT INTO Rental (customer_id, gear_id, rental_date, status, amount_paid)
-- VALUES (p_customer_id, p_gear_id, p_rental_date, 'Active', v_final_price);
-- END$$
DELIMITER ;


-- Demonstration: Loyalty Discount Logic

-- Customer has 5 returned rentals
CALL CreateRentalWithLoyalty(4, 501, CURDATE());
-- Check final price
-- SELECT * FROM Rental WHERE customer_id = 4 ORDER BY rental_id DESC LIMIT 1;


-- Expected Result:
-- Price will be 10% less if customer had 5 or more returned rentals.*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 9. Automate Daily Backup of Rental Records:

-- Purpose
-- It ensures business continuity by automatically backing up the rental records every night at midnight.

-- Description
-- Losing rental transaction data due to server crashes, human error or technical glitches can hurt the business. Backing up the Rental table daily into a separate backup table can help recover in emergencies.

-- Challenge
-- Manual backups are prone to being forgotten and mistaken. Automating this process using scheduled SQL events improves data security and consistency.

-- Assumptions
-- A table RentalBackup exists with same structure as Rental.
-- Only active and returned rentals need to be backed up.
-- Backup happens daily at 11:59 PM.

-- Implementation Plan

Create a backup table called RentalBackup if not already present.
-- Enable the event scheduler.
Create an event that runs daily at 11:59 PM and copies data from Rental into RentalBackup.


-- SQL Implementation:

-- Step 1: Create the backup table (structure matches Rental)
CREATE TABLE IF NOT EXISTS RentalBackup AS
-- SELECT * FROM Rental WHERE 1 = 0;

-- Step 2: Enable event scheduler
-- SET GLOBAL event_scheduler = ON;

-- Step 3: Create daily backup event
DELIMITER $$
CREATE EVENT IF NOT EXISTS DailyRentalBackup
-- ON SCHEDULE EVERY 1 DAY
-- STARTS TIMESTAMP(CURDATE() + INTERVAL 1 DAY) + INTERVAL 23 HOUR + INTERVAL 59 MINUTE
-- DO
-- BEGIN
-- -- Optional: delete yesterday's backup if needed
-- DELETE FROM RentalBackup WHERE DATE(backup_timestamp) = CURDATE();
-- -- Insert new backup
    INSERT INTO RentalBackup
-- SELECT * FROM Rental;
-- END$$
DELIMITER ;
-- (Assumes RentalBackup has a backup_timestamp column with default CURRENT_TIMESTAMP)


-- Demonstration: Simulate Backup Now:

-- Manually run backup logic for testing
INSERT INTO RentalBackup SELECT * FROM Rental;
-- SELECT COUNT(*) FROM RentalBackup;


-- Expected Result:
-- Rental data copied successfully into backup table, ready to restore if needed.*/


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Cancel Rental with Automatic Refund Based on Timing:

-- Purpose
-- It allows customers to cancel rentals and receive a refund only if they cancel at least 24 hours before the rental date.

-- Description
-- To maintain fairness and business discipline, the system should allow cancellations — but only provide a refund if done in time. Otherwise, mark it as non-refundable.

-- Challenge
-- This requirement involves time-based logic, conditional refunds, and changing rental status. Ensuring this is automated avoids human mistakes.

-- Assumptions
-- Rental table includes:
-- rental_id
-- rental_date
-- status (Active, Cancelled, etc.)
-- amount_paid
-- refund_status (new column: 'Refunded', 'Not Refunded')
-- The cancellation must occur at least 24 hours before the rental_date.

-- Implementation Plan

-- Add a new column refund_status to the Rental table.
-- Write a procedure CancelRental that:
-- Checks time difference between now and rental date.
-- If ≥ 24 hours, set status = 'Cancelled' and refund_status = 'Refunded'.
-- Else, mark it as Not Refunded.


-- SQL Implementation:

-- Step 1: Add refund_status column (if not exists)
-- ALTER TABLE Rental ADD COLUMN refund_status VARCHAR(20) DEFAULT 'Pending';

-- Step 2: Create the procedure
DELIMITER $$
CREATE PROCEDURE CancelRental(IN p_rental_id INT)
-- BEGIN
-- DECLARE v_rental_date DATE;
-- DECLARE v_hours_diff INT;
-- -- Get rental date
-- SELECT rental_date INTO v_rental_date
-- FROM Rental
-- WHERE rental_id = p_rental_id;
-- -- Calculate hours until rental
-- SET v_hours_diff = TIMESTAMPDIFF(HOUR, NOW(), v_rental_date);
-- -- If more than 24 hrs left, allow refund
-- IF v_hours_diff >= 24 THEN
-- UPDATE Rental
-- SET status = 'Cancelled',
-- refund_status = 'Refunded'
-- WHERE rental_id = p_rental_id;
-- ELSE
-- UPDATE Rental
-- SET status = 'Cancelled',
-- refund_status = 'Not Refunded'
-- WHERE rental_id = p_rental_id;
-- END IF;
-- END$$
DELIMITER ;


-- Demonstration: Cancel Rental Example:

-- Try cancelling rental with >24hr left
CALL CancelRental(101);
-- SELECT * FROM Rental WHERE rental_id = 101;


-- Expected Result:
-- Rental is marked "Cancelled" and refund status is set to "Refunded" or "Not Refunded" based on timing.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Conclusion:

-- In this milestone, 10 basic business requirements were achieved and achieved by applying SQL triggers, functions, procedures, and schedule events. Every requirement has been specifically created to satisfy the real life requirements of the Drum Gear and Rental System - these requirements include inventory control, customer loyalty, secure access to roles, time based cancellation and automated back-ups. These installations indicate the scalability, efficiency, and maintenance that is to be anticipated in an industry grade database product. This milestone features technical capability and functionality and this is in accord with the objectives of the system which were set in earlier System milestones