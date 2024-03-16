use vendingMachine;

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
DROP TABLE IF EXISTS VendingM_Prodotto;
CREATE TABLE VendingM_Prodotto(
	VendingMachineID INT NOT NULL,
	ProductID INT NOT NULL,
	ProductQt INT CHECK (ProductQt > 0),
	FOREIGN KEY (VendingMachineID) REFERENCES VendingMachine(VendingMachineID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
	PRIMARY KEY (VendingMachineID, ProductID)
)


-- Inserisci una nuova macchina distributrice
INSERT INTO VendingMachine (Location, Model)
VALUES ('Milano', 'Modello XYZ');

-- Inserisci un nuovo prodotto
INSERT INTO Product (Name, Price, StockQuantity)
VALUES ('Snack al formaggio', 2.99, 100);

-- Inserisci una nuova transazione
INSERT INTO Trs (VendingMachineID, ProductID, TransactionDateTime, Amount)
VALUES (1, 1, '2024-16-03 16:30:00', 2.99);

-- Inserisci un nuovo fornitore
INSERT INTO Supplier (Name, ContactDetails)
VALUES ('Fornitore ABC', 'info@fornitoreabc.com');

INSERT INTO Maintenance (VendingMachineID, MaintenanceDate, Description)
VALUES (1, '2024-03-16', 'Primo controllo');
-- Inserisci una nuova manutenzione
INSERT INTO Maintenance (VendingMachineID, MaintenanceDate, Description)
VALUES (1, '2024-03-20', 'Secondo controllo');








CREATE VIEW ProductsByVendingMachine AS
SELECT
    VendingMachine.VendingMachineID,
    VendingMachine.Location,
    Product.Name,
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

--Creare una vista ScheduledMaintenance che mostri tutti i distributori che hanno una
--manutenzione programmata, includendo l'ID e la posizione del distributore e la data dell'ultima e
--della prossima manutenzione.


CREATE VIEW ScheduledMaintenanceNext AS
SELECT TOP 1 VendingMachine.VendingMachineID, Location, MaintenanceDate as 'Prossima Manutenzione'
FROM VendingMachine
JOIN Maintenance ON VendingMachine.VendingMachineID = Maintenance.VendingMachineID
ORDER BY MaintenanceDate DESC;

CREATE VIEW ScheduledMaintenance AS
SELECT VendingMachine.VendingMachineID, VendingMachine.Location, MaintenanceDate as 'Ultima Manutenzione', [Prossima Manutenzione]
FROM VendingMachine
JOIN Maintenance ON VendingMachine.VendingMachineID = Maintenance.VendingMachineID
JOIN ScheduledMaintenanceNext ON VendingMachine.VendingMachineID = ScheduledMaintenanceNext.VendingMachineID
ORDER BY MaintenanceDate DESC OFFSET 1 ROW;

--Implementare una stored procedure RefillProduct che consenta di aggiungere scorte di un
--prodotto specifico in un distributore, richiedendo l'ID del distributore, l'ID del prodotto e la
--quantità da aggiungere.

CREATE PROCEDURE InsertProdotto
	@idDisributore INT,
	@idProd INT,
	@qtProd int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			INSERT INTO VendingM_Prodotto (VendingMachineID, ProductID, ProductQt) VALUES
			(@idDisributore, @idProd, @qtProd);

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK

		PRINT 'Errore: ' + ERROR_MESSAGE()
	END CATCH
END;

