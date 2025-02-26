/*#########################################################
    SET THE CONTEXT
    - Switch to the appropriate role, database, and warehouse.
    - Ensure you are operating in the correct environment for executing queries.
*/
USE ROLE <YOUR ROLE>;
USE DATABASE <YOUR DATABASE>;
USE WAREHOUSE <YOUR WAREHOUSE>;










/*#########################################################
###########################################################
###########################################################
    SETTING CLUSTER KEY
    - Objective: Improve query performance by setting a cluster key on the table.
    - This command sets the cluster key for the TRANSACTIONS table in the Core Banking schema.
    - Clustering by TRANSACTION_DATE and ACCOUNT_ID helps optimize query performance, 
      particularly for queries filtering on these columns.
*/
ALTER TABLE COREBANKING.TRANSACTIONS
    CLUSTER BY (TRANSACTION_DATE, ACCOUNT_ID);












    
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
    -- and database_name = 'MS_FINSIGHTS_1'
GROUP BY 
    date, database_name, schema_name, table_name
ORDER BY 
    credits_used DESC;
