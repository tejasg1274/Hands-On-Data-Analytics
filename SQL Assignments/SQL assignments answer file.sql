USE classicmodels;
SHOW TABLES;



# Q 1 (a)  ------------------------------------------------------------------------------------------------
SELECT
    employeeNumber,
    firstName,
    lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
AND reportsTo = 1102;



# Q 1 (b)  ------------------------------------------------------------------------------------------------
SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';



# Q 2 ------------------------------------------------------------------------------------------------
SELECT
    customerNumber,
    customerName,
    CASE
        WHEN country IN ('USA', 'Canada') THEN 'North America'
        WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment
FROM customers;



# Q 3 (a) ------------------------------------------------------------------------------------------------
SELECT
    productCode,
    SUM(quantityOrdered) AS TotalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY TotalQuantity DESC
LIMIT 10;



# Q 3 (b) ------------------------------------------------------------------------------------------------
SELECT
    MONTHNAME(paymentDate) AS MonthName,
    COUNT(*) AS TotalPayments
FROM payments
GROUP BY MONTH(paymentDate), MONTHNAME(paymentDate)
HAVING COUNT(*) > 20
ORDER BY TotalPayments DESC;



# Q 4 (a) ------------------------------------------------------------------------------------------------
CREATE DATABASE Customers_Orders;

USE Customers_Orders;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);



# Q 4 (b) ------------------------------------------------------------------------------------------------
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (total_amount > 0)
);



# Q 5  ------------------------------------------------------------------------------------------------
USE classicmodels;

SELECT
    c.country,
    COUNT(o.orderNumber) AS OrderCount
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY OrderCount DESC
LIMIT 5;



# Q 6  ------------------------------------------------------------------------------------------------
CREATE TABLE project (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(50) NOT NULL,
    Gender VARCHAR(10),
    ManagerID INT,
    CHECK (Gender IN ('Male', 'Female')),
    FOREIGN KEY (ManagerID) REFERENCES project(EmployeeID)
);

SELECT * FROM project;

INSERT INTO project (EmployeeID, FullName, Gender, ManagerID)
VALUES
(1, 'Pranaya', 'Male', NULL),
(2, 'Priyanka', 'Female', NULL),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', NULL),
(5, 'Sambit', 'Male', NULL),
(6, 'Rajesh', 'Male', NULL),
(7, 'Hina', 'Female', NULL);

UPDATE project
SET ManagerID = CASE EmployeeID
    WHEN 1 THEN 3
    WHEN 2 THEN 1
    WHEN 4 THEN 1
    WHEN 5 THEN 1
    WHEN 6 THEN 3
    WHEN 7 THEN 3
END
WHERE EmployeeID IN (1, 2, 4, 5, 6, 7);

SELECT
    e.FullName AS EmployeeName,
    m.FullName AS ManagerName
FROM project e
LEFT JOIN project m
    ON e.ManagerID = m.EmployeeID;



# Q 7  ------------------------------------------------------------------------------------------------
# Create Table
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

# i) Add Primary Key and Auto Increment
ALTER TABLE facility
MODIFY Facility_ID INT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (Facility_ID);

# ii) Add City column after Name
ALTER TABLE facility
ADD COLUMN City VARCHAR(100) NOT NULL AFTER Name;



# Q 8  ------------------------------------------------------------------------------------------------

CREATE VIEW product_category_sales AS
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM productlines pl
JOIN products p
    ON pl.productLine = p.productLine
JOIN orderdetails od
    ON p.productCode = od.productCode
JOIN orders o
    ON od.orderNumber = o.orderNumber
GROUP BY pl.productLine;

SELECT * FROM product_category_sales;

    

# Q 9  ------------------------------------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE Get_country_payments(
    IN p_year INT,
    IN p_country VARCHAR(50)
)
BEGIN
    SELECT
        YEAR(p.paymentDate) AS Year,
        c.country AS Country,
        CONCAT(FORMAT(ROUND(SUM(p.amount) / 1000), 0), 'K') AS TotalAmount
    FROM customers c
    JOIN payments p
        ON c.customerNumber = p.customerNumber
    WHERE YEAR(p.paymentDate) = p_year
      AND c.country = p_country
    GROUP BY YEAR(p.paymentDate), c.country;
END //
DELIMITER ;

CALL Get_country_payments(2003, 'FRANCE');



# Q 10 (a) ------------------------------------------------------------------------------------------------

SELECT
    c.customerName,
    COUNT(o.orderNumber) AS OrderCount,
    COUNT(o.orderNumber) AS OrderFrequency,
    RANK() OVER (
        ORDER BY COUNT(o.orderNumber) DESC
    ) AS CustomerRank
FROM customers c
JOIN orders o
    ON c.customerNumber = o.customerNumber
GROUP BY c.customerNumber, c.customerName;



# Q 10 (b) ------------------------------------------------------------------------------------------------

WITH MonthlyOrders AS (
    SELECT
        YEAR(orderDate) AS Year,
        MONTH(orderDate) AS MonthNumber,
        MONTHNAME(orderDate) AS MonthName,
        COUNT(orderNumber) AS TotalOrders
    FROM orders
    GROUP BY
        YEAR(orderDate),
        MONTH(orderDate),
        MONTHNAME(orderDate)
),
PreviousYear AS (
    SELECT
        Year,
        MonthNumber,
        MonthName,
        TotalOrders,
        LAG(TotalOrders) OVER (
            PARTITION BY MonthNumber
            ORDER BY Year
        ) AS PreviousYearOrders
    FROM MonthlyOrders
)
SELECT
    Year,
    MonthName,
    TotalOrders,
    CONCAT(
        ROUND(
            ((TotalOrders - PreviousYearOrders) /
            NULLIF(PreviousYearOrders, 0)) * 100,
            0
        ),
        '%'
    ) AS YoY_Percentage
FROM PreviousYear
ORDER BY Year, MonthNumber;



# Q 11 ------------------------------------------------------------------------------------------------

SELECT
    productLine,
    COUNT(*) AS Total
FROM products
WHERE buyPrice > (
    SELECT AVG(buyPrice)
    FROM products
)
GROUP BY productLine;



# Q 12 ------------------------------------------------------------------------------------------------

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(255)
);

DELIMITER //
CREATE PROCEDURE Insert_Emp_EH(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred' AS Message;
    END;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //

DELIMITER ;
CALL Insert_Emp_EH(1, 'Rahul', 'rahul@gmail.com');



# Q 13 ------------------------------------------------------------------------------------------------

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

DELIMITER //
CREATE TRIGGER before_insert_Emp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //
DELIMITER ;

 INSERT INTO Emp_BIT VALUES
('John', 'Engineer', '2020-10-05', -8);

SELECT * FROM Emp_BIT;


# -----------------------------------------------------------------------------------------------------
 