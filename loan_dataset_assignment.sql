-- LOAN DATA ASSIGNMENT

-- B1 Objective: Write basic SQL queries to select data from the loans table, such as selecting all columns for all records, and specific columns like loan amount and type
SELECT * FROM loan.loan_data;
SELECT LoanAmount, LoanType FROM loan.loan_data;

-- B2 Objective: Apply SQL commands to sort loans by issue date and filter loans by criteria such as loan type (e.g., Personal, Home).
SELECT * FROM loan.loan_data ORDER BY IssueDate DESC;
SELECT * FROM loan.loan_data WHERE LoanType = 'Personal';
SELECT * FROM loan.loan_data WHERE LoanType = 'Home';

-- B3 Objective: Use SQL to calculate aggregates like the total number of loans, average loan amount, and the maximum and minimum loan amounts.
SELECT COUNT(*) AS TotalLoans FROM loan.loan_data;
SELECT AVG(LoanAmount) AS AverageLoanAmount FROM loan.loan_data;
SELECT MAX(LoanAmount) AS MaxLoanAmount FROM loan.loan_data;
SELECT MIN(LoanAmount) AS MinLoanAmount FROM loan.loan_data;
SELECT MAX(LoanAmount) AS MaxLoanAmount, MIN(LoanAmount) AS MinLoanAmount  FROM loan.loan_data;

-- B4 Objective: Perform basic joins, for example, joining the loans table with a customer table (assuming such a table exists or is created for this task) on 
-- the customer ID to retrieve combined information.
SELECT L.LoanID, L.LoanAmount, C.CustomersName
FROM loan.loan_data L 
JOIN Customers C ON L.CustomerID = C.CustomerID;

-- B5 Objective: Create SQL views to simplify access to frequently needed queries, such as a view for all active loans.
CREATE VIEW ActiveLoans AS 
SELECT * FROM  loan.loan_data WHERE LoanStatus = 'Approved';

SELECT * FROM ActiveLoans;

-- I1 Objective: Use more complex joins and subqueries to answer specific questions, like finding the average loan amount for each type of loan or 
-- identifying customers with loans in more than one category.

SELECT LoanType, AVG(LoanAmount) AS AverageLoanAmount
FROM loan.loan_data
GROUP BY LoanType;

SELECT CustomerID
FROM loan.loan_data
GROUP BY CustomerID
HAVING COUNT(DISTINCT LoanType) > 1;

-- I2 Objective: Group data by various attributes such as loan type or region, and use the HAVING clause to filter groups based on aggregate conditions, 
-- like regions with average loan amounts above a certain threshold.

SELECT Region, AVG(LoanAmount) AS AverageLoanAmount
FROM loan.loan_data
GROUP BY Region
HAVING AVG(LoanAmount) > 100000;

-- I3 Objective: Create indexed views to improve query performance on complex aggregations, particularly for large datasets.

CREATE INDEX Index_LoanStatus ON loan.loan_data (LoanStatus(20)); -- MYSQL DOES NOT SUPPORT INDEXED VIEW, THAT'S WHY I HAVE CREATED MATERIALISED VIEW


-- I4 Use temporary tables to stage data manipulation tasks, such as calculating payment schedules or aggregating customer loan histories.

CREATE TEMPORARY TABLE PaymentPlan (
    LoanID INT,
    LoanAmount DECIMAL(15, 2),
    MonthlyPayment DECIMAL(15, 2)
);

INSERT INTO PaymentPlan (LoanID, LoanAmount, MonthlyPayment)
SELECT LoanID, LoanAmount, (LoanAmount / `Term (months)`) AS MonthlyPayment
FROM loan.loan_data;

SELECT * FROM PaymentPlan;

-- I5 Objective: Implement CASE statements in SQL to perform conditional logic, such as categorizing loan risk based on interest rates or repayment terms.

SELECT LoanID, LoanAmount,
    CASE
        WHEN 'InterestRate(%)' > 8 THEN 'High Risk'
        WHEN 'InterestRate(%)' BETWEEN 5 AND 8 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskCategory
FROM loan.loan_data;

-- A1 Objective: Use window functions for advanced analytics, like running totals, moving averages, or ranking loans within each category by size or interest rate.
-- Calculating running total of loan amounts by issue date:
SELECT LoanID, IssueDate, LoanAmount,
       SUM(LoanAmount) OVER (ORDER BY IssueDate) AS RunningTotal
FROM loan.loan_data;

-- Calculating moving average of loan amounts over a 3-month window:
SELECT LoanID, IssueDate, LoanAmount,
       AVG(LoanAmount) OVER (ORDER BY IssueDate ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS MovingAverage
FROM loan.loan_data;

-- Ranking loans within each loan type by loan amount:
-- Using window functions like running totals or rankings.
SELECT LoanID, LoanType, LoanAmount,
       RANK() OVER (PARTITION BY LoanType ORDER BY LoanAmount DESC) AS LoanRank
FROM loan.loan_data;

-- A2 Objective: Analyze and optimize SQL queries for performance, using EXPLAIN plans and adjusting indexes.
-- Using EXPLAIN to analyze query performance:
EXPLAIN
SELECT * FROM loan.loan_data WHERE LoanStatus = 'Approved' AND LoanAmount > 10000;

-- Creating an index on a frequently queried column:
CREATE INDEX loan_status ON loan.loan_data (LoanStatus(100));

-- A3 Objective: Write stored procedures to automate common data processing tasks, such as monthly loan status updates or alerts for delinquent loans.
-- Stored procedure to automate monthly loan status updates.
DELIMITER //
CREATE PROCEDURE UpdateLoanStatus()
BEGIN
    UPDATE loan.loan_data
    SET ProcedureLoanStatus = 'Delinquent'
    WHERE PaymentStatus = 'Unpaid' AND DATEDIFF(NOW(), IssueDate) > 30;
END //
DELIMITER ;

-- A4 Objective: Set up SQL scripts to import or export data from/to other databases or formats, integrating SQL database operations with other business systems.
-- IMPORTING

LOAD DATA INFILE '"C:\Users\Ashutosh Tiwari\Downloads\ABADS\flights.csv"'
INTO TABLE loan.loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- EXPORTING
SELECT * INTO OUTFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\loan_data.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM loan.loan_data;

-- A5  Implement security measures in SQL, including managing user permissions and roles, and securing sensitive data through encryption or secure access paths.
CREATE USER 'GUEST'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT, INSERT ON loan.loan_data TO 'GUEST'@'localhost';

CREATE ROLE 'data_analyst';
GRANT SELECT, INSERT ON loan.loan_data TO 'data_analyst';
GRANT 'data_analyst' TO 'GUEST'@'localhost';
REVOKE SELECT, INSERT ON loan.loan_data FROM 'GUEST'@'localhost';
DROP USER 'GUEST'@'localhost';
SELECT User, Host FROM mysql.user;