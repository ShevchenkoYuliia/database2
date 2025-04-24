USE pcmouse;
--завдання 3
GO
CREATE FUNCTION dbo.GetCustomerFullName(
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50)
)
RETURNS NVARCHAR(100)
AS
BEGIN
    RETURN @FirstName + ' ' + @LastName
END
GO
SELECT 
    CustomerId, 
    dbo.GetCustomerFullName(FirstName, LastName) AS FullName
FROM Customer;

GO
CREATE FUNCTION dbo.IsProductInStock(@StockQuantity INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    RETURN CASE 
        WHEN @StockQuantity > 0 THEN 'In Stock'
        ELSE 'Out of Stock'
    END
END

GO
SELECT 
    ProductId,
    ModelName,
    StockQuantity,
    dbo.IsProductInStock(StockQuantity) AS StockStatus
FROM ComputerMouse;

GO
CREATE FUNCTION dbo.CalculateDiscountedAmount(
    @ItemAmount DECIMAL(10, 2),
    @ProductQuantity INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @DiscountRate DECIMAL(4,2)

    IF @ProductQuantity > 1
        SET @DiscountRate = 0.10
    ELSE
        SET @DiscountRate = 0.00

    RETURN @ItemAmount - (@ItemAmount * @DiscountRate)
END
GO
SELECT 
    OrderDetailsId,
    ProductQuantity,
    ItemAmount,
    dbo.CalculateDiscountedAmount(ItemAmount, ProductQuantity) AS DiscountedPrice
FROM OrderDetails;

--завдання 4

GO
CREATE FUNCTION dbo.GetSupplierContactInfoInline(
    @Name NVARCHAR(100),
    @Address NVARCHAR(200),
    @ContactNumber NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN (
    SELECT CONCAT(@Name, ' | ', @Address, ' | Tel: ', @ContactNumber) AS ContactInfo
);

GO
SELECT 
    SupplierId,
    (SELECT ContactInfo FROM dbo.GetSupplierContactInfoInline(Name, Address, ContactNumber)) AS SupplierContact
FROM Supplier;

GO
CREATE FUNCTION dbo.GetFormattedOrderDateInline(@OrderDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT FORMAT(@OrderDate, 'd MMMM yyyy', 'uk-UA') AS FormattedDate
);
GO
SELECT 
    OrderId,
    (SELECT FormattedDate FROM dbo.GetFormattedOrderDateInline(OrderDate)) AS PrettyDate,
    TotalAmount
FROM OrderTable;

GO
CREATE FUNCTION dbo.GetCustomerLevelInline(@TotalAmount DECIMAL(10, 2))
RETURNS TABLE
AS
RETURN (
    SELECT 
        CASE 
            WHEN @TotalAmount < 2500 THEN 'Новачок'
            WHEN @TotalAmount < 5000 THEN 'Регулярний'
            ELSE 'VIP'
        END AS CustomerLevel
);
GO
SELECT 
    OrderId,
    CustomerId,
    TotalAmount,
    (SELECT CustomerLevel FROM dbo.GetCustomerLevelInline(TotalAmount)) AS Category
FROM OrderTable;

--завдання 5
GO
CREATE FUNCTION dbo.GetMouseCountByBrand(@Brand NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @Count INT

    SELECT @Count = COUNT(*) 
    FROM ComputerMouse 
    WHERE Brand = @Brand

    RETURN @Count
END
GO
SELECT 
    DISTINCT Brand,
    dbo.GetMouseCountByBrand(Brand) AS BrandModelCount
FROM ComputerMouse;

GO
CREATE FUNCTION dbo.GetOrderTypeByQuantity(@OrderId INT)
RETURNS NVARCHAR(30)
AS
BEGIN
    DECLARE @TotalQty INT
    DECLARE @Result NVARCHAR(30)

    SELECT @TotalQty = SUM(ProductQuantity)
    FROM OrderDetails
    WHERE OrderId = @OrderId

    SET @Result =
        CASE 
            WHEN @TotalQty IS NULL THEN 'Без товарів'
            WHEN @TotalQty <= 2 THEN 'Маленьке замовлення'
            WHEN @TotalQty <= 4 THEN 'Середнє замовлення'
            ELSE 'Велике замовлення'
        END

    RETURN @Result
END
GO
SELECT 
    OrderId,
    dbo.GetOrderTypeByQuantity(OrderId) AS OrderSizeType
FROM OrderTable;

GO
CREATE FUNCTION dbo.GetAveragePriceByMouseType(@MouseType NVARCHAR(50))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @AvgPrice DECIMAL(10,2)

    SELECT @AvgPrice = AVG(Price)
    FROM ComputerMouse
    WHERE Type = @MouseType

    RETURN ISNULL(@AvgPrice, 0)
END
GO
SELECT 
    DISTINCT Type,
    dbo.GetAveragePriceByMouseType(Type) AS AvgPrice
FROM ComputerMouse;

--завдання 6
GO  
CREATE FUNCTION dbo.GetOrdersByCustomer(@CustomerId INT)
RETURNS TABLE
AS
RETURN
    SELECT 
        o.OrderId,
        o.OrderDate,
        o.TotalAmount
    FROM OrderTable o
    WHERE o.CustomerId = @CustomerId;
GO
SELECT * FROM dbo.GetOrdersByCustomer(1046);

GO
CREATE FUNCTION dbo.GetTotalProductsInOrder(@OrderId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = SUM(ProductQuantity)
    FROM OrderDetails
    WHERE OrderId = @OrderId;

    RETURN ISNULL(@Total, 0);
END

GO
SELECT 
    OrderId,
    dbo.GetTotalProductsInOrder(OrderId) AS TotalProducts
FROM OrderTable;

GO
CREATE FUNCTION dbo.GetAveragePricePerBrand()
RETURNS TABLE
AS
RETURN
    SELECT 
        Brand,
        AVG(Price) AS AvgPrice
    FROM ComputerMouse
    GROUP BY Brand;
GO
SELECT * FROM dbo.GetAveragePricePerBrand();
