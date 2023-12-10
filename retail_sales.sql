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

SELECT -- This Query is noisy
	sales_month
    , kind_of_business
    , sales
FROM retail_sales
WHERE kind_of_business IN ( -- in SQL Server 'Men''s clothing stores'
	"Men's clothing stores",
    "Women's clothing stores"
    )
;

SELECT -- with a smooth pattern
	EXTRACT(YEAR FROM sales_month) AS "Sales_Year"
    , kind_of_business
    , SUM(sales) AS "Sales"
FROM retail_sales
WHERE kind_of_business IN (
				"Men's clothing stores",
				"Women's clothing stores"
    )
GROUP BY 1, 2
;



SELECT SALES_YEAR
	, Womens_Sales - Mens_Sales AS Womens_Minus_Mens
    , Mens_Sales - Womens_Sales AS Mens_Minus_Womens
FROM (
	SELECT 
		EXTRACT(YEAR FROM sales_month) AS "SALES_YEAR"
		, SUM(
			CASE 
				WHEN kind_of_business = "Women's clothing stores" 
				THEN sales
			END) AS Womens_Sales
		, SUM(
			CASE
				WHEN kind_of_business = "Men's clothing stores"
				THEN sales
			END) AS Mens_Sales
	FROM retail_sales
	WHERE kind_of_business IN (
		"Women's clothing stores",
		"Men's clothing stores"
		) 
        AND sales_month >= "2015-12-01"
	GROUP BY 1
) a 
;



/* we can calculate the gap between the two categories, 
the ratio, and the percent difference between them.*/

SELECT 
	EXTRACT(YEAR FROM sales_month) AS "SALES_YEAR"
    , SUM(
		CASE 
			WHEN kind_of_business = "Women's clothing stores" 
            THEN sales
        END) AS Womens_Sales
	, SUM(
		CASE
			WHEN kind_of_business = "Men's clothing stores"
            THEN sales
		END) AS Mens_Sales
FROM retail_sales
WHERE kind_of_business IN (
	"Women's clothing stores",
    "Men's clothing stores"
    )
GROUP BY 1
;