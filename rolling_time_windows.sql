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

SELECT * FROM retail_sales;


CREATE VIEW women_sales AS 
SELECT sales_month
	,kind_of_business
	,sales
FROM retail_sales
WHERE kind_of_business = "Women's clothing stores"
;


CREATE VIEW noisy_rolling AS 
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

CREATE VIEW smooth_rolling AS 
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