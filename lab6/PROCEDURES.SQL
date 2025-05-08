USE pcmouse;
--Завдання 6
GO

-- 1. sp_help – отримати метадані про таблицю
EXEC sp_help 'ComputerMouse';

-- 2. sp_spaceused – оцінка зайнятого місця таблицею
EXEC sp_spaceused 'OrderDetails';

-- 3. sp_helpindex – інформація про індекси в таблиці
EXEC sp_helpindex 'Customer';
--Завдання 7
GO

-- 1. ##GetCustomerOrders – повертає всі замовлення конкретного покупця
CREATE PROCEDURE ##GetCustomerOrders
    @CustomerId INT
AS
BEGIN
    SELECT o.OrderId, o.OrderDate, o.TotalAmount
    FROM OrderTable o
    WHERE o.CustomerId = @CustomerId;
END;
GO

-- 2. ##GetLowStockMice – показує мишки, яких залишилося менше 10 штук на складі
CREATE PROCEDURE ##GetLowStockMice
AS
BEGIN
    SELECT ProductId, ModelName, StockQuantity
    FROM ComputerMouse
    WHERE StockQuantity < 20;
END;
GO

-- 3. ##GetSupplierStats – показує кількість моделей мишок від кожного постачальника
CREATE PROCEDURE ##GetSupplierStats
AS
BEGIN
    SELECT s.Name AS SupplierName, COUNT(cm.ProductId) AS MouseCount
    FROM Supplier s
    JOIN ComputerMouse cm ON s.SupplierId = cm.SupplierId
    GROUP BY s.Name;
END;
GO
EXEC ##GetCustomerOrders @CustomerId = 3;

EXEC ##GetLowStockMice;

EXEC ##GetSupplierStats;
--Завдання 8
GO

-- 1. #GetTopCustomers – повертає топ-5 клієнтів за сумою покупок
CREATE PROCEDURE #GetTopCustomers
AS
BEGIN
    SELECT TOP 5 
        c.FirstName + ' ' + c.LastName AS CustomerName,
        SUM(o.TotalAmount) AS TotalSpent
    FROM Customer c
    JOIN OrderTable o ON c.CustomerId = o.CustomerId
    GROUP BY c.FirstName, c.LastName
    ORDER BY TotalSpent DESC;
END;
GO

-- 2. #GetOutOfStockProducts – показує мишки, що повністю закінчилися
CREATE PROCEDURE #GetOutOfStockProducts
AS
BEGIN
    SELECT ProductId, ModelName, Brand
    FROM ComputerMouse
    WHERE StockQuantity = 0;
END;
GO

-- 3. #GetOrderDetailsByOrderId – повертає деталі замовлення за конкретним ID замовлення
CREATE PROCEDURE #GetOrderDetailsByOrderId
    @OrderId INT
AS
BEGIN
    SELECT od.OrderDetailsId, cm.ModelName, od.ProductQuantity, od.ItemAmount
    FROM OrderDetails od
    JOIN ComputerMouse cm ON od.ProductId = cm.ProductId
    WHERE od.OrderId = @OrderId;
END;
GO
EXEC #GetTopCustomers;

EXEC #GetOutOfStockProducts;

EXEC #GetOrderDetailsByOrderId @OrderId = 7;

--Завдання 9
GO

-- 1. Створити замовлення для покупця + Транзакція
CREATE PROCEDURE CreateOrder
    @OrderId INT,
    @CustomerId INT,
    @OrderDate DATE,
    @TotalAmount DECIMAL(10,2)
AS
BEGIN
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
END;

GO

-- 2. Додати товар до замовлення + Транзакція
CREATE PROCEDURE AddOrderDetail
    @OrderDetailsId INT,
    @OrderId INT,
    @ProductId INT,
    @ProductQuantity INT,
    @ItemAmount DECIMAL(10,2)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
        VALUES (@OrderDetailsId, @ProductId, @OrderId, @ProductQuantity, @ItemAmount);

        -- Оновлюємо кількість товару на складі
        UPDATE ComputerMouse
        SET StockQuantity = StockQuantity - @ProductQuantity
        WHERE ProductId = @ProductId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3. Видалити замовлення разом із деталями + Транзакція
CREATE PROCEDURE DeleteOrder
    @OrderId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM OrderDetails
        WHERE OrderId = @OrderId;
        
        DELETE FROM OrderTable
        WHERE OrderId = @OrderId;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- Створити замовлення
EXEC CreateOrder @OrderId = 503, @CustomerId = 2, @OrderDate = '2025-04-26', @TotalAmount = 300.00;

-- Додати товар до замовлення
EXEC AddOrderDetail @OrderDetailsId = 506, @OrderId = 101, @ProductId = 2, @ProductQuantity = 1, @ItemAmount = 300.00;

-- Видалити замовлення
EXEC DeleteOrder @OrderId = 503;


--Завдання 10
GO
-- Процедура для вставки Supplier
CREATE or alter PROCEDURE InsertSuppliers
    @N INT
AS
BEGIN
    DECLARE @i INT = 101;
    
    WHILE @i <= @N
    BEGIN
        INSERT INTO Supplier (SupplierId, Name, Address, ContactNumber, Email)
        VALUES (
            @i,
            CONCAT('Supplier_', @i),
            CONCAT('City_', @i, ', Street_', @i),
            CONCAT('+380', CAST(CAST(100000000 + RAND() * 900000000 AS BIGINT) AS VARCHAR(20))),
            CONCAT('supplier_', @i, '@example.com')
        );
        SET @i += 1;
    END
END
GO

-- Процедура для вставки ComputerMouse
CREATE or alter PROCEDURE InsertComputerMice
    @N INT
AS
BEGIN
    DECLARE @j INT = 101;

    WHILE @j <= @N
    BEGIN
        INSERT INTO ComputerMouse (ProductId, ModelName, Brand, Type, ButtonCount, Size, Price, StockQuantity, Color, SupplierId)
        VALUES (
            @j,
            CONCAT('Model_', @j),
            CONCAT('Brand_', @j % 10),
            CASE WHEN @j % 2 = 0 THEN 'Wired' ELSE 'Wireless' END,
            3 + (@j % 5),
            CONCAT('Size_', @j % 4),
            ROUND(100 + (RAND() * 900), 2),
            10 + (@j % 90),
            CASE WHEN @j % 3 = 0 THEN 'Black' ELSE 'White' END,
            @j
        );
        SET @j += 1;
    END
END
drop PROCEDURE InsertCustomers;
GO

-- Процедура для вставки Customer
CREATE or alter PROCEDURE InsertCustomers
    @N INT
AS
BEGIN
    DECLARE @y INT = 101;

    WHILE @y <= @N
    BEGIN
        INSERT INTO Customer (CustomerID, FirstName, LastName, Email, PhoneNumber, ShippingAddress, BonusAccountNumber)
        VALUES (
			@y,
            CONCAT('First', @y),
            CONCAT('Last', @y),
            CONCAT('customer', @y, '@example.com'),
            CONCAT('+380', RIGHT('000000000' + CAST(100000000 + @y AS VARCHAR), 9)),
            CONCAT('City_', @y, ', Street_', @y),
            CONCAT('BONUS', FORMAT(@y, '000000'))
        );
        SET @y += 1;
    END
END
GO
-- Процедура для вставки OrderTable
CREATE or alter PROCEDURE InsertOrders
    @N INT
AS
BEGIN
    DECLARE @k INT = 101;

    WHILE @k <= @N
    BEGIN
        INSERT INTO OrderTable (OrderId, CustomerId, OrderDate, TotalAmount)
        VALUES (
            @k,
			@k,
            DATEADD(DAY, -(@k % 100), GETDATE()),
            ROUND(100 + (RAND() * 500), 2)
        );
        SET @k += 1;
    END
END
GO

-- Процедура для вставки OrderDetails
CREATE or alter PROCEDURE InsertOrderDetails
    @N INT
AS
BEGIN
    DECLARE @m INT = 101;

    WHILE @m <= @N
    BEGIN
        DECLARE @quantity INT = 1 + (@m % 5);
        DECLARE @price DECIMAL(10, 2) = ROUND(100 + (RAND() * 400), 2);

        INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
        VALUES (
            @m,
			@m,
			@m,
            @quantity,
            @quantity * @price
        );
        SET @m += 1;
    END
END
GO
EXEC InsertSuppliers @N = 10000;
EXEC InsertComputerMice @N = 10000;
EXEC InsertCustomers @N = 10000;
EXEC InsertOrders @N = 10000;
EXEC InsertOrderDetails @N = 10000;

--Завдання 11
GO
CREATE PROCEDURE InsertCustomer
(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @PhoneNumber NVARCHAR(20),
    @ShippingAddress NVARCHAR(200),
    @BonusAccountNumber NVARCHAR(20),
    @NewCustomerId INT OUTPUT
)
AS
BEGIN
    BEGIN TRY
		DECLARE @Count INT;
		SELECT @Count = COUNT(*) FROM Customer;
        DECLARE @NextId INT = 1 + @Count;
        
        INSERT INTO Customer (CustomerId, FirstName, LastName, Email, PhoneNumber, ShippingAddress, BonusAccountNumber)
        VALUES (@NextId, @FirstName, @LastName, @Email, @PhoneNumber, @ShippingAddress, @BonusAccountNumber);

        SET @NewCustomerId = @NextId;
    END TRY
    BEGIN CATCH
        SET @NewCustomerId = NULL;
    END CATCH
END
GO
DECLARE @InsertedId INT;

EXEC InsertCustomer 
    @FirstName = 'Ivan',
    @LastName = 'Petrenko',
    @Email = 'ivan.petrenko@example.com',
    @PhoneNumber = '+380123456789',
    @ShippingAddress = 'Kyiv, Street 1',
    @BonusAccountNumber = 'BONUS001',
    @NewCustomerId = @InsertedId OUTPUT;

PRINT 'Inserted ID: ' + COALESCE(CAST(@InsertedId AS NVARCHAR), 'NULL');
