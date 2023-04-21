
use projects_r;


CREATE TABLE customer_nodes(
   customer_id INTEGER  NOT NULL 
  ,region_id   INTEGER  NOT NULL
  ,node_id     INTEGER  NOT NULL
  ,start_date  VARCHAR(24) NOT NULL
  ,end_date    VARCHAR(24) NOT NULL
);


select * from customer_nodes;


CREATE TABLE customer_transactions(
   customer_id INTEGER  NOT NULL 
  ,txn_date    VARCHAR(24) NOT NULL
  ,txn_type    VARCHAR(10) NOT NULL
  ,txn_amount  INTEGER  NOT NULL
);

select * from customer_transactions;

CREATE TABLE regions(
   region_id   INTEGER  NOT NULL 
  ,region_name VARCHAR(9) NOT NULL
);

select * from regions;
select * from customer_transactions;
select * from customer_nodes;
-----------------------------------------------------------------------------------------------------


##Q1 	How many different nodes make up the Data Bank network?
SELECT count(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;
----------------------------------------------------------------------
## 2.	How many nodes are there in each region?
SELECT r.region_id,
       r.region_name,
       count(node_id) AS node_count
FROM customer_nodes as c
INNER JOIN regions as r
on c. region_id = r.region_id 
GROUP BY region_id;
------------------------------------------------------------------------------------------------------------
## 3.	How many customers are divided among the regions?
SELECT r.region_id,
       r.region_name,
       count(DISTINCT customer_id) AS customer_count
FROM customer_nodes as c
INNER JOIN regions  as r
on c. region_id = r.region_id 
GROUP BY region_id;
----------------------------------------------------------------------------------------------------
## 4.	Determine the total amount of transactions for each region name.
select region_name, sum(txn_amount) as 'total transaction amount' from regions,customer_nodes,customer_transactions 
where regions.region_id=customer_nodes.region_id and customer_nodes.customer_id=customer_transactions.customer_id 
group by region_name;
------------------------------------------------------------------------------------------------------
## 5.	How long does it take on an average to move clients to a new node?
SELECT round(avg(datediff(end_date, start_date)), 2) AS avg_days
FROM customer_nodes
WHERE end_date!='9999-12-31';
-----------------------------------------------------------------------------------------------
## 6.	What is the unique count and total amount for each transaction type?

SELECT txn_type,
       count(*) AS unique_count,
       sum(txn_amount) AS total_amont
FROM customer_transactions
GROUP BY txn_type;

---------------------------------------------------------------------------------------------------------
## 7.	What is the average number and size of past deposits across all customers?
SELECT round(count(customer_id)/
               (SELECT count(DISTINCT customer_id)
                FROM customer_transactions)) AS average_deposit_count,
       concat('$', round(avg(txn_amount), 2)) AS average_deposit_amount
FROM customer_transactions
WHERE txn_type = "deposit";
-------------------------------------------------------------------------------------------------------------------
## 8.	For each month - how many Data Bank customers make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?

WITH transaction_count_per_month_cte AS
  (SELECT customer_id,
          month(txn_date) AS txn_month,
          SUM(IF(txn_type="deposit", 1, 0)) AS deposit_count,
          SUM(IF(txn_type="withdrawal", 1, 0)) AS withdrawal_count,
          SUM(IF(txn_type="purchase", 1, 0)) AS purchase_count
   FROM customer_transactions
   GROUP BY customer_id,
            month(txn_date))
SELECT txn_month,
       count(DISTINCT customer_id) as customer_count
FROM transaction_count_per_month_cte
WHERE deposit_count>1
  AND (purchase_count = 1
       OR withdrawal_count = 1)
GROUP BY txn_month;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------








