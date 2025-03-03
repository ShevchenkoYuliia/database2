use pcmouse;


CREATE TABLE Supplier (
    SupplierId INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    ContactNumber NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE ComputerMouse (
    ProductId INT PRIMARY KEY,
    ModelName NVARCHAR(100) NOT NULL,
    Brand NVARCHAR(50) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    ButtonCount INT NOT NULL,
    Size NVARCHAR(20),
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL,
    Color NVARCHAR(20),
    SupplierId INT NOT NULL,
    FOREIGN KEY (SupplierId) REFERENCES Supplier(SupplierId)
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
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);

CREATE TABLE OrderDetails (
    OrderDetailsId INT PRIMARY KEY,
    ProductId INT NOT NULL,
    OrderId INT NOT NULL,
    ProductQuantity INT NOT NULL,
    ItemAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ProductId) REFERENCES ComputerMouse(ProductId),
    FOREIGN KEY (OrderId) REFERENCES OrderTable(OrderId)
);
