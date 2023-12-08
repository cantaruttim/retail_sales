use historical_sales;

-- create the table
DROP table if exists retail_sales;
CREATE table retail_sales (
	sales_month date,
	naics_code varchar(100),
    kind_of_business varchar(100),
    reason_for_null varchar(100),
	sales decimal
);

SELECT * FROM retail_sales;

-- Trending the Data
SELECT 
	sales_month
	, sales
from retail_sales
WHERE kind_of_business = 'Retail and food services sales, total' ;

/* This data clearly has some patterns, 
but it also has some noise. 
Transforming the data and aggregating at the yearly level can help 
us gain a better understanding.*/


/* now have a smoother time series that is
generally increasing over time, as might be expected, since the sales values are not
adjusted for inflation */

SELECT 
	EXTRACT(YEAR FROM sales_month) AS "SALES_YEAR",
    SUM(sales) AS "SALES"
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total' 
GROUP BY 1
;

SELECT 
	EXTRACT(MONTH FROM sales_month) AS "SALES_MONTH",
    SUM(sales) AS "SALES"
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total' 
GROUP BY 1
;

SELECT 
	EXTRACT(DAY FROM sales_month) AS "SALES_DAY",
    SUM(sales) AS "SALES"
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total' 
GROUP BY 1
;

-- Comparing Components
/* Let’s compare the yearly sales trend for a few categories that are
associated with leisure activities: book stores, sporting goods stores, and hobby stores.*/

SELECT 
	EXTRACT(YEAR FROM sales_month) AS "Sales_Year"
    , kind_of_business
    , SUM(sales) AS "Sales"
FROM retail_sales
WHERE kind_of_business IN (
				"Book stores", 
                "Sporting goods stores",
                "Hobby, toy, and game stores" 
				)
GROUP BY 1, 2
;