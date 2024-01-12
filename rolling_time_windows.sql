USE estudos;

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    sales_month	VARCHAR(100),
    naics_code	VARCHAR(100),
    kind_of_business VARCHAR(100),
    reason_for_null	VARCHAR(100),
    sales VARCHAR(100)
);

SELECT * FROM retail_sales;

-- Calculating Cumulative Values

SELECT sales_month, sales
	,sum(sales) OVER (PARTITION BY EXTRACT(YEAR FROM sales_month)
						ORDER BY sales_month
					 ) AS sales_ytd
FROM retail_sales
WHERE kind_of_business = 'Women''s clothing stores'
;

SELECT 1873 + 1991 AS 'ACUMULATIVE SUM';

-- Analyzing with Seasonality
-- Seasonality is any pattern that repeats over regular intervals. But seasonality can be predicted.
-- Dealing with seasonality: smooth it out // to benchmark against similar time periods and analyze the difference

-- Period-over-Period Comparisons: YoY and MoM

-- the lag function returns the previous or lagging value from a series.
SELECT kind_of_business, sales_month, sales
	,lag(sales_month) over (partition by kind_of_business
							order by sales_month
							) as prev_month
	,lag(sales) over (partition by kind_of_business
					  order by sales_month
					  ) as prev_month_sales
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;

SELECT kind_of_business, sales_month, sales
	,(sales / lag(sales) over (partition by kind_of_business
								order by sales_month) - 1) * 100 as pct_growth_from_previous
FROM retail_sales
WHERE kind_of_business = 'Book stores'
;

SELECT sales_year, yearly_sales
	, LAG(YEARLY_SALES) OVER (ORDER BY sales_year) as PREV_YEAR_SALES
    , (YEARLY_SALES / LAG(yearly_sales) OVER (ORDER BY SALES_YEAR) - 1) * 100 AS PCT_GROWTH_FROM_PREVIOUS
FROM (
        -- estamos somando as vendas de cada ano
		SELECT EXTRACT(YEAR FROM sales_month) AS SALES_YEAR
			 , SUM(sales) AS YEARLY_SALES
		FROM retail_sales
		WHERE kind_of_business = "Book stores"
		GROUP BY 1
) a 
;

-- How to use SQL to compare current values to the values for the same month in the previous year
-- Period-over-Period Comparisons

SELECT sales_month
	  , EXTRACT(MONTH FROM sales_month) AS `MONTH`
FROM retail_sales
WHERE kind_of_business = "Book stores"
;

SELECT sales_month, sales
	  , LAG(sales_month) OVER (PARTITION BY EXTRACT(MONTH FROM sales_month) ORDER BY sales_month ) AS `PREV_YEAR_MONTH`
      , LAG(sales) OVER (PARTITION BY EXTRACT(MONTH FROM sales_month) ORDER BY sales_month ) AS `PREV_YEAR_SALES`
FROM retail_sales
WHERE kind_of_business = "Book stores"
;

-- calculate comparison metrics such as absolute difference and percent change from previous

SELECT sales_month, sales
	, sales - LAG(sales) OVER (PARTITION BY EXTRACT(MONTH FROM sales_month) ORDER BY sales_month) AS `ABSOLUTE_DIFF`
    , (sales / LAG(sales) OVER (PARTITION BY EXTRACT(MONTH FROM sales_month) ORDER BY sales_month) - 1 ) * 100 AS `PCT_DIFF`
FROM retail_sales
WHERE kind_of_business = "Book stores"
;

SELECT EXTRACT(MONTH FROM sales_month) AS MONTH_NUMBER
	  , CONVERT(sales_month USING utf8mb4)
FROM retail_sales
;

SELECT EXTRACT(MONTH FROM sales_month) as month_number
	, MONTHNAME(sales_month) AS month_name
    -- max de vendas de cada ano
	, max(case when EXTRACT(YEAR FROM sales_month) = 1992 then sales end) as sales_1992
	, max(case when EXTRACT(YEAR FROM sales_month) = 1993 then sales end) as sales_1993
	, max(case when EXTRACT(YEAR FROM sales_month) = 1994 then sales end) as sales_1994
    FROM retail_sales
WHERE kind_of_business = 'Book stores' and sales_month between '1992-01-01' and '1994-12-01'
GROUP BY 1,2
;

/*
SELECT EXTRACT(MONTH FROM sales_month) as month_number
	, MONTHNAME(sales_month) AS month_name
    , max(case when EXTRACT(YEAR FROM sales_month) = 2018 then sales end) as sales_2018
    , max(case when EXTRACT(YEAR FROM sales_month) = 2019 then sales end) as sales_2019
    , max(case when EXTRACT(YEAR FROM sales_month) = 2020 then sales end) as sales_2020
FROM retail_sales
WHERE kind_of_business = 'Book stores' and sales_month between '2018-01-01' and '2020-12-01'
GROUP BY 1,2
;
*/

-- add a new column
ALTER TABLE retail_sales
	ADD COLUMN sales_month2 DATE;
-- populando com os dados da coluna antiga
UPDATE retail_sales
	SET sales_month2 = STR_TO_DATE(sales_month, '%d-%m-%Y');
-- retirando a coluna original
ALTER TABLE retail_sales
	DROP COLUMN sales_month;
-- renomeando a coluna
ALTER TABLE retail_sales
	CHANGE COLUMN sales_month2 sales_month DATE;
-- alterando a ordem das colunas
ALTER TABLE retail_sales
MODIFY COLUMN naics_code VARCHAR(100)
AFTER sales_month
;


CREATE VIEW women_sales AS 
SELECT sales_month
	,kind_of_business
	,sales
FROM retail_sales
WHERE kind_of_business = "Women's clothing stores"
;


SELECT a.sales_month ,a.sales
	 , b.sales_month AS ROLLING_SALES_MONTH
     , b.sales AS ROLLING_SALES
FROM retail_sales a
	JOIN retail_sales b
		ON a.kind_of_business = b.kind_of_business
			AND b.sales_month BETWEEN a.sales_month - INTERVAL 11 MONTH
            AND a.sales_month
            AND b.kind_of_business = "Women's clothing stores"
	WHERE a.kind_of_business = "Women's clothing stores"
		AND a.sales_month = "2019-12-01"
;

SELECT a.sales_month, a.sales, AVG(b.sales) AS MOVING_SALES, COUNT(b.sales) AS RECORDS_COUNT
FROM retail_sales a
	JOIN retail_sales b 
		ON a.kind_of_business = b.kind_of_business
			AND b.sales_month BETWEEN a.sales_month - INTERVAL 11 MONTH
            AND a.sales_month 
            AND b.kind_of_business = "Women's clothing stores"
	WHERE a.kind_of_business = "Women's clothing stores"
		AND a.sales_month >= "1993-01-01"
GROUP BY 1,2
;

-- podemos recalcular a moving_avg com menos linhas de código
/* the window orders the sales by month (ascending) to ensure that the
window records are in chronological order */
SELECT sales_month
	, AVG(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS MOVING_AVG
    , COUNT(sales) OVER (ORDER BY sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS RECORDS_COUNT
FROM retail_sales
WHERE kind_of_business = "Women's clothing stores"
;
