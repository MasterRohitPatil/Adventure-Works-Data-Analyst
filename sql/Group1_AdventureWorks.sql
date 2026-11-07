CREATE DATABASE AdventureWorks;
USE AdventureWorks;

SELECT *
FROM FactInternetSales
LIMIT 10;

SELECT *
FROM dimProduct
LIMIT 10;

SELECT *
FROM dimCustomer
LIMIT 10;

DESCRIBE FactInternetSales;
DESCRIBE FactInternetSalesNew;

DESCRIBE dimproduct;
DESCRIBE dimcustomer;

ALTER TABLE dimcustomer
CHANGE COLUMN `ï»¿CustomerKey` CustomerKey INT;

SELECT COUNT(*) FROM FactInternetSales;
SELECT COUNT(*) FROM fact_internet_sales_new;


-- Q 0. Union of Fact Internet sales and Fact internet sales new

CREATE TABLE Sales AS
SELECT * FROM FactInternetSales
UNION ALL
SELECT * FROM fact_internet_sales_new;

SELECT COUNT(*) FROM Sales;


-- Q 1.Lookup the productname from the Product sheet to Sales sheet.

UPDATE Sales s
JOIN dimproduct p
ON s.ProductKey = p.ProductKey
SET s.ProductName = p.EnglishProductName;

SELECT COUNT(*) FROM Sales;

SELECT COUNT(*) FROM dimproduct;
SHOW INDEX FROM Sales;

SHOW INDEX FROM dimproduct;

ALTER TABLE dimproduct
ADD PRIMARY KEY (ProductKey);

CREATE INDEX idx_sales_productkey
ON Sales(ProductKey);

UPDATE Sales s
JOIN dimproduct p
ON s.ProductKey = p.ProductKey
SET s.ProductName = p.EnglishProductName;

SELECT ProductKey, ProductName
FROM Sales
LIMIT 10;

SELECT
    COUNT(*) AS TotalRows,
    COUNT(ProductName) AS ProductNamesFilled
FROM Sales;

-- Q2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.

ALTER TABLE Sales
ADD COLUMN CustomerFullName VARCHAR(255),
ADD COLUMN LookupUnitPrice DECIMAL(10,2);

DROP TABLE IF EXISTS DimCustomer;

SELECT 1;

SELECT COUNT(*)
FROM DimCustomer;

ALTER TABLE DimCustomer
ADD PRIMARY KEY (CustomerKey);

CREATE INDEX idx_sales_customerkey
ON Sales(CustomerKey);

UPDATE Sales s
JOIN DimCustomer c
ON s.CustomerKey = c.CustomerKey
SET s.CustomerFullName = CONCAT_WS(' ', c.FirstName, c.LastName);

SELECT CustomerKey, CustomerFullName
FROM Sales
LIMIT 10;

UPDATE Sales s
JOIN dimproduct p
ON s.ProductKey = p.ProductKey
SET s.LookupUnitPrice = p.`Unit price`;

SELECT
    ProductKey,
    UnitPrice,
    LookupUnitPrice
FROM Sales
LIMIT 10;

-- Q3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)

SELECT OrderDateKey
FROM Sales
LIMIT 10;

ALTER TABLE Sales
ADD COLUMN OrderDate DATE;

SELECT OrderDateKey, OrderDate
FROM Sales
LIMIT 10;

ALTER TABLE Sales
ADD COLUMN OrderDate_Date DATE;

UPDATE Sales
SET OrderDate_Date = STR_TO_DATE(CAST(OrderDateKey AS CHAR), '%Y%m%d');

SELECT OrderDateKey, OrderDate_Date
FROM Sales
LIMIT 10;

ALTER TABLE Sales
ADD COLUMN Year INT,
ADD COLUMN MonthNo INT,
ADD COLUMN MonthFullName VARCHAR(20),
ADD COLUMN QuarterName VARCHAR(2),
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN WeekdayNo INT,
ADD COLUMN WeekdayName VARCHAR(20),
ADD COLUMN FinancialMonth INT,
ADD COLUMN FinancialQuarter VARCHAR(2);

UPDATE Sales
SET
    Year = YEAR(OrderDate_Date),
    MonthNo = MONTH(OrderDate_Date),
    MonthFullName = MONTHNAME(OrderDate_Date),
    QuarterName = CONCAT('Q', QUARTER(OrderDate_Date)),
    YearMonth = DATE_FORMAT(OrderDate_Date, '%Y-%b'),

    
    WeekdayNo = WEEKDAY(OrderDate_Date) + 1,
    WeekdayName = DAYNAME(OrderDate_Date),

   
    FinancialMonth = CASE
        WHEN MONTH(OrderDate_Date) >= 4 THEN MONTH(OrderDate_Date) - 3
        ELSE MONTH(OrderDate_Date) + 9
    END,

    FinancialQuarter = CASE
        WHEN MONTH(OrderDate_Date) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(OrderDate_Date) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(OrderDate_Date) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END;
    
    SELECT
    OrderDate_Date,
    Year,
    MonthNo,
    MonthFullName,
    QuarterName,
    YearMonth,
    WeekdayNo,
    WeekdayName,
    FinancialMonth,
    FinancialQuarter
FROM Sales
LIMIT 10;


-- Q4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)

UPDATE Sales
SET SalesAmount_Calc =
    UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct);
    
    SELECT
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    
   
    SalesAmount_Calc,
    
  
    ROUND(UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct), 2) AS Expected_Value
    
FROM Sales
LIMIT 10;

-- Q5. Calculate Production Cost

ALTER TABLE Sales
ADD COLUMN ProductionCost DECIMAL(12,2);

UPDATE Sales
SET ProductionCost =
    ProductStandardCost * OrderQuantity;
    
    SELECT
    ProductStandardCost,
    OrderQuantity,
    
    -- Your column
    ProductionCost,
    
    -- Expected value
    ROUND(ProductStandardCost * OrderQuantity, 2) AS Expected_Value

FROM Sales
LIMIT 10;

-- Q6. Calculate Profit

ALTER TABLE Sales
ADD COLUMN Profit DECIMAL(12,2);

UPDATE Sales
SET Profit =
    SalesAmount_Calc - ProductionCost;
    
    SELECT
    UnitPrice,
    OrderQuantity,
    UnitPriceDiscountPct,
    SalesAmount_Calc,
    ProductStandardCost,
    ProductionCost,
    Profit
FROM Sales
LIMIT 10;

SELECT
    SalesAmount_Calc,
    ProductionCost,
    Profit,
    ROUND(SalesAmount_Calc - ProductionCost, 2) AS Expected_Profit
FROM Sales
LIMIT 10;







