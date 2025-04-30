CREATE DATABASE SimpleEcommerce;
USE SimpleEcommerce;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    Category VARCHAR(255),  /*e.g., Electronics, Clothing*/
    ImageURL VARCHAR(255)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Address VARCHAR(255)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2), /*Price at the time of order*/
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
/*sample data insertion*/
INSERT INTO Products (ProductName, Description, Price, Category, ImageURL) 
VALUES
('Laptop', 'High-performance laptop', 999.99, 'Electronics', 'laptop.jpg'),
('T-Shirt', 'Cotton T-shirt', 19.99, 'Clothing', 'tshirt.jpg'),
('Book', 'Mystery novel', 12.99, 'Books', 'book.jpg');

INSERT INTO Customers (FirstName, LastName, Email, Address) 
VALUES
('John', 'Doe', 'john.doe@example.com', '123 Main St'),
('Jane', 'Smith', 'jane.smith@example.com', '456 Oak Ave');

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) 
VALUES
(1, '2023-11-20', 1019.98),  -- Laptop + T-Shirt
(2, '2023-11-21', 12.99);   -- Book

INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) 
VALUES
(1, 1, 1, 999.99),
(1, 2, 1, 19.99),
(2, 3, 1, 12.99);
/*queries:1 Get all products:*/
SELECT * FROM Products;
/*2 get all products by category*/
SELECT * FROM Products WHERE Category = 'Electronics';
/*3 Get customer orders:*/
SELECT * FROM Orders WHERE CustomerID = 1;
/*4 Get order details (including products):*/
SELECT o.OrderID, o.OrderDate, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;
/*5 Calculate total order amount:*/
SELECT SUM(oi.Quantity * oi.Price) AS Total
FROM OrderItems oi
WHERE oi.OrderID = 1;
/*6 Find the most popular product category (most orders):*/
SELECT p.Category, COUNT(oi.ProductID) AS OrderCount
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY OrderCount DESC
LIMIT 1;
                     /* views*/
/*1. ProductDetails View:
This view combines product information with the number of times each product has been ordered.  This is useful for analyzing product popularity.  */
CREATE VIEW ProductDetails AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Description,
    p.Price,
    p.Category,
    p.ImageURL,
    COUNT(oi.ProductID) AS OrderCount  -- Number of times this product was ordered
FROM
    Products p
LEFT JOIN  -- Use LEFT JOIN to include products that haven't been ordered yet
    OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY
    p.ProductID, p.ProductName, p.Description, p.Price, p.Category, p.ImageURL;    
    
/*Query using the view:*/
SELECT * FROM ProductDetails ORDER BY OrderCount DESC; -- Shows products sorted by popularity

/*2. CustomerOrderDetails View:
This view shows all the details of customer orders, including the products ordered and their prices.*/
CREATE VIEW CustomerOrderDetails AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    oi.ProductID,
    p.ProductName,
    oi.Quantity,
    oi.Price,  -- Price at the time of order
    (oi.Quantity * oi.Price) AS ItemTotal -- Calculate the total for each item
FROM
    Customers c
JOIN
    Orders o ON c.CustomerID = o.CustomerID
JOIN
    OrderItems oi ON o.OrderID = oi.OrderID
JOIN
    Products p ON oi.ProductID = p.ProductID;
    /*Query using the view:*/
    SELECT * FROM CustomerOrderDetails WHERE CustomerID = 1; -- Shows all orders for customer 1
    
    /*3. OrderSummary View:
This view provides a summarized view of each order, including the total amount.*/
CREATE VIEW OrderSummary AS
SELECT
    o.OrderID,
    o.OrderDate,
    c.FirstName,
    c.LastName,
    SUM(oi.Quantity * oi.Price) AS TotalAmount  
FROM
    Orders o
JOIN
    Customers c ON o.CustomerID = c.CustomerID
JOIN
    OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY
    o.OrderID, o.OrderDate, c.FirstName, c.LastName;
    /* query using this view*/
    SELECT * FROM OrderSummary ORDER BY OrderDate DESC; 
    
    /*4. CategorySales View:
    This view calculates the total sales for each product category.*/
    CREATE VIEW CategorySales AS
SELECT
    p.Category,
    SUM(oi.Quantity * oi.Price) AS TotalSales
FROM
    Products p
JOIN
    OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY
    p.Category;
    /* query using this view*/
    SELECT * FROM CategorySales ORDER BY TotalSales DESC;  
    
    
    /*5. CustomerOrderHistory View:
    This view shows a simplified history of customer orders, just the order ID and date.*/
    CREATE VIEW CustomerOrderHistory AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate
FROM
    Customers c
JOIN
    Orders o ON c.CustomerID = o.CustomerID;
    /*query using this view*/
    SELECT * FROM CustomerOrderHistory WHERE LastName = 'Doe'; 
    
    
    