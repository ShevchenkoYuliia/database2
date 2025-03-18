USE pcmouse;
-- завдання 3
SELECT * FROM ComputerMouse WHERE Price < 2000;

-- завдання 4
SELECT * FROM ComputerMouse WHERE Price < 2000 AND Color = 'Gray';

--завдання 5
SELECT * FROM Customer WHERE ShippingAddress LIKE '%Poltava%';

--завдання 6
SELECT * FROM OrderTable
JOIN Customer ON OrderTable.CustomerId = Customer.CustomerId;

--завдання 7
SELECT 
    Customer.CustomerId,
    Customer.FirstName,
    Customer.LastName,
    OrderTable.OrderId,
    OrderTable.OrderDate,
    OrderDetails.ProductQuantity,
    ComputerMouse.ModelName,
    ComputerMouse.Brand,
    ComputerMouse.Color
FROM Customer
LEFT JOIN OrderTable ON Customer.CustomerId = OrderTable.CustomerId
LEFT JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId
RIGHT JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

--завдання 8
SELECT ModelName, Price
FROM ComputerMouse
WHERE SupplierId IN (
    SELECT SupplierId 
    FROM Supplier 
    WHERE Address LIKE '%Zhytomyr%'
)
AND Price >= 2000;

--завдання 9
SELECT 
    Supplier.Name AS SupplierName,
    ComputerMouse.ModelName,
    SUM(ComputerMouse.StockQuantity) AS TotalStock
FROM ComputerMouse
JOIN Supplier ON ComputerMouse.SupplierId = Supplier.SupplierId
GROUP BY Supplier.Name, ComputerMouse.ModelName
HAVING SUM(ComputerMouse.StockQuantity) > 40
ORDER BY TotalStock DESC;

--завдання 10
SELECT 
    Supplier.Name AS SupplierName,
    ComputerMouse.ModelName,
    SUM(ComputerMouse.StockQuantity) AS TotalStock,
    (SELECT SUM(OrderDetails.ProductQuantity) 
     FROM OrderDetails 
     WHERE OrderDetails.ProductId = ComputerMouse.ProductId) AS TotalSold
FROM Supplier
JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId
LEFT JOIN OrderDetails ON ComputerMouse.ProductId = OrderDetails.ProductId
WHERE Supplier.Address LIKE '%Lviv%' 
GROUP BY Supplier.Name, ComputerMouse.ModelName, ComputerMouse.ProductId
HAVING SUM(ComputerMouse.StockQuantity) <= 30;

--завдання 11
SELECT 
    Supplier.Name AS SupplierName,
	Supplier.Address AS SupplierAddress,
    ComputerMouse.ModelName,
    ComputerMouse.Price,
    ComputerMouse.Color
FROM Supplier
JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId
WHERE Supplier.Address LIKE '%Kyiv%' 
AND ComputerMouse.Price > 2000 
AND ComputerMouse.Color = 'Black';
