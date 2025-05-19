USE pcmouse;
GO
CREATE TRIGGER trg_AfterInsert_OrderDetails
ON OrderDetails
AFTER INSERT
AS
BEGIN
    DECLARE @ProductId INT;
    DECLARE @ProductQuantity INT;
    DECLARE @StockQuantity INT;

    SELECT @ProductId = ProductId, @ProductQuantity = ProductQuantity
    FROM INSERTED;

    SELECT @StockQuantity = StockQuantity
    FROM ComputerMouse
    WHERE ProductId = @ProductId;

    UPDATE ComputerMouse
    SET StockQuantity = @StockQuantity - @ProductQuantity
    WHERE ProductId = @ProductId;

    PRINT 'Товари оновлені після додавання запису в OrderDetails';
END;

GO
CREATE TRIGGER trg_AfterUpdate_ComputerMouse
ON ComputerMouse
AFTER UPDATE
AS
BEGIN
    DECLARE @ProductId INT;
    DECLARE @OldStockQuantity INT;
    DECLARE @NewStockQuantity INT;

    SELECT @ProductId = ProductId, @OldStockQuantity = StockQuantity
    FROM DELETED;

    SELECT @NewStockQuantity = StockQuantity
    FROM INSERTED;

    IF @OldStockQuantity <> @NewStockQuantity
    BEGIN
        PRINT 'Кількість товару на складі була оновлена.';
    END
END;
GO
CREATE TRIGGER trg_AfterDelete_OrderDetails
ON OrderDetails
AFTER DELETE
AS
BEGIN
    DECLARE @ProductId INT;
    DECLARE @ProductQuantity INT;
    DECLARE @StockQuantity INT;

    SELECT @ProductId = ProductId, @ProductQuantity = ProductQuantity
    FROM DELETED;

    SELECT @StockQuantity = StockQuantity
    FROM ComputerMouse
    WHERE ProductId = @ProductId;

    UPDATE ComputerMouse
    SET StockQuantity = @StockQuantity + @ProductQuantity
    WHERE ProductId = @ProductId;

    PRINT 'Товари оновлені після видалення запису з OrderDetails';
END;
GO
CREATE TRIGGER trg_InsteadOfInsert_OrderTable
ON OrderTable
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CustomerId INT;
    DECLARE @OrderDate DATE;
    DECLARE @TotalAmount DECIMAL(10, 2);

    SELECT @CustomerId = CustomerId, @OrderDate = OrderDate, @TotalAmount = TotalAmount
    FROM INSERTED;

    IF @TotalAmount > 0
    BEGIN
        INSERT INTO OrderTable (CustomerId, OrderDate, TotalAmount)
        VALUES (@CustomerId, @OrderDate, @TotalAmount);
    END
    ELSE
    BEGIN
        PRINT 'Загальна сума не може бути відємною або нульовою';
    END
END;

INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
VALUES (106, 1, 1, 3, 150);
UPDATE ComputerMouse
SET StockQuantity = 45 
WHERE ProductId = 1;
DELETE FROM OrderDetails WHERE OrderDetailsId = 101;
INSERT INTO OrderTable (OrderId, CustomerId, OrderDate, TotalAmount)
VALUES (111, 21, '2025-01-23', -5000);

GO
CREATE TRIGGER trg_AfterCreate
ON DATABASE
FOR CREATE_TABLE, CREATE_PROCEDURE, CREATE_VIEW
AS
BEGIN
    DECLARE @ObjectType NVARCHAR(100);
    DECLARE @ObjectName NVARCHAR(100);
    
    SET @ObjectType = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)');
    SET @ObjectName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)');

    PRINT 'Був створений новий обєкт у базі даних: ';
    PRINT 'Тип обєкта: ' + @ObjectType;
    PRINT 'Імя обєкта: ' + @ObjectName;
END;
GO
CREATE TRIGGER trg_AfterAlter 
ON DATABASE
FOR ALTER_TABLE, ALTER_PROCEDURE, ALTER_VIEW
AS
BEGIN
    DECLARE @ObjectType NVARCHAR(100);
    DECLARE @ObjectName NVARCHAR(100);

    SELECT 
        @ObjectType = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        @ObjectName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)');

    PRINT 'Був змінений обєкт у базі даних: ';
    PRINT 'Тип обєкта: ' + @ObjectType;
    PRINT 'Імя обєкта: ' + @ObjectName;
END;
GO

CREATE TRIGGER trg_AfterDrop
ON DATABASE
FOR DROP_TABLE, DROP_PROCEDURE, DROP_VIEW
AS
BEGIN
    DECLARE @ObjectType NVARCHAR(100);
    DECLARE @ObjectName NVARCHAR(100);

    SELECT 
        @ObjectType = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        @ObjectName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)');

    PRINT 'Був видалений обєкт з бази даних: ';
    PRINT 'Тип обєкта: ' + @ObjectType;
    PRINT 'Імя обєкта: ' + @ObjectName;
END;
GO

CREATE TRIGGER trg_AfterDDL
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW
AS
BEGIN
    DECLARE @ObjectType NVARCHAR(100);
    DECLARE @ObjectName NVARCHAR(100);
    DECLARE @EventType NVARCHAR(100);

    SELECT 
        @ObjectType = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        @ObjectName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        @EventType = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)');

    PRINT 'Був виконаний DDL запит:';
    PRINT 'Тип обєкта: ' + @ObjectType;
    PRINT 'Імя обєкта: ' + @ObjectName;
    PRINT 'Тип команди: ' + @EventType;
END;
GO
CREATE TRIGGER trg_LogonUserActivity
ON ALL SERVER
FOR LOGON
AS
BEGIN
    INSERT INTO UserLogins (LoginTime, UserName)
    VALUES (GETDATE(), SYSTEM_USER);
END;
DROP TRIGGER trg_LogonUserActivity ON ALL SERVER;

GO
CREATE TRIGGER trg_CheckFutureOrderDate
ON OrderTable
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE OrderDate > GETDATE()
    )
    BEGIN
        RAISERROR('Order date cannot be in the future.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    INSERT INTO OrderTable
    SELECT *
    FROM inserted;
END;
 
INSERT INTO OrderTable (OrderId, CustomerId, OrderDate, TotalAmount)
VALUES 
(1000, 21, '2026-01-23', 5000);
drop TRIGGER trg_UpdateStock;
GO
CREATE TRIGGER trg_UpdateStock
ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE m
    SET m.StockQuantity = m.StockQuantity - i.ProductQuantity
    FROM ComputerMouse m
    JOIN inserted i ON m.ProductId = i.ProductId;
END;
SELECT * FROM ComputerMouse WHERE ProductId = 1;
INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
VALUES (111, 1, 1, 5, 5000);
SELECT * FROM  ComputerMouse WHERE ProductId = 1;
GO
CREATE TRIGGER trg_CalculateOrderTotal
ON OrderDetails
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE o
    SET o.TotalAmount = (
        SELECT SUM(ItemAmount)
        FROM OrderDetails
        WHERE OrderId = o.OrderId
    )
    FROM OrderTable o
    JOIN inserted i ON o.OrderId = i.OrderId;
END;

INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
VALUES (1112, 1, 1, 2, 999);

select * from OrderTable where OrderId = 1;
select * from OrderDetails where OrderDetailsId = 1112;
GO
CREATE TRIGGER trg_CheckDuplicateProductInOrder
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN OrderDetails od
            ON i.OrderId = od.OrderId AND i.ProductId = od.ProductId
    )
    BEGIN
        RAISERROR('Product already exists in this order.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    INSERT INTO OrderDetails
    SELECT *
    FROM inserted;
END;

INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
VALUES (1117, 1, 1, 2, 999);