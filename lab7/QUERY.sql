USE pcmouse;
/*-- завдання 4
SELECT o.OrderId, c.FirstName, c.LastName, o.OrderDate, o.TotalAmount
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId;

SELECT m.ProductId, m.ModelName, m.Brand, m.Type, m.Price, m.StockQuantity, s.Name AS SupplierName, s.ContactNumber
FROM ComputerMouse m
JOIN Supplier s ON m.SupplierId = s.SupplierId;

SELECT od.OrderDetailsId, c.FirstName, c.LastName, cm.ModelName, cm.Brand, od.ProductQuantity, od.ItemAmount
FROM OrderDetails od
JOIN OrderTable o ON od.OrderId = o.OrderId
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId;

SELECT DISTINCT s.SupplierId, s.Name, s.ContactNumber
FROM Supplier s
JOIN ComputerMouse cm ON s.SupplierId = cm.SupplierId
WHERE cm.Price > 3000;

-- завдання 5
-- Перевірка каскадних видалень
DELETE FROM Supplier WHERE SupplierId = 2;
DELETE FROM Customer WHERE CustomerId = 1002;

-- Перевірка каскадних оновлень
UPDATE Supplier SET SupplierId = 2 WHERE SupplierId = 1;
UPDATE Customer SET CustomerId = 1002 WHERE CustomerId = 1001;

--завдання 6
SELECT ProductId, ModelName, Brand, StockQuantity
FROM ComputerMouse
WHERE StockQuantity < 20
ORDER BY StockQuantity ASC;

SELECT DISTINCT s.SupplierId, s.Name, s.ContactNumber
FROM Supplier s
JOIN ComputerMouse m ON s.SupplierId = m.SupplierId
WHERE m.StockQuantity > 0
ORDER BY s.Name;

SELECT * FROM OrderTable
WHERE TotalAmount > 4500
ORDER BY OrderDate DESC;

SELECT * FROM ComputerMouse
ORDER BY Brand ASC;

--завдання 7

SELECT * FROM ComputerMouse WHERE Price >= 3500 OR ButtonCount < 5;
SELECT * FROM ComputerMouse WHERE Size = 'Large';
SELECT * FROM ComputerMouse WHERE Price < 2000 AND Color = 'Gray';
SELECT * FROM Customer WHERE NOT LastName LIKE '%o%';

--завдання 8
SELECT Customer.CustomerId,Customer.FirstName,Customer.LastName, OrderTable.OrderId, OrderTable.OrderDate,
    OrderDetails.ProductQuantity, ComputerMouse.ModelName, ComputerMouse.Brand, ComputerMouse.Color
FROM Customer
LEFT JOIN OrderTable ON Customer.CustomerId = OrderTable.CustomerId
LEFT JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId
RIGHT JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

SELECT ComputerMouse.ProductId, ComputerMouse.ModelName, OrderDetails.OrderId, OrderDetails.ProductQuantity
FROM OrderDetails  
RIGHT JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

SELECT OrderTable.OrderId, OrderTable.OrderDate, ComputerMouse.ProductId, ComputerMouse.ModelName, OrderDetails.ProductQuantity
FROM OrderTable  
FULL JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId  
FULL JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

SELECT Supplier.SupplierId, Supplier.Name AS SupplierName, ComputerMouse.ProductId, ComputerMouse.ModelName
FROM Supplier  
LEFT JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId;

SELECT Customer.CustomerId, Customer.FirstName, Customer.LastName, OrderTable.OrderId, OrderTable.OrderDate
FROM OrderTable  
RIGHT JOIN Customer ON OrderTable.CustomerId = Customer.CustomerId;

--завдання 9
SELECT Supplier.Name AS SupplierName, ComputerMouse.ModelName, SUM(ComputerMouse.StockQuantity) AS TotalStock
FROM ComputerMouse
JOIN Supplier ON ComputerMouse.SupplierId = Supplier.SupplierId
GROUP BY Supplier.Name, ComputerMouse.ModelName
HAVING SUM(ComputerMouse.StockQuantity) > 40
ORDER BY TotalStock DESC;

SELECT c.CustomerId, c.FirstName, c.LastName, COUNT(o.OrderId) AS OrderCount, SUM(o.TotalAmount) AS TotalSpent
FROM Customer c
JOIN OrderTable o ON c.CustomerId = o.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING SUM(o.TotalAmount) > 9000;

SELECT cm.Brand, SUM(od.ProductQuantity) AS TotalSold
FROM ComputerMouse cm
JOIN OrderDetails od ON cm.ProductId = od.ProductId
GROUP BY cm.Brand
HAVING SUM(od.ProductQuantity) > 10;

SELECT s.SupplierId, s.Name, COUNT(cm.ProductId) AS ModelsSupplied
FROM Supplier s
JOIN ComputerMouse cm ON s.SupplierId = cm.SupplierId
GROUP BY s.SupplierId, s.Name
HAVING COUNT(cm.ProductId) > 3;

SELECT cm.Brand, AVG(cm.Price) AS AvgPrice
FROM ComputerMouse cm
GROUP BY cm.Brand
HAVING AVG(cm.Price) > 2000;
*/
-- завдання 2
SELECT 'Supplier' AS TableName, COUNT(*) AS RecordCount FROM Supplier
UNION ALL
SELECT 'ComputerMouse', COUNT(*) FROM ComputerMouse
UNION ALL
SELECT 'Customer', COUNT(*) FROM Customer
UNION ALL
SELECT 'OrderTable', COUNT(*) FROM OrderTable
UNION ALL
SELECT 'OrderDetails', COUNT(*) FROM OrderDetails;
/*
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
FROM OrderTable;
--Лабораторна 5
--Завдання 3
--Кластеризований
CREATE CLUSTERED INDEX IX_ComputerMouse_Price
ON ComputerMouse(Price);
--Некластеризований
CREATE NONCLUSTERED INDEX IX_OrderTable_TotalAmount_OrderDate
ON OrderTable(TotalAmount, OrderDate);
--Унікальний
CREATE UNIQUE INDEX IX_Customer_Email
ON Customer(Email);
--Індекс з включеними стовпцями
CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductId_OrderId
ON OrderDetails(ProductId)
INCLUDE (OrderId, ProductQuantity);
--Фільтрований індекс
CREATE NONCLUSTERED INDEX IX_ComputerMouse_Size_Medium
ON ComputerMouse(Price)
WHERE Size = 'Medium';
SELECT
    DB_NAME() AS [База_даних],
    OBJECT_NAME(i.[object_id]) AS [Таблиця],
    i.name AS [Індекс],
    i.type_desc AS [Тип_індексу],
    i.is_unique AS [Унікальний],
    ps.avg_fragmentation_in_percent AS [Фрагментація_у_%],
    ps.page_count AS [Кількість_сторінок]
FROM
    sys.indexes AS i
INNER JOIN
    sys.dm_db_index_physical_stats(DB_ID('pcmouse'), NULL, NULL, NULL, 'LIMITED') AS ps
    ON i.[object_id] = ps.[object_id] AND i.index_id = ps.index_id
WHERE
    OBJECT_SCHEMA_NAME(i.object_id) = 'dbo' AND
    OBJECT_NAME(i.object_id) IN (
        'Supplier', 'ComputerMouse', 'Customer', 'OrderTable', 'OrderDetails'
    )
    AND i.type > 0
    AND i.is_hypothetical = 0
ORDER BY
    ps.avg_fragmentation_in_percent DESC;*/