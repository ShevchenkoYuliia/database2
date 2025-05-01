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

UPDATE Supplier
SET ContactNumber = '123-456-7890'
WHERE SupplierId = 1;

SAVE TRANSACTION point1;

UPDATE Supplier
SET Email = '12345@example.com'
WHERE SupplierId = 1;

ROLLBACK TRANSACTION point1;

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

BEGIN TRAN;

UPDATE Customer
SET FirstName = 'Ivan'
WHERE CustomerId = 1;

INSERT INTO audit_log (Action)
VALUES ('Update Customer FirstName to Ivan');

COMMIT;
select * from audit_log;

BEGIN TRAN;

BEGIN TRY
    -- 1. Додаємо замовлення
    INSERT INTO OrderTable (OrderId, CustomerId, OrderDate, TotalAmount)
    VALUES (1001, 1, GETDATE(), 200.00);

    -- 2. Додаємо деталі замовлення
    INSERT INTO OrderDetails (OrderDetailsId, ProductId, OrderId, ProductQuantity, ItemAmount)
    VALUES (5001, 101, 1001, 2, 200.00);

    -- 3. Зменшуємо кількість товару на складі
    UPDATE ComputerMouse
    SET StockQuantity = StockQuantity - 2
    WHERE ProductId = 101;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Помилка: ' + ERROR_MESSAGE();
END CATCH;


BEGIN TRAN;

BEGIN TRY
    -- Додаємо нового постачальника
    INSERT INTO Supplier (SupplierId, Name, Address, ContactNumber, Email)
    VALUES (501, 'NovaTech', 'Lviv, Main Street 10', '380-67-555-1111', 'info@novatech.ua');

    -- Оновлюємо лічильник
    UPDATE SupplierStats
    SET SupplierCount = SupplierCount + 1
    WHERE StatId = 1;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Помилка: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRAN;

BEGIN TRY
    -- 1. Вставка нового постачальника в таблицю Supplier
    INSERT INTO Supplier (SupplierId, Name, Address, ContactNumber, Email)
    VALUES (701, 'TechWorld', 'Kyiv, Shevchenka St. 5', '380-67-777-7777', 'contact@techworld.ua');

    -- 2. Вставка нового товару для цього постачальника
    INSERT INTO ComputerMouse (ProductId, ModelName, Brand, Type, ButtonCount, Size, Price, StockQuantity, Color, SupplierId)
    VALUES (701, 'TechMouse Pro', 'TechWorld', 'Wired', 5, 'Medium', 40.99, 100, 'Black', 701);

    -- 3. Оновлення контактного номера для постачальника з SupplierId = 701
    UPDATE Supplier
    SET ContactNumber = '380-67-888-8888'
    WHERE SupplierId = 701;

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Помилка: ' + ERROR_MESSAGE();
END CATCH;