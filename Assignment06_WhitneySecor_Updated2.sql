--*************************************************************************--
-- Title: Assignment06
-- Author: WhitneySecor
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-08-17,WhitneySecor,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_WhitneySecor')
	 Begin 
	  Alter Database [Assignment06DB_WhitneySecor] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_WhitneySecor;
	 End
	Create Database Assignment06DB_WhitneySecor;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_WhitneySecor;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Table

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Select * From Categories 
-- Go
-- Select * From Products 
-- Go
-- Select * From Employees 
-- Go 
-- Select * From Inventories 
-- Go 
-- ** Answer Found: Class on August 11, DEMO - Views SQL and Pg. 8 & 9 of Module 6 Notes ** 

Create
View vCategories
With SchemaBinding
As
	Select CategoryID, CategoryName
	  From Dbo.Categories;
Go

Create 
View vProducts 
With SchemaBinding 
As 
	Select ProductID, ProductName, CategoryID, UnitPrice 
	  From Dbo.Products;
Go 

Create 
View vEmployees  
With SchemaBinding 
As 
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID 
	  From Dbo.Employees;
Go 

Create 
View vInventories  
With SchemaBinding 
As 
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] 
	  From Dbo.Inventories;
Go 

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Answer Found: ** Module 6 Notes, Page. 9 and YouTube video Part 1 **

Use Assignment06DB_WhitneySecor;
Deny Select On Categories to Public;
Deny Select On Products to Public; 
Deny Select On Employees to Public;
Deny Select On Inventories to Public; 
Go 

Use Assignment06DB_WhitneySecor;
Grant Select On vCategories to Public;
Grant Select On vProducts to Public; 
Grant Select On vEmployees to Public;
Grant Select On vInventories to Public; 
Go 

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Answer Found: ** Order By Views Examples, Creating Views Functions and Stored Procedures Part 1, and Order By Issues in Views and Functions **

Create
View vProductsByCategories 
As
	Select Top 100000 
	C.CategoryName, 
	P.ProductName,
	P.UnitPrice 
	From vCategories as C 
		Inner Join vProducts as P  
		On C.CategoryID = P.CategoryID
		Order By 1,2,3; 
Go
Select * From vProductsByCategories;
Go

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Answer Found: ** Order By Views Examples, Creating Views Functions and Stored Procedures Part 1, and Order By Issues in Views and Functions **

Create
View vInventoriesByProductsByDates  
As
	Select Top 100000 
	P.ProductName,
	I.InventoryDate,
	I.[Count] 
	From vProduct as P 
		Inner Join vInventories as I  
		On P.ProductID = I.ProductID
		Order By 2,1,3; 
Go


-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Answer Found: ** Order By Views Examples, Creating Views Functions and Stored Procedures Part 1, Order By Issues in Views and Functions, and Module 5 Assignment **

Create
View vInventoriesByEmployeesByDates  
As
	Select Top 100000 
	I.InventoryDate,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName 
	From vInventories as I 
		Inner Join vEmployees as E  
		On I.EmployeeID = E.EmployeeID
		Order By 1,2; 
Go

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Answer Found: ** Order By Views Examples, SQL Views YouTube Video, Step-By-Step Approach to Solving Any Data Science SQL Interview YouTube, and Module 5 Notes **

-- Select * From Inventory 
-- Select * From Employees 
-- Select * From Categories 

-- Create
-- View vInventoriesByProductsByDates -- Categories Instead 
-- As
--Select Top 100000 -- KEEP
-- P.ProductName, -- KEEP
-- I.InventoryDate, -- KEEP
-- I.[Count] -- KEEP
-- From vProduct as P -- CHANGE 
-- Inner Join vInventories as I -- CHANGE 
-- On P.ProductID = I.ProductID -- CHANGE 
-- Order By 2,1,3; -- Add one more 
-- Go

Create
View vInventoriesByProductsByCategories 
As
	Select Top 100000 
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count]
	From vInventories as I 
	Inner Join vEmployees as E 
	On I.EmployeeID = E.EmployeeID
	Inner Join vProducts as P 
	On I.ProductID = P.ProductID
	Inner Join vCategories as C 
	On P.CategoryID = C.CategoryID
Order By 1,2,3,4; 
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Answer Found: ** Order By Views Examples, SQL Views YouTube Video, Step-By-Step Approach to Solving Any Data Science SQL Interview YouTube, and Module 5 Notes **

-- Create
-- View vInventoriesByEmployeesByDates  -- I By P By E 
-- As
-- Select Top 100000 
-- I.InventoryDate, -- KEEP 
-- E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName -- KEEP 
-- From vInventories as I -- KEEP 
-- Inner Join vEmployees as E  -- DELETE 
-- On I.EmployeeID = E.EmployeeID -- KEEP 
-- Order By 1,2; -- Add TWO more 
-- Go
-- ADD: CategoryName, ProductName, and Count 

Create
View vInventoriesByProductsByEmployees 
As
	Select Top 100000 
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count],
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName 
	From vInventories as I 
	Inner Join vEmployees as E 
	On I.EmployeeID = E.EmployeeID
	Inner Join vProducts as P 
	On I.ProductID = P.ProductID
	Inner Join vCategories as C 
	On P.CategoryID = C.CategoryID
Order By 3,1,2,4; 
Go


-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Answer Found: ** Order By Views Examples, SQL Views YouTube Video, Step-By-Step Approach to Solving Any Data Science SQL Interview YouTube, Question 7, and Module 5 Notes **
-- Create
-- View vInventoriesByProductsByEmployees 
-- As
-- Select Top 100000 
-- C.CategoryName,
-- P.ProductName,
-- I.InventoryDate,
-- I.[Count],
-- E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName 
-- From vInventories as I 
-- Inner Join vEmployees as E 
-- On I.EmployeeID = E.EmployeeID
-- Inner Join vProducts as P 
-- On I.ProductID = P.ProductID
-- Inner Join vCategories as C 
-- On P.CategoryID = C.CategoryID
-- Order By 3,1,2,4; 
-- Go
-- --> Add WHERE Clause with SubQuery 


Create
View vInventoriesForChaiAndChangByEmployees
As
	Select Top 100000 
	C.CategoryName,
	P.ProductName,
	I.InventoryDate,
	I.[Count],
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName 
	From vInventories as I 
	Inner Join vEmployees as E 
	On I.EmployeeID = E.EmployeeID
	Inner Join vProducts as P 
	On I.ProductID = P.ProductID
	Inner Join vCategories as C 
	On P.CategoryID = C.CategoryID
	Where I.ProductID in (Select ProductID from Products Where ProductName in ('Chai', 'Chang'))
Order By 3,1,2,4; 
Go

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Answer Found: ** Order By Views Examples, SQL Views YouTube Video, Step-By-Step Approach to Solving Any Data Science SQL Interview YouTube, and Module 5 Assignment **

Create 
View vEmployeesByManager
As 
	Select Top 10000 
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager,
	E.EmployeeFirstName + '' + E.EmployeeLastName as Employee
	From vEmployees as E 
	Inner Join vEmployees As M 
	On E.ManagerID = M.EmployeeId 
	Order By 1,2 
Go 

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Answer Found: ** Order By Views Examples, SQL Views YouTube Video, Step-By-Step Approach to Solving Any Data Science SQL Interview YouTube, Module 5 notes **

-- Select * From vCategories
-- Select * From vProducts 
-- Select * From vEmployees  
-- Select * From vInventories  
-- Select * View vEmployeesByManager

-- Create
-- View vInventoriesByProductsByEmployees -- vI By P By C By E 
-- As
-- Select Top 100000 -- KEEP 
-- C.CategoryName, -- KEEP, add Name 
-- P.ProductName, -- KEEP, add ID and Price 
-- I.InventoryDate, -- KEEP
-- I.[Count], -- KEEP
-- E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName -- KEEP 

-- Category, Product, InventoryID, and Employee



Create 
View vInventoriesByProductsByCategoriesByEmployees
As 
	Select Top 10000 
	C.CategoryID,
	C.CategoryName,
	P.ProductId,
	P.ProductName, 
	P.UnitPrice, 
	I.InventoryDate,
	I.[Count],
	E.EmployeeId,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee,
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager 
	From vCategories as C 
	Inner Join vProducts as P 
	On P.CategoryID = C.CategoryID
	Inner Join vInventories as I 
	On P.ProductID = I.ProductID
	Inner Join vEmployees as E 
	On E.ManagerID = M.EmployeeId 
	Order By 1,3,6,9  
Go 



-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/