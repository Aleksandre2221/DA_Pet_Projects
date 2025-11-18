

			-- All The Questions -- 
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
-- Task 2. Update an Existing Member's Address
-- Task 3. Delete the record with issued_id = 'IS104' form the issue_status table.
-- Task 4. Select all books issued by the employee with emp_id = 'E101'
-- Task 5. List Employees who have issued more than two book
-- Task 6. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_count
-- Task 7. Retrive all books in a specific category
-- Task 8. Find Total Rental Income by Category
-- Task 9. List Memebers Who Registered in the Last 100 days
-- Task 10. List employees with their branch Manager's Name and their branch details
-- Task 11. Create a table of Books with Rental Price above 7 USD:
-- Task 12. Retrive the List of Books Not Yet Returned
-- Task 13. Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Task 14. Create a query that generates a preformance report for each branch, showing the number of books issued, the number of books returned and the total revenue from book rentals
-- Task 15. Use CTAS statment to create a new table active_members contining members who have issued at least 1 book in the las 6 month
-- Task 16. Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch
-- Task 17: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.




-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To KIll a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co. ');



-- Task 2. Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';



-- Task 3. Delete the record with issued_id = 'IS104' form the issue_status table.
DELETE FROM issue_status
WHERE issued_id = 'IS106';



-- Task 4. Select all books issued by the employee with emp_id = 'E101'
SELECT issued_book_name
FROM issue_status
WHERE issued_emp_id = 'E101';



-- Task 5. List Employees who have issued more than two book
SELECT 
	issued_emp_id 
	--COUNT(issued_book_name) AS books_issued
FROM issue_status
GROUP BY issued_emp_id
HAVING COUNT(issued_book_name) > 2;



-- Task 6. Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_count
CREATE TABLE book_count AS
SELECT books.book_title, COUNT(issue_status.issued_book_name) AS num_of_issues
FROM books
JOIN issue_status
	ON books.isbn = issue_status.issued_book_isbn
GROUP BY books.book_title;
--SELECT * FROM book_count ORDER BY 2 DESC;



-- Task 7. Retrive all books in a specific category
SELECT book_title 
FROM books
WHERE category = 'Classic';



-- Task 8. Find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
LEFT JOIN issue_status as ist
	ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY 2 DESC;



-- Task 9. List Memebers Who Registered in the Last 100 days
SELECT member_name, reg_date 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '12 month';


INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES
('C120', 'Alex Kawolski', '276 Man St', '2024-07-10'),
('C121', 'Nick Johnson', '321 Okl St', '2024-06-03');



-- Task 10. List employees with their branch Manager's Name and their branch details
SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager
FROM employees as e1
JOIN branch as b
	ON b.branch_id = e1.branch_id
JOIN employees as e2
	ON b.manager_id = e2.emp_id;



-- Task 11. Create a table of Books with Rental Price above 7 USD:
CREATE TABLE exp_books AS
SELECT * 
FROM books 
WHERE rental_price > 7;
--SELECT * FROM exp_books



-- Task 12. Retrive the List of Books Not Yet Returned
SELECT ist1.issued_book_name
FROM issue_status ist1
LEFT JOIN return_status rs
	ON ist1.issued_id = rs.issued_id
WHERE rs.issued_id IS NULL



-- Task 13. Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the members name, book title, issue date and days overdue.

-- issued_status == members == books == return_status
-- filter books which is return 
-- overdue > 30 days
	
SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date
FROM issue_status AS ist
LEFT JOIN members AS m
	ON ist.issued_member_id = m.member_id
JOIN books as b
	ON ist.issued_book_isbn = b.isbn
LEFT JOIN return_status AS rs
	ON ist.issued_id = rs.issued_id
WHERE rs.issued_id IS NULL 



-- Task 14. Create a query that generates a preformance report for each branch, showing the number of books issued, the number of books returned and the total revenue from book rentals

CREATE TABLE branch_reports 
AS
SELECT 
	e.branch_id,
	COUNT(ist.*) AS books_issued,
	COUNT(rs.*) AS books_returned,
	SUM(b.rental_price)
FROM issue_status as ist
JOIN employees as e
	ON e.emp_id = ist.issued_emp_id
FULL JOIN return_status as rs
	ON ist.issued_id = rs.issued_id
JOIN books as b
	ON b.isbn = ist.issued_book_isbn
GROUP BY e.branch_id
ORDER BY 3 DESC;
--SELECT * FROM branch_reports



-- Task 15. Use CTAS statment to create a new table active_members contining members who have issued at least 1 book in the las 6 month

DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members 
AS
SELECT DISTINCT m.member_name as active_members
FROM issue_status as ist
JOIN members as m
	ON m.member_id = ist.issued_member_id
WHERE issued_date > CURRENT_DATE - INTERVAL '1 year 3 month'
SELECT * FROM active_members


-- OR SUBQUERY

-- DROP TABLE IF EXISTS active_members;
-- CREATE TABLE active_members 
-- AS
-- SELECT DISTINCT member_name
-- FROM members
-- WHERE member_id IN (SELECT 
-- 						DISTINCT issued_member_id 
-- 					FROM issue_status 
-- 					WHERE issued_date > CURRENT_DATE - INTERVAL '14 month'
-- 					)





-- Task 16. Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch

SELECT 
	b.branch_id,
	e.emp_name,
	b.manager_id,
	b.branch_address,
	b.contact_no, 
	COUNT(ist.issued_emp_id) as books_num
FROM employees as e
JOIN issue_status as ist
	ON e.emp_id = ist.issued_emp_id
JOIN branch as b
	ON e.branch_id = b.branch_id
GROUP BY 
	b.branch_id, 
	e.emp_name, 
	b.manager_id, 
	b.branch_address,
	b.contact_no
ORDER BY books_num DESC
LIMIT 3;
