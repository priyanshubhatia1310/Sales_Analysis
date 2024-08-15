CREATE DATABASE CAPSTONE1;

USE capstone1;

-- Table 1 - SalesOrders = Orderdate,shipdate,unitprice, totalunit cost,total revenue
select * from sales_orders;	
describe sales_orders;

-- Table 2 - Customers
select * from Customers;
Describe Customers;

-- Table 3 - regions
select * from regions;
Describe regions;

-- Table 4 - products
select * from products;
describe products;

-- Data Cleaning & Transforming 
select * from sales_orders;
describe sales_orders;

-- Orderdate
UPDATE sales_orders
SET OrderDate = DATE_FORMAT(STR_TO_DATE(OrderDate, '%d-%m-%Y'), '%Y-%m-%d');

alter table sales_orders modify column OrderDate Date;

-- ship date
UPDATE sales_orders
SET Ship_Date = DATE_FORMAT(STR_TO_DATE(Ship_Date, '%d-%m-%Y'), '%Y-%m-%d');

ALTER TABLE sales_orders MODIFY COLUMN Ship_Date Date;

--  Unit Price
UPDATE Sales_orders
SET Unit_Price = REPLACE(Unit_Price, ',', '');

ALTER TABLE sales_orders MODIFY COLUMN Unit_Price float;

-- Total Unit cost
UPDATE Sales_orders
SET Total_Unit_Cost = REPLACE(Total_Unit_Cost, ',', '');

ALTER TABLE sales_orders MODIFY COLUMN  Total_Unit_Cost float;

-- Total Revenue
UPDATE Sales_orders
SET Total_Revenue = REPLACE(Total_Revenue, ',', '');

ALTER TABLE sales_orders MODIFY COLUMN Total_Revenue float;

-- A) KPI's requirements

-- Total Cost 
SELECT round(sum(Order_Quantity * Total_Unit_Cost),2) as Total_Cost from sales_orders;

-- Total Orders 
select count(distinct(OrderNumber)) as Total_Orders from sales_orders;

-- Average Order value
SELECT round(SUM(Total_Revenue) / COUNT(DISTINCT OrderNumber),2) AS Average_Order_Value FROM sales_orders;

-- Total Revenue 
select round(sum(Total_Revenue),2) as Total_Revenue from sales_orders;

-- Total Profit 
Select round(sum(Total_Revenue -(Order_Quantity * Total_Unit_Cost)),2) as Total_Profit from Sales_Orders;

-- Current Year Sales
WITH CurrentYearSales AS (SELECT COALESCE(round(SUM(Total_Revenue), 0),0) AS CY_Sales FROM sales_orders WHERE YEAR(OrderDate) = '2019'),
--  Previous Year Sales
PreviousYearSales AS (SELECT COALESCE(round(SUM(Total_Revenue), 0),0) AS PY_Sales FROM sales_orders WHERE year(OrderDate) = '2018')
-- YoY Percentage
SELECT CY_Sales,PY_Sales, round((CY_Sales - PY_Sales) / PY_Sales * 100,2) as YoY_Percentage FROM CurrentYearSales, PreviousYearSales;

-- Total Products Sold =done
Select sum(Order_Quantity) as Total_Products_Sold from sales_orders;

-- Avg Product Per Order
select Round(sum(Order_Quantity)/COUNT(DISTINCT OrderNumber),2) AS Avg_Product_per_Order from sales_orders;

-- B) Total Orders by warehouse code
SELECT s.Warehouse_Code, COUNT(s.OrderNumber) AS Total_Orders
FROM Sales_Orders s
GROUP BY s.Warehouse_Code
order by Total_Orders desc;

-- C) AVerage of Total Revenue by Month
SELECT  DATE_FORMAT(OrderDate, '%b') as Month, ROUND(AVG(Total_Revenue), 2) as Avg_Total_Revenue 
FROM sales_orders 
GROUP BY DATE_FORMAT(OrderDate, '%b'), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

-- D) Sum of Total Profit by city
SELECT r.city,round(sum(Total_Revenue -(Order_Quantity * Total_Unit_Cost)),2) AS Total_Profit FROM sales_orders AS s
INNER JOIN regions AS r 
ON s.Delivery_Region_Index= r.Index
GROUP BY r.city
ORDER BY Total_Profit  DESC;

-- E) Total Product Sold by Channel & Currency Code
SELECT Channel,currency_code,SUM(Order_Quantity) AS Total_Products_Sold FROM Sales_orders 
GROUP BY channel,currency_code
ORDER  BY Total_Products_Sold desc;

-- F) %Total Revenue by City
SELECT r.city,ROUND(SUM(s.Total_Revenue) * 100.0 / (SELECT SUM(Total_Revenue) FROM Sales_Orders), 2) AS Percentage_Revenue
FROM Sales_Orders AS s
INNER JOIN regions AS r	
ON s.Delivery_Region_Index = r.Index
GROUP BY r.city;

-- G) Avg of Total cost,Avg of Total Revenue by Product Name. 
SELECT p.Product_Name,ROUND(AVG(Total_Revenue),0) as Avg_Total_Revenue,ROUND(AVG(Order_Quantity * Total_Unit_Cost),0) AS Avg_Total_Cost 
FROM sales_orders AS s
INNER JOIN Products AS p
ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name
ORDER BY Avg_Total_Cost DESC;

-- H) Top 5 products by revenue
SELECT p.Product_Name, round(SUM(s.Total_Revenue),0) AS Total_Revenue
FROM Sales_Orders s
JOIN Products p ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name
ORDER BY Total_Revenue DESC
limit 5;

-- I) Bottom 5 products by revenue
SELECT p.Product_Name, ROUND(SUM(s.Total_Revenue),0) AS Total_Revenue
FROM Sales_Orders s
JOIN Products p ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name
ORDER BY Total_Revenue ASC
LIMIT 5;

-- J)Product Performance by Channel
SELECT p.Product_Name, s.Channel,SUM(s.Order_Quantity) AS Total_Products_Sold
FROM Sales_Orders s
INNER JOIN Products p ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name,s.Channel
ORDER BY Total_Products_Sold DESC;

-- K) Product Performance by currency code
SELECT p.Product_Name, s.currency_code, SUM(s.Order_Quantity) AS Total_Products_Sold
FROM Sales_Orders s
INNER JOIN Products p ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name,s.currency_code
ORDER BY Total_Products_Sold DESC;

-- L) Top 5 products by Total Orders
SELECT p.Product_Name,count(DISTINCT(OrderNumber)) AS Total_Orders FROM
sales_orders AS s
INNER JOIN products AS p
ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name
ORDER BY Total_Orders DESC
LIMIT 5;

-- M) Bottom 5 products by Total Orders
SELECT p.Product_Name,count(DISTINCT(OrderNumber)) AS Total_Orders FROM
sales_orders AS s
INNER JOIN products AS p
ON s.Product_Description_Index = p.Index
GROUP BY p.Product_Name
ORDER BY Total_Orders ASC
LIMIT 5;

-- N) CUSTOMER PURCHASE PATTERN
SELECT c.customer_Names,count(DISTINCT(OrderNumber)) AS Total_Orders , sum(Order_Quantity) AS Total_Products_Sold, 
ROUND(SUM(Total_Revenue -(Order_Quantity * Total_Unit_Cost)),0) AS Total_Profit
FROM sales_orders s 
INNER JOIN customers c
ON c.Customer_Index = s.Customer_Name_Index
GROUP BY c.customer_Names
ORDER BY Total_Profit DESC;

-- O) Top 10 Customers by total revenue
SELECT c.Customer_Names, round(SUM(s.Total_Revenue),0) AS Total_Revenue
FROM Sales_Orders s
INNER JOIN Customers c ON s.Customer_Name_Index= c.Customer_Index
GROUP BY c.Customer_Names
ORDER BY Total_Revenue DESC
Limit 10;

-- P) TOTal unit cost by customer
SELECT c.Customer_Names, ROUND(SUM(s.Total_Unit_Cost),2) AS Total_Unit_Cost
FROM Sales_Orders s
INNER JOIN Customers c ON s.Customer_Name_Index = c.Customer_Index
GROUP BY c.Customer_Names
ORDER BY Total_Unit_Cost DESC;

