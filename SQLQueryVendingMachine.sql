CREATE TABLE VendingMachine (
    VendingMachineID INT PRIMARY KEY IDENTITY(1,1) ,
    Location VARCHAR(255) NOT NULL,
    Model VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL
);

CREATE TABLE Trs (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    VendingMachineID INT,
    ProductID INT,
    TransactionDateTime DATETIME NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (VendingMachineID) REFERENCES VendingMachine(VendingMachineID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    ContactDetails VARCHAR(255)
);
CREATE TABLE Maintenance (
    MaintenanceID INT PRIMARY KEY IDENTITY(1,1),
    VendingMachineID INT,
    MaintenanceDate DATE NOT NULL,
    Description TEXT,
    FOREIGN KEY (VendingMachineID) REFERENCES VendingMachine(VendingMachineID)
);

CREATE VIEW ProductsByVendingMachine AS
SELECT
    VendingMachine.VendingMachineID,
    VendingMachine.Location,
    Product.Name AS ProductName,
    Product.Price,
    Product.StockQuantity
FROM
    VendingMachine 
JOIN
    Trs ON VendingMachine.VendingMachineID = Trs.VendingMachineID
JOIN
    Product  ON Trs.ProductID = Product.ProductID;

CREATE VIEW RecentTransactions AS
SELECT TOP 10
    TransactionID,
    TransactionDateTime,
    VendingMachineID,
    ProductID,
    Amount
FROM
    Trs
ORDER BY
    TransactionDateTime DESC;