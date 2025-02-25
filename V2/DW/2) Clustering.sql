/*#########################################################
    SET THE CONTEXT
    - Find and replace 'XXX' with your number
*/
USE ROLE MS_DBA_XXX;
USE DATABASE MS_FINSIGHTS_XXX;
USE WAREHOUSE MS_HOL_WH;


SELECT system$clustering_depth('MS_FINSIGHTS_27.COREBANKING.TRANSACTIONS','(TRANSACTION_DATE)');

SELECT TRANSACTION_DATE,
       COUNT(TRANSACTION_ID) AS TOTAL_TRANSACTIONS
FROM COREBANKING.TRANSACTIONS
WHERE TRANSACTION_DATE = '2023-11-01'
GROUP BY 1;

-- Let's look at the query profile




/*#########################################################
###########################################################
###########################################################
    SETTING CLUSTER KEY
    - Objective: Improve query performance by setting a cluster key on the table.
    - This command sets the cluster key for the TRANSACTIONS table in the Core Banking schema.
    - Clustering by TRANSACTION_DATE and ACCOUNT_ID helps optimize query performance, 
      particularly for queries filtering on these columns.
*/

ALTER TABLE COREBANKING.TRANSACTIONS CLUSTER BY (TRANSACTION_DATE);

---LET US CHECKOUT THE QUERY PROFILE

alter session set use_cached_result=false;
   
SELECT TRANSACTION_DATE,
       COUNT(TRANSACTION_ID) AS TOTAL_TRANSACTIONS
FROM COREBANKING.TRANSACTIONS
WHERE TRANSACTION_DATE = '2023-11-01'
GROUP BY 1;














    
/*#########################################################
###########################################################
###########################################################
    MONITORING AUTOMATIC CLUSTERING COSTS
    - Objective: Monitor the cost associated with automatic clustering.
    - Switch to the ACCOUNTADMIN role to access account usage data.
    - This query retrieves the amount of credits used for automatic clustering 
      over the last month, grouped by date, database, schema, and table.
    - The results are sorted by the total credits used in descending order 
      to identify the most expensive clustering operations.
*/

SELECT 
    TO_DATE(start_time) AS date,
    database_name,
    schema_name,
    table_name,
    SUM(credits_used) AS credits_used
FROM 
    snowflake.account_usage.automatic_clustering_history

WHERE 
    start_time >= DATEADD(month,-1,CURRENT_TIMESTAMP())
    -- and database_name = 'MS_FINSIGHTS_XXX'
GROUP BY 
    date, database_name, schema_name, table_name
ORDER BY 
    credits_used DESC;
