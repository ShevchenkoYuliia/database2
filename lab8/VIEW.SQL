USE pcmouse;
GO

CREATE VIEW vw_OrderSummary AS
SELECT 
    o.OrderId,
    o.OrderDate,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    cm.ModelName,
    cm.Brand,
    od.ProductQuantity,
    od.ItemAmount
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId;
GO

SELECT * FROM vw_OrderSummary
ORDER BY OrderDate DESC;

GO
CREATE VIEW vCustomerNames AS
SELECT CustomerID, FirstName, LastName
FROM Customer;


GO
SELECT FirstName, LastName FROM vCustomerNames;
SELECT * FROM vCustomerNames;

GO
CREATE VIEW vKyivCustomers AS
SELECT *
FROM Customer
WHERE ShippingAddress LIKE '%Kyiv,%';
GO
SELECT * FROM vKyivCustomers;


GO
UPDATE vKyivCustomers
SET BonusAccountNumber = '111111'
WHERE CustomerId = 1;
GO
SELECT * FROM vKyivCustomers;

GO
CREATE VIEW vCustomerOrders AS
SELECT 
    C.CustomerId, 
    C.FirstName, 
    C.LastName, 
    O.OrderId, 
    O.OrderDate
FROM Customer C
JOIN OrderTable O ON C.CustomerId = O.CustomerId;
GO
SELECT * FROM vCustomerOrders;
GO
CREATE VIEW vCustomerOrderCounts AS
SELECT 
    C.CustomerId, 
    C.FirstName, 
    C.LastName, 
    COUNT(O.OrderId) AS OrderCount
FROM Customer C
LEFT JOIN OrderTable O ON C.CustomerId = O.CustomerId
GROUP BY C.CustomerId, C.FirstName, C.LastName;

GO
SELECT * FROM vCustomerOrderCounts;
GO
CREATE VIEW vVIPCustomers AS
SELECT 
    CustomerId, 
    FirstName, 
    LastName, 
    OrderCount
FROM vCustomerOrderCounts
WHERE OrderCount > 2;
GO
SELECT * FROM vVIPCustomers;
GO
ALTER VIEW vCustomerOrders AS
SELECT 
    C.CustomerId, 
    C.FirstName, 
    C.LastName, 
    C.ShippingAddress, 
    O.OrderId, 
    O.OrderDate
FROM Customer C
JOIN OrderTable O ON C.CustomerId = O.CustomerId;
GO
SELECT * FROM vCustomerOrders;

GO
DROP VIEW vVIPCustomers;

GO
CREATE VIEW vOrderSummary AS
SELECT 
    OrderId, 
    TotalAmount AS OrderTotal, 
    OrderDate AS OrderDateTime
FROM OrderTable;

GO
SELECT * FROM vOrderSummary;
GO
CREATE VIEW vProductPriceWithTax AS
SELECT 
    ModelName AS ProductName, 
    Price, 
    Price * 1.20 AS PriceWithTax
FROM ComputerMouse;
GO
SELECT * FROM vProductPriceWithTax;
GO
CREATE VIEW vHighValueProducts AS
SELECT *
FROM ComputerMouse
WHERE Price > 3000
WITH CHECK OPTION;
GO
SELECT * FROM vHighValueProducts;

-- Цей запит викличе помилку, бо порушує CHECK OPTION
INSERT INTO vHighValueProducts (ProductId, ModelName, Brand, Type, ButtonCount, Size, Price, StockQuantity, Color, SupplierId)
VALUES (130, 'Aerox 9 Wireless', 'SteelSeries', 'Wireless', 12, 'Large', 2500, 15, 'White', 61);

GO
CREATE VIEW vEncryptedCustomerView
WITH ENCRYPTION
AS
SELECT CustomerId, FirstName, LastName
FROM Customer;
GO
sp_helptext 'vEncryptedCustomerView';

GO
CREATE VIEW vRestrictedOrders AS
SELECT OrderId, OrderDate
FROM OrderTable;
GO
CREATE LOGIN ReadOnlyUser WITH PASSWORD = 'StrongP@ssword123'
CREATE USER ReadOnlyUser FOR LOGIN ReadOnlyUser;
GRANT SELECT ON vRestrictedOrders TO ReadOnlyUser;

SELECT * from vRestrictedOrders;