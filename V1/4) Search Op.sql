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
    ADDING SEARCH OPTIMIZATION TO COREBANKING.FULL_CUSTOMER
    - Objective: Improve query performance on specific columns in the FULL_CUSTOMER table.
    - Search optimization is added for equality searches on CUSTOMER_ID and TRANSACTION_ID 
      to expedite lookups and enhance query efficiency.
*/
ALTER TABLE COREBANKING.FULL_CUSTOMER ADD SEARCH OPTIMIZATION ON EQUALITY(CUSTOMER_ID);














/*#########################################################
###########################################################
###########################################################
    EXAMPLE OF ADDING & REMOVING SEARCH OPTIMIZATION
    - Since the table is clustered on CUSTOMER_ID, search optimization for this column 
      may be redundant and can be removed to streamline the table structure.
*/
ALTER TABLE COREBANKING.FULL_CUSTOMER ADD SEARCH OPTIMIZATION ON EQUALITY(TRANSACTION_ID);
ALTER TABLE COREBANKING.FULL_CUSTOMER DROP SEARCH OPTIMIZATION ON EQUALITY(CUSTOMER_ID);
DESCRIBE SEARCH OPTIMIZATION ON COREBANKING.FULL_CUSTOMER;

-- Query to count the total number of records in the FULL_CUSTOMER table
SELECT COUNT(*) FROM COREBANKING.FULL_CUSTOMER;

-- Example queries to retrieve specific customer and transaction records
-- Note: Query on CUSTOMER_ID utilizes clustering, not search optimization
SELECT * FROM COREBANKING.FULL_CUSTOMER WHERE CUSTOMER_ID = '402000'; 

-- Note: Query on TRANSACTION_ID will utilize search optimization
SELECT * FROM COREBANKING.FULL_CUSTOMER WHERE TRANSACTION_ID = '110546'; 













/*#########################################################
###########################################################
###########################################################
    ADDING SEARCH OPTIMIZATION TO RISKANALYSIS.FULL_RISK
    - Objective: Enhance performance for queries on the FULL_RISK table by 
      adding search optimization on CREDIT_CARD_ID and LOAN_ID columns.
    - This will improve the efficiency of lookups on these key columns.

ALTER SESSION SET USE_CACHED_RESULT = FALSE;

*/
ALTER TABLE RISKANALYSIS.FULL_RISK ADD SEARCH OPTIMIZATION ON EQUALITY(MERCHANT);
ALTER TABLE RISKANALYSIS.FULL_RISK ADD SEARCH OPTIMIZATION ON EQUALITY(CATEGORY);
DESCRIBE SEARCH OPTIMIZATION ON RISKANALYSIS.FULL_RISK;

-- Example query to retrieve specific loan information using search optimization
SELECT *
FROM RISKANALYSIS.FULL_RISK
WHERE MERCHANT = 'Butler PLC';
