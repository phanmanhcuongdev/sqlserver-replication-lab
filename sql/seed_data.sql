USE DDB;
GO


INSERT INTO Customers (FullName, Phone, Address, CreatedAt) VALUES
('Nguyen Van A', '0900000001', 'Ha Noi', GETDATE()),
('Tran Thi B', '0900000002', 'Ha Noi', GETDATE()),
('Le Van C', '0900000003', 'Hai Phong', GETDATE()),
('Pham Thi D', '0900000004', 'Da Nang', GETDATE()),
('Hoang Van E', '0900000005', 'HCM', GETDATE());


INSERT INTO Employees (FullName, Phone, Role, HireDate) VALUES
('Nguyen Staff 1', '0910000001', 'Cashier', '2023-01-01'),
('Tran Staff 2', '0910000002', 'Chef', '2023-02-01'),
('Le Staff 3', '0910000003', 'Cashier', '2023-03-01');


INSERT INTO Pizzas (PizzaName, BasePrice, IsActive) VALUES
('Margherita', 100000, 1),
('Pepperoni', 120000, 1),
('Hawaiian', 130000, 1),
('Seafood', 150000, 1),
('BBQ Chicken', 140000, 1);


INSERT INTO Orders (CustomerID, EmployeeID, OrderTime, Status, TotalAmount) VALUES
(1, 1, GETDATE(), 'PAID', 200000),   -- ID 1
(2, 1, GETDATE(), 'PAID', 240000),   -- ID 2
(3, 2, GETDATE(), 'PENDING', 130000),-- ID 3
(4, 2, GETDATE(), 'PAID', 300000),   -- ID 4
(5, 3, GETDATE(), 'PENDING', 150000),-- ID 5
(1, 3, GETDATE(), 'PAID', 280000);   -- ID 6


INSERT INTO OrderItems (OrderID, PizzaID, Quantity, UnitPrice, LineTotal) VALUES
(1, 1, 2, 100000, 200000),

(2, 2, 2, 120000, 240000),

(3, 3, 1, 130000, 130000),

(4, 4, 2, 150000, 300000),

(5, 1, 1, 100000, 100000),
(5, 3, 1, 50000, 50000),

(6, 5, 2, 140000, 280000);


INSERT INTO Payments (OrderID, Method, PaidAmount, PaidAt, Status) VALUES
(1, 'CASH', 200000, GETDATE(), 'SUCCESS'),
(2, 'BANK', 240000, GETDATE(), 'SUCCESS'),
(4, 'CASH', 300000, GETDATE(), 'SUCCESS'),
(6, 'BANK', 280000, GETDATE(), 'SUCCESS');