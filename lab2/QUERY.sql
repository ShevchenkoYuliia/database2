USE pcmouse;
-- завдання 4
SELECT * FROM ComputerMouse WHERE Price > 3500;
SELECT * FROM ComputerMouse WHERE Size = 'Large';
SELECT * FROM ComputerMouse WHERE Color = 'Green';
SELECT * FROM ComputerMouse WHERE ButtonCount < 5;
SELECT * FROM ComputerMouse WHERE Type = 'Wired';
-- завдання 5
SELECT * FROM ComputerMouse WHERE Price < 2000 AND Color = 'Gray';
SELECT * FROM Customer WHERE LastName = 'Tkachenko' AND FirstName = 'Mykhailo'
SELECT * FROM ComputerMouse WHERE Color = 'Gray' AND Brand = 'Logitech';
SELECT * FROM ComputerMouse WHERE Price > 3000 AND Color = 'White' AND Type = 'Wireless'; 
SELECT * FROM ComputerMouse WHERE Size = 'Large' AND StockQuantity > 30;

--завдання 6
SELECT * FROM Customer WHERE ShippingAddress LIKE '%Poltava%';
SELECT * FROM Supplier WHERE Name LIKE '%Cyber%'; 
SELECT * FROM Customer WHERE Email LIKE 'ivan.%';
SELECT * FROM OrderTable WHERE OrderDate LIKE '2025%';
SELECT * FROM Customer WHERE PhoneNumber LIKE '%09512346%'; 

--завдання 7

SELECT * FROM OrderTable
JOIN Customer ON OrderTable.CustomerId = Customer.CustomerId;

SELECT OrderTable.OrderId, Customer.FirstName, Customer.LastName, ComputerMouse.ModelName, 
       OrderDetails.ProductQuantity, OrderDetails.ItemAmount  
FROM OrderTable  
JOIN Customer ON OrderTable.CustomerId = Customer.CustomerId  
JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId  
JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

SELECT ComputerMouse.ProductId, ComputerMouse.ModelName, ComputerMouse.Brand, Supplier.Name AS SupplierName, Supplier.ContactNumber  
FROM ComputerMouse  
JOIN Supplier ON ComputerMouse.SupplierId = Supplier.SupplierId;  

SELECT OrderTable.OrderId, OrderTable.OrderDate, OrderDetails.ProductQuantity, OrderDetails.ItemAmount,ComputerMouse.ModelName, 
    ComputerMouse.Brand,  Supplier.Name AS SupplierName, Supplier.ContactNumber  
FROM OrderTable  
JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId  
JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId  
JOIN Supplier ON ComputerMouse.SupplierId = Supplier.SupplierId;  

SELECT ComputerMouse.ProductId, ComputerMouse.ModelName, ComputerMouse.Brand, OrderTable.OrderId, OrderTable.OrderDate, 
	OrderDetails.ProductQuantity, OrderDetails.ItemAmount
FROM ComputerMouse  
JOIN OrderDetails ON ComputerMouse.ProductId = OrderDetails.ProductId  
JOIN OrderTable ON OrderDetails.OrderId = OrderTable.OrderId;

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
SELECT ModelName, Price
FROM ComputerMouse
WHERE SupplierId IN (
    SELECT SupplierId 
    FROM Supplier 
    WHERE Address LIKE '%Zhytomyr%'
)
AND Price >= 2000;


SELECT ModelName, Price, SupplierId 
FROM ComputerMouse 
WHERE Price = (
    SELECT MAX(Price) 
    FROM ComputerMouse AS CM 
    WHERE CM.SupplierId = ComputerMouse.SupplierId
)
AND Price > 3000;

SELECT FirstName, LastName 
FROM Customer 
WHERE CustomerId IN (
    SELECT CustomerId 
    FROM OrderTable 
    WHERE TotalAmount > 3000
)

SELECT FirstName, LastName 
FROM Customer 
WHERE CustomerId IN (
    SELECT DISTINCT CustomerId 
    FROM OrderTable
);
SELECT OrderId, OrderDate, TotalAmount
FROM OrderTable 
WHERE OrderId IN (
    SELECT OrderId 
    FROM OrderDetails 
    WHERE ProductId IN (
        SELECT ProductId 
        FROM ComputerMouse 
        WHERE Color = 'Black'
    )
);

--завдання 10
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

--завдання 11
SELECT Supplier.Name AS SupplierName, ComputerMouse.ModelName, SUM(ComputerMouse.StockQuantity) AS TotalStock,
    (SELECT SUM(OrderDetails.ProductQuantity) 
     FROM OrderDetails 
     WHERE OrderDetails.ProductId = ComputerMouse.ProductId) AS TotalSold
FROM Supplier
JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId
LEFT JOIN OrderDetails ON ComputerMouse.ProductId = OrderDetails.ProductId
WHERE Supplier.Address LIKE '%Lviv%' 
GROUP BY Supplier.Name, ComputerMouse.ModelName, ComputerMouse.ProductId
HAVING SUM(ComputerMouse.StockQuantity) <= 30;

SELECT o.OrderId, c.FirstName, c.LastName, SUM(od.ProductQuantity) AS TotalItems, o.TotalAmount
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
GROUP BY o.OrderId, c.FirstName, c.LastName, o.TotalAmount;

SELECT c.CustomerId, c.FirstName, c.LastName
FROM Customer c
JOIN OrderTable o ON c.CustomerId = o.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
WHERE cm.Color = 'Black';

SELECT cm.ModelName, cm.Brand, cm.StockQuantity, s.Name AS SupplierName
FROM ComputerMouse cm
JOIN Supplier s ON cm.SupplierId = s.SupplierId
WHERE cm.StockQuantity < 15;


SELECT s.Name AS SupplierName, AVG(cm.Price) AS AvgPrice
FROM Supplier s
JOIN ComputerMouse cm ON s.SupplierId = cm.SupplierId
GROUP BY s.Name
HAVING AVG(cm.Price) > 3000;

--завдання 12
SELECT  Supplier.Name AS SupplierName, Supplier.Address AS SupplierAddress, ComputerMouse.ModelName, ComputerMouse.Price, ComputerMouse.Color
FROM Supplier
JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId
WHERE Supplier.Address LIKE '%Kyiv%' 
AND ComputerMouse.Price > 2000 
AND ComputerMouse.Color = 'Black';

SELECT c.CustomerId, c.FirstName, c.LastName
FROM Customer c
JOIN OrderTable o ON c.CustomerId = o.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
WHERE cm.Brand = 'Logitech';

SELECT s.SupplierId, s.Name, s.ContactNumber, s.Email
FROM Supplier s
JOIN ComputerMouse cm ON s.SupplierId = cm.SupplierId
WHERE cm.Color = 'Red';

SELECT o.OrderId, c.FirstName, c.LastName, o.OrderDate, o.TotalAmount
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
WHERE o.OrderDate > '2025-01-01' AND o.TotalAmount > 6000;

SELECT cm.ModelName, cm.Brand, cm.Price, cm.ButtonCount, s.Name AS SupplierName
FROM ComputerMouse cm
JOIN Supplier s ON cm.SupplierId = s.SupplierId
WHERE cm.Price > 3300 AND cm.ButtonCount > 5;