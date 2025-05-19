use pcmouse;
BEGIN TRAN;

UPDATE Supplier
SET Name = 'Test Supplier'
WHERE SupplierId = 1;

UPDATE ComputerMouse
SET StockQuantity = StockQuantity - 999
WHERE ProductId = 101;

IF EXISTS (SELECT 1 FROM ComputerMouse WHERE ProductId = 101 AND StockQuantity < 0)
    ROLLBACK;
ELSE
    COMMIT;


BEGIN TRAN;

UPDATE ComputerMouse
SET Price = Price + 50
WHERE ProductId = 9999999; 

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;


BEGIN TRAN;
BEGIN TRY
    UPDATE Supplier
    SET Email = 'this_email_is_too_long_to_fit_in_the_field_and_should_cause_an_error_because_it_is_over_100_characters@example.com'
    WHERE SupplierId = 1;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Помилка: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRANSACTION;

WITH Numbers AS (
    SELECT TOP (100000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)

INSERT INTO ComputerMouse (
    ProductId, ModelName, Brand, Type, ButtonCount, Size,
    Price, StockQuantity, Color, SupplierId
)
SELECT
    n,
    'Model_' + CAST(n AS NVARCHAR),
    'Logitech',
    CASE WHEN n % 2 = 0 THEN 'Wired' ELSE 'Wireless' END,
    3 + (n % 4),
    'Medium',
    CAST(15.99 + (n % 50) AS DECIMAL(10, 2)),
    10 + (n % 100),
    CASE WHEN n % 3 = 0 THEN 'Black' ELSE 'White' END,
    1
FROM Numbers;

COMMIT;

BEGIN TRANSACTION;

DROP PROCEDURE IF EXISTS CreateOrder;

EXEC('
CREATE PROCEDURE CreateOrder 
    @OrderId INT,
    @CustomerId INT,
    @OrderDate DATE,
    @TotalAmount DECIMAL(10,2)
AS
BEGIN
    PRINT ''[START] Виконання: '' + CONVERT(NVARCHAR, GETDATE(), 120);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO OrderTable (OrderId, CustomerId, OrderDate, TotalAmount)
        VALUES (@OrderId, @CustomerId, @OrderDate, @TotalAmount);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    PRINT ''[END] Завершено: '' + CONVERT(NVARCHAR, GETDATE(), 120);
END;
');

COMMIT;

GO
EXEC CreateOrder 
    @OrderId = 1000,
    @CustomerId = 101,
    @OrderDate = '12.12.2012',
    @TotalAmount = 1999.99;

SET STATISTICS TIME ON;

SELECT 
    c.FirstName + ' ' + c.LastName AS CustomerName,
    cm.ModelName AS MouseModel,
    od.ProductQuantity,
    od.ItemAmount,
    o.OrderDate
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
WHERE o.TotalAmount > 10
  AND o.OrderDate >= '2025-01-01'
ORDER BY o.OrderDate DESC, c.LastName;
SET STATISTICS TIME OFF;


DROP INDEX IX_OrderTable_TotalAmount_OrderDate ON OrderTable;

DROP INDEX IX_OrderDetails_OrderDate_Customer_LastName ON OrderTable;

DROP INDEX IX_OrderDetails_OrderId_ProductId ON OrderDetails;


CREATE INDEX IX_OrderTable_TotalAmount_OrderDate ON OrderTable (TotalAmount, OrderDate) WHERE TotalAmount > 10 AND OrderDate >= '2025-01-01';
CREATE INDEX IX_OrderDetails_OrderDate_Customer_LastName ON OrderTable (OrderDate) INCLUDE (CustomerId, TotalAmount)
CREATE INDEX IX_OrderDetails_OrderId_ProductId ON OrderDetails (OrderId, ProductId);

DECLARE @StartTime DATETIME, @EndTime DATETIME;
DECLARE @CustomerName NVARCHAR(100);
DECLARE @MouseModel NVARCHAR(100);
DECLARE @ProductQuantity INT;
DECLARE @ItemAmount DECIMAL(10,2);
DECLARE @OrderDate DATE;

DECLARE @Result TABLE (
    CustomerName NVARCHAR(100),
    MouseModel NVARCHAR(100),
    ProductQuantity INT,
    ItemAmount DECIMAL(10,2),
    OrderDate DATE
);

DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT 
    c.FirstName + ' ' + c.LastName,
    cm.ModelName,
    od.ProductQuantity,
    od.ItemAmount,
    o.OrderDate
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
WHERE o.TotalAmount > 10
  AND o.OrderDate >= '2025-01-01'
ORDER BY o.OrderDate DESC, c.LastName;
SET @StartTime = GETDATE();
OPEN order_cursor;

FETCH NEXT FROM order_cursor INTO 
    @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @Result
    VALUES (@CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate);

    FETCH NEXT FROM order_cursor INTO 
        @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;
END;
SET @EndTime = GETDATE();
CLOSE order_cursor;
DEALLOCATE order_cursor;
SELECT * FROM @Result;
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecutionTimeMs;


DECLARE @StartTime1 DATETIME, @EndTime1 DATETIME;
DECLARE @StartTime2 DATETIME, @EndTime2 DATETIME;

DECLARE @CustomerName NVARCHAR(100);
DECLARE @MouseModel NVARCHAR(100);
DECLARE @ProductQuantity INT;
DECLARE @ItemAmount DECIMAL(10,2);
DECLARE @OrderDate DATE;

DECLARE @Result1 TABLE (
    CustomerName NVARCHAR(100),
    MouseModel NVARCHAR(100),
    ProductQuantity INT,
    ItemAmount DECIMAL(10,2),
    OrderDate DATE
);

DECLARE @Result2 TABLE (
    CustomerName NVARCHAR(100),
    MouseModel NVARCHAR(100),
    ProductQuantity INT,
    ItemAmount DECIMAL(10,2),
    OrderDate DATE
);

DECLARE order_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT 
    c.FirstName + ' ' + c.LastName,
    cm.ModelName,
    od.ProductQuantity,
    od.ItemAmount,
    o.OrderDate
FROM OrderTable o
JOIN Customer c ON o.CustomerId = c.CustomerId
JOIN OrderDetails od ON o.OrderId = od.OrderId
JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
WHERE o.TotalAmount > 10
  AND o.OrderDate >= '2025-01-01'
ORDER BY o.OrderDate DESC, c.LastName;

SET @StartTime1 = GETDATE();
OPEN order_cursor;

FETCH NEXT FROM order_cursor INTO 
    @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @Result1
    VALUES (@CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate);

    FETCH NEXT FROM order_cursor INTO 
        @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;
END;
SET @EndTime1 = GETDATE();
CLOSE order_cursor;
SET @StartTime2 = GETDATE();
OPEN order_cursor;

FETCH NEXT FROM order_cursor INTO 
    @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @Result2
    VALUES (@CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate);

    FETCH NEXT FROM order_cursor INTO 
        @CustomerName, @MouseModel, @ProductQuantity, @ItemAmount, @OrderDate;
END;
SET @EndTime2 = GETDATE();
CLOSE order_cursor;
DEALLOCATE order_cursor;
SELECT DATEDIFF(MILLISECOND, @StartTime1, @EndTime1) AS ExecutionTimeMs;
SELECT DATEDIFF(MILLISECOND, @StartTime2, @EndTime2) AS ExecutionTimeMs;
