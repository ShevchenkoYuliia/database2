USE pcmouse;
CREATE TABLE Supplier (
    SupplierId INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    ContactNumber NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE ComputerMouse (
    ProductId INT PRIMARY KEY NONCLUSTERED,
    ModelName NVARCHAR(100) NOT NULL,
    Brand NVARCHAR(50) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    ButtonCount INT NOT NULL,
    Size NVARCHAR(20),
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    Color NVARCHAR(20),
    SupplierId INT NOT NULL,
    FOREIGN KEY (SupplierId) REFERENCES Supplier(SupplierId) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(20) NOT NULL UNIQUE,
    ShippingAddress NVARCHAR(200),
    BonusAccountNumber NVARCHAR(20) UNIQUE
);

CREATE TABLE OrderTable (
    OrderId INT PRIMARY KEY,
    CustomerId INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OrderDetails (
    OrderDetailsId INT PRIMARY KEY,
    ProductId INT NOT NULL,
    OrderId INT NOT NULL,
    ProductQuantity INT NOT NULL,
    ItemAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ProductId) REFERENCES ComputerMouse(ProductId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (OrderId) REFERENCES OrderTable(OrderId) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE audit_log (
    LogId INT IDENTITY PRIMARY KEY,
    Action NVARCHAR(100),
    Timestamp DATETIME DEFAULT GETDATE()
);
CREATE TABLE SupplierStats (
    StatId INT PRIMARY KEY,
    SupplierCount INT NOT NULL
);
