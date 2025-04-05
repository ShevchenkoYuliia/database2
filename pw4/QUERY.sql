USE pcmouse;
-- завдання 2
/*SELECT 'Supplier' AS TableName, COUNT(*) AS RecordCount FROM Supplier
UNION ALL
SELECT 'ComputerMouse', COUNT(*) FROM ComputerMouse
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'OrderTable', COUNT(*) FROM OrderTable
UNION ALL
SELECT 'OrderDetails', COUNT(*) FROM OrderDetails;

--завдання 3
SELECT AVG(Price) AS AveragePrice FROM ComputerMouse;
SELECT MAX(ButtonCount) AS MaxButtonCount FROM ComputerMouse;
SELECT CustomerId, SUM(TotalAmount) AS TotalSpent FROM OrderTable GROUP BY CustomerId;

--завдання 4
SELECT 
    ProductId, 
    ModelName, 
    Brand, 
    Price, 
    RANK() OVER (PARTITION BY Brand ORDER BY Price DESC) AS PriceRank
FROM ComputerMouse;

SELECT 
    CustomerId, 
    OrderId, 
    OrderDate, 
    SUM(TotalAmount) OVER (PARTITION BY CustomerId ORDER BY OrderDate) AS RunningTotal
FROM OrderTable;

SELECT 
    ProductId, 
    ModelName, 
    SupplierId, 
    Price, 
    AVG(Price) OVER (PARTITION BY SupplierId) AS AvgPricePerSupplier
FROM ComputerMouse;
*/
--завдання 5
SELECT 
    CustomerId, 
    FirstName, 
    LEN(FirstName) AS NameLength
FROM Customer;

SELECT 
    CustomerId, 
    Email, 
    UPPER(Email) AS EmailUpperCase
FROM Customer;

SELECT CustomerId, 
       FirstName, 
       LastName, 
       CONCAT(SUBSTRING(FirstName, 1, 1), '.', SUBSTRING(LastName, 1, 1), '.') AS Initials
FROM Customer;
/*
--завдання 6
SELECT 
    OrderId, 
    OrderDate, 
    DATEDIFF(DAY, OrderDate, GETDATE()) AS OrderAgeDays
FROM OrderTable;

SELECT 
    OrderId, 
    OrderDate, 
    DATENAME(MONTH, OrderDate) AS OrderMonth
FROM OrderTable;

SELECT 
    OrderId, 
    OrderDate, 
    DATENAME(WEEKDAY, OrderDate) AS OrderDayOfWeek
FROM OrderTable;*/
