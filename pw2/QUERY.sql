USE pcmouse;

-- Select all mouse models and their prices
SELECT ModelName, Price FROM ComputerMouse;

-- Count the total stock quantity
SELECT SUM(StockQuantity) AS TotalStock FROM ComputerMouse;

-- Show all orders with their details
SELECT OrderTable.OrderId, Customer.FirstName, Customer.LastName, ComputerMouse.ModelName, 
       OrderDetails.ProductQuantity, OrderDetails.ItemAmount
FROM OrderTable
JOIN Customer ON OrderTable.CustomerId = Customer.CustomerId
JOIN OrderDetails ON OrderTable.OrderId = OrderDetails.OrderId
JOIN ComputerMouse ON OrderDetails.ProductId = ComputerMouse.ProductId;

-- Calculate the total amount of all orders
SELECT SUM(TotalAmount) AS TotalSum FROM OrderTable;

-- Show suppliers that supply wired mice
SELECT DISTINCT Supplier.* FROM Supplier
JOIN ComputerMouse ON Supplier.SupplierId = ComputerMouse.SupplierId
WHERE ComputerMouse.Type = 'Wired';
