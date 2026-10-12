CREATE TABLE dbo.Products
(
    ProductID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    UnitsInStock INT NOT NULL,
    Discontinued BIT NOT NULL DEFAULT 0
);

INSERT INTO dbo.Products (ProductName, Category, UnitPrice, UnitsInStock, Discontinued) VALUES
('Laptop Pro 15', 'Electronics', 1299.99, 45, 0),
('Wireless Mouse', 'Electronics', 29.99, 150, 0),
('Office Chair', 'Furniture', 249.99, 30, 0),
('Standing Desk', 'Furniture', 599.99, 15, 0),
('Coffee Maker', 'Appliances', 89.99, 60, 0),
('Notebook Set', 'Office Supplies', 12.99, 200, 0),
('USB-C Hub', 'Electronics', 49.99, 80, 0),
('Desk Lamp', 'Furniture', 39.99, 100, 0),
('Bluetooth Headphones', 'Electronics', 149.99, 50, 0),
('Water Bottle', 'Office Supplies', 19.99, 120, 0);