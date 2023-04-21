create database projects_r;

use projects_r;


 ----------------------------------------------------------
 CREATE TABLE product_details(
  product_id    VARCHAR(6) NOT NULL PRIMARY KEY,
  price         INTEGER  NOT NULL,
  product_name  VARCHAR(32) NOT NULL,
  category_id   INTEGER  NOT NULL,
  segment_id    INTEGER  NOT NULL,
  style_id      INTEGER  NOT NULL,
  category_name VARCHAR(6) NOT NULL,
  segment_name  VARCHAR(6) NOT NULL,
  style_name    VARCHAR(19) NOT NULL
);
drop table product_details;

select * from product_details;

-------------------------------------------------------------------------------

CREATE TABLE product_hierarchy(
   id         INTEGER  NOT NULL PRIMARY KEY, 
  parent_id  INTEGER ,
  level_text VARCHAR(19) NOT NULL,
  level_name VARCHAR(8) NOT NULL
);
drop table  product_hierarchy;

select * from product_hierarchy;


-----------------------------------------------------------------------------------------

CREATE TABLE product_prices(
   id         INTEGER  NOT NULL PRIMARY KEY 
  ,product_id VARCHAR(6) NOT NULL
  ,price      INTEGER  NOT NULL
);
drop table  product_prices;

select * from product_prices;


--------------------------------------------------------------------------------------------

CREATE TABLE sales(
   prod_id        VARCHAR(6) NOT NULL 
  ,qty            INTEGER  NOT NULL
  ,price          INTEGER  NOT NULL
  ,discount       INTEGER  NOT NULL
  ,member         VARCHAR(5) NOT NULL
  ,txn_id         VARCHAR(6) NOT NULL
  ,start_txn_time VARCHAR(24) NOT NULL
);
drop table sales;

select * from sales;
select * from product_prices;
select * from product_details;
select * from product_hierarchy;


--------------------------------------------------------------------------

##1.	What was the total quantity sold for all products?

SELECT  pd.product_name, SUM(s.qty) AS total_sale_counts
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_sale_counts DESC;

---------------------------------------------------------------------------------------------------------------------
## 2.	What is the total generated revenue for all products before discounts?

SELECT  SUM(price * qty) AS revenue_before_discount
FROM sales ;

------------------------------------------------------------------------------------------------------------------------
## 3.	What was the total discount amount for all products?

SELECT 
	SUM(price * qty * discount)/100 AS total_discount
FROM sales;

---------------------------------------------------------------------------------------------------------------------------------------------------
##4.	How many unique transactions were there?

SELECT COUNT(DISTINCT txn_id) AS unique_txn
FROM sales;

-------------------------------------------------------------------------------------------------------------------------------------------------
## 5.	What are the average unique products purchased in each transaction?

WITH cte_transaction_products AS (
	SELECT
		txn_id,
		COUNT(DISTINCT prod_id) AS product_count
	FROM sales
	GROUP BY txn_id
)
SELECT
	ROUND(AVG(product_count)) AS avg_unique_products
FROM cte_transaction_products;

------------------------------------------------------------------------------------------------------------------------------------------
## 6.	What is the average discount value per transaction?

WITH cte_transaction_discounts AS (
	SELECT
		txn_id,
		SUM(price * qty * discount)/100 AS total_discount
	FROM sales
	GROUP BY txn_id
)
SELECT
	ROUND(AVG(total_discount)) AS avg_unique_products
FROM cte_transaction_discounts;

-----------------------------------------------------------------------------------------------------------------------------------
## 7.	What is the average revenue for member transactions and non-member transactions?

WITH cte_member_revenue AS (
  SELECT
    member,
    txn_id,
    SUM(price * qty) AS revenue
  FROM sales
  GROUP BY 
	member, 
	txn_id
)
SELECT
  member,
  ROUND(AVG(revenue), 2) AS avg_revenue
FROM cte_member_revenue
GROUP BY member;

------------------------------------------------------------------------------------------------------------
## 8.	What are the top 3 products by total revenue before discount?

SELECT 
	pd.product_name,
	SUM(s.qty * s.price) AS revenue_total
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY revenue_total DESC
LIMIT 3;

-----------------------------------------------------------------------------------------------------------
## 9.	What are the total quantity, revenue and discount for each segment?

SELECT 
	pd.segment_id,
	pd.segment_name,
	SUM(s.qty) AS total_quantity,
	SUM(s.qty * s.price) AS total_revenue,
	SUM(s.qty * s.price * s.discount)/100 AS total_discount
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY 
	pd.segment_id,
	pd.segment_name
ORDER BY total_revenue DESC;

------------------------------------------------------------------------------------------------------------------------------
## 10.	What is the top selling product for each segment?


SELECT 
	pd.segment_id,
	pd.segment_name,
	pd.product_id,
	pd.product_name,
	SUM(s.qty) AS product_quantity
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY
	pd.segment_id,
	pd.segment_name,
	pd.product_id,
	pd.product_name
ORDER BY product_quantity DESC
LIMIT 5;

--------------------------------------------------------------------------------------------------------------------------------------------------
## 11.	What are the total quantity, revenue and discount for each category?

SELECT 
	pd.category_id,
	pd.category_name,
	SUM(s.qty) AS total_quantity,
	SUM(s.qty * s.price) AS total_revenue,
	SUM(s.qty * s.price * s.discount)/100 AS total_discount
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY 
	pd.category_id,
	pd.category_name
ORDER BY total_revenue DESC;

----------------------------------------------------------------------------------------------------------------------------------------
## 12.	What is the top selling product for each category?

SELECT 
	pd.category_id,
	pd.category_name,
	pd.product_id,
	pd.product_name,
	SUM(s.qty) AS product_quantity
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY
	pd.category_id
ORDER BY product_quantity DESC
LIMIT 5;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------



