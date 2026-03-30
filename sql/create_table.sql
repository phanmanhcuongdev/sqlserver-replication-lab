
USE DDB;
GO

CREATE TABLE Customers
(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	FullName VARCHAR(100),
	Phone VARCHAR(15) UNIQUE,
	Address VARCHAR(255),
	CreatedAt DATETIME
);

CREATE TABLE Employees (
	EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
	FullName VARCHAR(100),
	Phone VARCHAR(15) UNIQUE,
	Role VARCHAR(50),
	HireDate DATE
);
CREATE TABLE Pizzas (
	PizzaID INT IDENTITY(1,1) PRIMARY KEY,
	PizzaName VARCHAR(100) UNIQUE,
	BasePrice DECIMAL(10,2),
	IsActive BIT
);

CREATE TABLE Orders (
	OrderID INT IDENTITY(1,1) PRIMARY KEY,
	CustomerID INTEGER,
	EmployeeID INTEGER,
	OrderTime DATETIME,
	Status VARCHAR(30),
	TotalAmount DECIMAL(10,2),

	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    PizzaID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    LineTotal DECIMAL(10,2),

    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PizzaID) REFERENCES Pizzas(PizzaID)
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT UNIQUE,
    Method VARCHAR(50),
    PaidAmount DECIMAL(10,2),
    PaidAt DATETIME,
    Status VARCHAR(30),

    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);