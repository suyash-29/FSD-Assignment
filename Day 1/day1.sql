
CREATE DATABASE BikeStores;
use BikeStores;
-- create schemas
CREATE SCHEMA production;
go

CREATE SCHEMA sales;
go

-- create tables
CREATE TABLE production.categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sales.customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.staffs (
	staff_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.orders (
	order_id INT IDENTITY (1, 1) PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);


--3 User-Defined Function to Calculate the Total Amount Based on ProductID and Quantity
CREATE FUNCTION CalculateTotalAmount
(
    @ProductID INT,
    @Quantity INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10, 2);

    -- Calculate the total amount based on product list price and quantity
    SELECT @TotalAmount = list_price * @Quantity
    FROM production.products
    WHERE product_id = @ProductID;

    RETURN @TotalAmount;
END;

SELECT dbo.CalculateTotalAmount(3, 5) AS TotalAmount;

--4 User-Defined Function to Get All Orders for a Specific Customer with Order Details
CREATE FUNCTION GetCustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.list_price * oi.quantity * (1 - oi.discount / 100)) AS TotalAmount
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY o.order_id, o.order_date
);

SELECT * FROM dbo.GetCustomerOrders(1);

--5 Multistatement Table-Valued Function
CREATE FUNCTION CalculateTotalSalesPerProduct()
RETURNS @ProductSales TABLE
(
    ProductID INT,
    ProductName VARCHAR(255),
    TotalSales DECIMAL(10, 2)
)
AS
BEGIN
    
    INSERT INTO @ProductSales (ProductID, ProductName, TotalSales)
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)) AS TotalSales
    FROM sales.order_items oi
    INNER JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name;

    RETURN;
END;

SELECT * FROM dbo.CalculateTotalSalesPerProduct();

--6 Multistatement Table-Valued Function
CREATE FUNCTION CalculateTotalSpentByCustomers()
RETURNS @CustomerSpending TABLE
(
    CustomerID INT,
    FullName VARCHAR(510),
    TotalSpent DECIMAL(10, 2)
)
AS
BEGIN
    -- Insert total spending data for each customer
    INSERT INTO @CustomerSpending (CustomerID, FullName, TotalSpent)
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS FullName,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount / 100)) AS TotalSpent
    FROM sales.customers c
    INNER JOIN sales.orders o ON c.customer_id = o.customer_id
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name;

    RETURN;
END;

SELECT * FROM dbo.CalculateTotalSpentByCustomers();

/* Question 1 and 2  
 CREATE TABLE Department with 
the below columns
ID,Name
populate with test data
CREATE TABLE Employee with
the below columns
ID,Name,Gender,DOB,Deptld
populate with test data */

CREATE DATABASE Practise
use Practise

CREATE TABLE Department (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO Department (ID, Name) 
VALUES 
(1, 'HR'),
(2, 'IT'),
(3, 'Finance');

CREATE TABLE Employee (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender CHAR(1),  -- M for Male, F for Female
    DOB DATE,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(ID)
);

INSERT INTO Employee (ID, Name, Gender, DOB, DeptID) 
VALUES 
(1, 'John Doe', 'M', '1985-06-15', 1),
(2, 'Jane Smith', 'F', '1990-11-22', 2),
(3, 'Sam Johnson', 'M', '1988-03-03', 3),
(4, 'Emily Brown', 'F', '1992-07-12', 1),
(5, 'Mike Wilson', 'M', '1983-08-25', 2);


-- procedure to update employee details
CREATE PROCEDURE UpdateEmployeeDetails
    @EmpID INT,
    @NewName VARCHAR(100),
    @NewGender CHAR(1),
    @NewDOB DATE,
    @NewDeptID INT
AS
BEGIN
    UPDATE Employee
    SET Name = @NewName, 
        Gender = @NewGender,
        DOB = @NewDOB,
        DeptID = @NewDeptID
    WHERE ID = @EmpID;
END;

-- procedure to get employee information by gender and department ID
CREATE PROCEDURE GetEmployeeInfoByGenderDept
    @Gender CHAR(1),
    @DeptID INT
AS
BEGIN
    SELECT * 
    FROM Employee
    WHERE Gender = @Gender
      AND DeptID = @DeptID;
END;

-- procedure to get employee count by gender
CREATE PROCEDURE GetEmployeeCountByGender
    @Gender CHAR(1)
AS
BEGIN
    SELECT COUNT(*) AS EmployeeCount
    FROM Employee
    WHERE Gender = @Gender;
END;

EXEC UpdateEmployeeDetails 
    @EmpID = 1, 
    @NewName = 'Johnathan Doe', 
    @NewGender = 'M', 
    @NewDOB = '1985-06-16', 
    @NewDeptID = 2;

EXEC UpdateEmployeeDetails 2, 'Suyash singh ', 'F','2003-12-12', 1;

SELECT * FROM Employee

EXEC GetEmployeeInfoByGenderDept 
    @Gender = 'F', 
    @DeptID = 1;

EXEC GetEmployeeInfoByGenderDept 'M' , 2 ;

EXEC GetEmployeeCountByGender 'M';






