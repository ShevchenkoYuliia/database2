use pcmouse;

UPDATE Supplier
SET ContactNumber = '+380501234888'
WHERE SupplierId = 1;

UPDATE ComputerMouse
SET Price = 2400
WHERE ProductId = 101;

UPDATE ComputerMouse
SET Color = 'Black'
WHERE ProductId = 103;

UPDATE Customer
SET ShippingAddress = 'Lviv, Khreshchatyk St, 7'
WHERE CustomerId = 1002;

UPDATE OrderTable
SET OrderDate = '2024-11-24'
WHERE OrderId = 1;

UPDATE OrderTable
SET TotalAmount = 3100
WHERE OrderId = 2;

UPDATE OrderDetails
SET ItemAmount = 5200
WHERE OrderDetailsId = 1;

UPDATE OrderDetails
SET ProductQuantity = 2
WHERE OrderDetailsId = 2;