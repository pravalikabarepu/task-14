### Query-1 Total sales by customer
with OrderSales as (
select
     OrderID,
	 CustomerID,
    sum(Quantity * UnitPrice*(1-Discount)) as OrderTotal
from orders 
group by OrderID, CustomerID
)
select
     CustomerID,
     sum(OrderTotal) as TotalSales
from OrderSales
group by CustomerID
order By totalSales desc;

### Query-2 Top 10 products by sales
with ProductSales as (
select 
     ProductID,
	sum(Quantity * UnitPrice*(1-Discount)) as TotalSales
from orders 
group by ProductID
),
RankedProducts as (
select
    ProductID,
    TotalSales,
    RANK() OVER (order by TotalSales desc) as ProductRank
from ProductSales
)
select
	  ProductID,
       TotalSales,
       ProductRank
from RankedProducts rp 
where ProductRank <= 10
order by ProductRank;

### Query-3 Monthly sales trend
WITH MonthlySales AS (
    SELECT
        YEAR(
            COALESCE(
                STR_TO_DATE(OrderDate, '%Y-%m-%d'),
                STR_TO_DATE(OrderDate, '%m/%d/%Y'),
                STR_TO_DATE(OrderDate, '%d/%m/%Y')
            )
        ) AS SalesYear,

        MONTH(
            COALESCE(
                STR_TO_DATE(OrderDate, '%Y-%m-%d'),
                STR_TO_DATE(OrderDate, '%m/%d/%Y'),
                STR_TO_DATE(OrderDate, '%d/%m/%Y')
            )
        ) AS SalesMonth,

        SUM(Quantity * UnitPrice * (1 - Discount)) AS TotalSales

    FROM orders

    GROUP BY
        YEAR(
            COALESCE(
                STR_TO_DATE(OrderDate, '%Y-%m-%d'),
                STR_TO_DATE(OrderDate, '%m/%d/%Y'),
                STR_TO_DATE(OrderDate, '%d/%m/%Y')
            )
        ),
        MONTH(
            COALESCE(
                STR_TO_DATE(OrderDate, '%Y-%m-%d'),
                STR_TO_DATE(OrderDate, '%m/%d/%Y'),
                STR_TO_DATE(OrderDate, '%d/%m/%Y')
            )
        )
),

SalesGrowth AS (
    SELECT
        SalesYear,
        SalesMonth,
        TotalSales,

        LAG(TotalSales) OVER (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthSales

    FROM MonthlySales
)

SELECT
    SalesYear,
    SalesMonth,
    ROUND(TotalSales, 2) AS TotalSales,
    ROUND(PreviousMonthSales, 2) AS PreviousMonthSales,

    ROUND(
        (
            (TotalSales - PreviousMonthSales)
            / NULLIF(PreviousMonthSales, 0)
        ) * 100,
        2
    ) AS GrowthPercentage

FROM SalesGrowth

WHERE SalesYear IS NOT NULL
  AND SalesMonth IS NOT NULL
ORDER BY SalesYear, SalesMonth;

### Query-4 Sales by Category
SELECT
    c.`Category ID`,
    c.`Category Name`,
    ROUND(SUM(o.Quantity * o.UnitPrice * (1 - o.Discount)), 2) AS TotalSales
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
JOIN category c
    ON p.CategoryID = c.`Category ID`
GROUP BY
    c.`Category ID`,
    c.`Category Name`
ORDER BY
    TotalSales DESC;
 
 ### Query-5 Sales by Employee
SELECT
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    ROUND(SUM(
        o.Quantity * CAST(o.UnitPrice AS DECIMAL(10,2)) * (1 - o.Discount)
    ), 2) AS TotalSales
FROM orders o
JOIN employee e
    ON o.EmployeeID = e.EmployeeID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY
    TotalSales DESC;  
   
### Query-6 Sales by Product
SELECT
    p.ProductID,
    p.ProductName,
    ROUND(
        SUM(o.Quantity * CAST(o.UnitPrice AS DECIMAL(10,2)) * (1 - o.Discount)),
        2
    ) AS TotalSales
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY
    TotalSales DESC;
    
### Query-7 Quantity Sold by Product
SELECT
    p.ProductID,
    p.ProductName,
    SUM(o.Quantity) AS TotalQuantitySold
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY
    TotalQuantitySold DESC;

### Query-8 Products by Category
SELECT
    c.`Category ID`,
    c.`Category Name`,
    COUNT(p.ProductID) AS ProductCount
FROM category c
LEFT JOIN products p
    ON c.`Category ID` = p.CategoryID
GROUP BY
    c.`Category ID`,
    c.`Category Name`
ORDER BY
    ProductCount DESC;

### Query-9 Sales by Supplier
SELECT
    s.SupplierID,
    s.CompanyName,
    ROUND(
        SUM(o.Quantity * CAST(o.UnitPrice AS DECIMAL(10,2)) * (1 - o.Discount)),
        2
    ) AS TotalSales
FROM orders o
JOIN products p
    ON o.ProductID = p.ProductID
JOIN suppliers s
    ON p.SupplierID = s.SupplierID
GROUP BY
    s.SupplierID,
    s.CompanyName
ORDER BY
    TotalSales DESC;
    
### Query-10 Orders Handled by Employee
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    COUNT(o.OrderID) AS TotalOrders
FROM employee e
LEFT JOIN orders o
    ON e.EmployeeID = o.EmployeeID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY
    TotalOrders DESC;

