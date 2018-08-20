-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.

-- 2.1 SELECT

-- Task – Select all records from the Employee table.
SELECT * FROM employee;

-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee
WHERE lastname='King';

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
WHERE firstname='Andrew' and reportsto IS NULL;

-- 2.2 ORDER BY

-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album
ORDER BY(title) desc;

-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer
ORDER BY(city);

-- 2.3 INSERT INTO

-- Task – Insert two new records into Genre table
INSERT INTO genre VALUES(26, 'Funk');
INSERT INTO genre VALUES(27, 'Indie');

-- Task – Insert two new records into Employee table
INSERT INTO employee VALUES(9, 'Mathiowetz', 'Kevin', 'Project Manager', 1, '1993-03-11 00:00:00', '2018-08-15 00:00:00', '1979 Milky Way', 'Madison', 'WI', 'United States', '53593', '+1 (555)-123-4567', '+1 (555)-123-4568', 'kevin@chinookcorp.com');
INSERT INTO employee VALUES(10, 'Meyers', 'Bree', 'Sales District Manager', 2, '1993-04-02 00:00:00', '2018-08-15 00:00:00', '6500 River Pl Blvd', 'Austin', 'TX', 'United States', '78730', '+1 (555)-987-6543', '+1 (555)-987-6542', 'bree@chinookcorp.com');

-- Task – Insert two new records into Customer table
INSERT INTO customer VALUES(60, 'Laura', 'Hauglid', 'University of Denver', '2199 S University Blvd', 'Denver', 'CO', 'United States', '80208', '+1 (555)-246-1357', NULL, 'lhauglid@gmail.com', 5);
INSERT INTO customer VALUES(61, 'Tim', 'Zhang', 'University of Minnesota', '300 Washington Ave SE', 'Minneapolis', 'MN', 'United States', '55455', '+1 (555)-011-2358', NULL, 'tim.zhang@gmail.com', 3);

-- 2.4 UPDATE

-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer SET firstname='Robert', lastname='Walter'
WHERE firstname='Aaron' AND lastname='Mitchell';

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist SET name='CCR'
WHERE name='Creedence Clearwater Revival';

-- 2.5 LIKE

-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice
WHERE billingaddress LIKE 'T%';

-- 2.6 BETWEEN

-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice
WHERE total BETWEEN 15 AND 50;

-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee
WHERE hiredate BETWEEN '2003-06-01 00:00:00' AND '2004-03-01 00:00:00';

-- 2.7 DELETE

-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
--First delete statement
DELETE FROM invoiceline
WHERE invoiceid IN (
SELECT invoiceid FROM invoice
WHERE customerid=(
SELECT customerid FROM customer
WHERE firstname='Robert' AND lastname='Walter'));

--Second delete statement
DELETE FROM invoice
WHERE customerid=(
SELECT customerid FROM customer
WHERE firstname='Robert' AND lastname='Walter');

--Third delete statement
DELETE FROM customer
WHERE firstname='Robert' AND lastname='Walter';

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database

-- 3.1 System Defined Functions

-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION get_current_time()
RETURNS TIMESTAMP AS $$
	BEGIN
		RETURN CURRENT_TIMESTAMP;
	END;
$$ LANGUAGE plpgsql;

-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION get_length_mediatype_name(mediatype_name VARCHAR)
RETURNS INTEGER AS $$
	BEGIN
		RETURN LENGTH(name) FROM mediatype WHERE name=mediatype_name;
	END;
$$ LANGUAGE plpgsql;

-- 3.2 System Defined Aggregate Functions

-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION avg_all_invoices()
RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(total) FROM invoice;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION get_cost_most_expensive_track()
RETURNS NUMERIC AS $$
	BEGIN
		RETURN MAX(unitprice) FROM track;
	END;
$$ LANGUAGE plpgsql;

-- 3.3 User Defined Scalar Functions

-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION get_avgprice_invoiceline_items()
RETURNS NUMERIC AS $$
	BEGIN
		RETURN AVG(unitprice) FROM invoiceline;
	END;
$$ LANGUAGE plpgsql;

-- 3.4 User Defined Table Valued Functions

-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION birthdates()
RETURNS TABLE(birthdates TIMESTAMP) AS $$
BEGIN
	RETURN QUERY
		SELECT birthdate FROM employee
			WHERE birthdate > '1969-01-01 00:00:00';
	END;
$$ LANGUAGE plpgsql;

-- 4.0 Stored Procedures

--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.

-- 4.1 Basic Stored Procedure

-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION get_first_last_names()
RETURNS TABLE(f_name VARCHAR, l_name VARCHAR) AS $$
	BEGIN
		RETURN QUERY
			SELECT firstname, lastname FROM employee;
	END;
$$ LANGUAGE plpgsql;

-- 4.2 Stored Procedure Input Parameters

-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_personal_info(employee_id INTEGER, new_address VARCHAR, new_city VARCHAR, 
												new_state VARCHAR, new_country VARCHAR, new_postalcode VARCHAR)
RETURNS void AS $$
	BEGIN
		UPDATE employee
		SET address=new_address,
			city=new_city,
			state=new_state,
			country=new_country,
			postalcode=new_postalcode
		WHERE employeeid=employee_id;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION get_manager_info(employee_id INTEGER)
RETURNS TABLE(ei INTEGER, lsn VARCHAR, fn VARCHAR, ttl VARCHAR, rt INTEGER, bd TIMESTAMP, hd TIMESTAMP,
			 adr VARCHAR, ci VARCHAR, st VARCHAR, co VARCHAR, pc VARCHAR, ph VARCHAR, fax VARCHAR, em VARCHAR) AS $$
	BEGIN
		RETURN QUERY
			SELECT * FROM employee
			WHERE employeeid=(
			SELECT reportsto FROM employee
			WHERE employeeid=employee_id);
	END;
$$ LANGUAGE plpgsql;

-- 4.3 Stored Procedure Output Parameters

-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION get_name_and_company(customer_id INTEGER)
RETURNS TABLE(first_name VARCHAR, last_name VARCHAR, comp VARCHAR) AS $$
	BEGIN
	RETURN QUERY
		SELECT firstname, lastname, company FROM customer
		WHERE customerid=customer_id;
	END;
$$ LANGUAGE plpgsql;

-- 5.0 Transactions

-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.

-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE OR REPLACE FUNCTION delete_invoices(invoice_id INTEGER)
RETURNS void AS $$
	BEGIN
		DELETE FROM invoiceline
		WHERE invoiceid=(
		SELECT invoiceid FROM invoice
		WHERE invoiceid=invoice_id);
		
		DELETE FROM invoice
		WHERE invoiceid=invoice_id;
	END;
$$ LANGUAGE plpgsql;

-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION insert_customer(cid INTEGER, fn VARCHAR, lan VARCHAR, co VARCHAR, addr VARCHAR,
													  ci VARCHAR, st VARCHAR, coun VARCHAR, ps VARCHAR, ph VARCHAR, fax VARCHAR,
													  em VARCHAR, sid INTEGER)
RETURNS void AS $$
	DECLARE 
	high INTEGER=MAX(employeeid) FROM employee;
	low INTEGER=MIN(employeeid) FROM employee;
	BEGIN
	IF sid BETWEEN low AND high THEN
		INSERT INTO customer VALUES(cid, fn, lan, co, addr, ci, st, coun, ps, ph, fax, em, sid);
	END IF;
	END;
$$ LANGUAGE plpgsql;

-- 6.0 Triggers

-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.

-- 6.1 AFTER/FOR

-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE TABLE send_welcome_card_list(
	firstname VARCHAR,
	lastname VARCHAR,
	address VARCHAR,
	city VARCHAR,
	state VARCHAR,
	country VARCHAR,
	postalcode VARCHAR);

CREATE OR REPLACE FUNCTION welcomelist()
RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO welcome_card_list(firstname, lastname, address, city, state, country, postalcode)
		VALUES(NEW.firstname, NEW.lastname, NEW.address, NEW.city, NEW.state, NEW.country, NEW.postalcode);
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER intolist
AFTER INSERT ON employee
FOR EACH ROW
EXECUTE PROCEDURE welcomelist();

-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table.
CREATE TABLE track_title_changes_within_company(
	old_title VARCHAR,
	new_title VARCHAR);
	
CREATE OR REPLACE FUNCTION track_title_changes()
RETURNS TRIGGER AS $$
	BEGIN
	INSERT INTO track_title_changes_within_company(old_title, new_title)
	VALUES(OLD.title, NEW.title);
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER title_changes_trig
AFTER UPDATE on employee
FOR EACH ROW
EXECUTE PROCEDURE track_title_changes();

-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TABLE num_employees_that_have_left(
	num_employees_gone INTEGER);
	
INSERT INTO num_employees_that_have_left(num_employees_gone)
VALUES(0);

CREATE OR REPLACE FUNCTION get_counter()
RETURNS INTEGER AS $$
	BEGIN
		RETURN num_employees_gone FROM num_employees_that_have_left;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION track_num_employees_that_have_left()
RETURNS TRIGGER AS $$
	DECLARE
	counter INTEGER=get_counter();
	BEGIN
		UPDATE num_employees_that_have_left SET num_employees_gone=counter+1;
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER employeesgone
AFTER DELETE ON employee
EXECUTE PROCEDURE track_num_employees_that_have_left();

-- 6.2 INSTEAD OF

-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE FUNCTION prevent_delete_above_50()
RETURNS TRIGGER AS $$
	BEGIN
		IF OLD.total > 50 THEN
			INSERT INTO invoice(invoiceid, customerid, invoicedate, billingaddress, billingcity, billingstate,
							   billingcountry, billingpostalcode, total)
			VALUES(OLD.invoiceid, OLD.customerid, OLD.invoicedate, OLD.billingaddress, OLD.billingcity, OLD.billingstate,
				  OLD.billingcountry, OLD.billingpostalcode, OLD.total);
			
		END IF;
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent
AFTER DELETE ON invoice
FOR EACH ROW
EXECUTE PROCEDURE prevent_delete_above_50();

-- 7.0 JOINS

-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.

-- 7.1 INNER

-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT firstname, lastname, invoiceid FROM customer
INNER JOIN invoice ON(customer.customerid=invoice.customerid);

-- 7.2 OUTER

-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, firstname, lastname, invoiceid, total FROM customer
FULL JOIN invoice ON (customer.customerid=invoice.customerid);

-- 7.3 RIGHT

-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title FROM album
RIGHT JOIN artist ON(album.artistid=artist.artistid);

-- 7.4 CROSS

-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM album
CROSS JOIN artist
ORDER BY(artist.name);

-- 7.5 SELF

-- Task – Perform a self-join on the employee table, joining on the reportsto column.
--Aligns people that share the same manager
SELECT * FROM employee
SELF JOIN employee USING(reportsto);
--Aligns employees with their managers
SELECT e1.firstname, e1.lastname, e2.firstname, e2.lastname FROM employee AS e1
LEFT JOIN employee AS e2 ON(e1.reportsto=e2.employeeid);
