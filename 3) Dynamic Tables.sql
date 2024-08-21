/*#########################################################
    SET THE CONTEXT
    - Switch to the appropriate role, database, and warehouse.
    - Ensure you are operating in the correct environment for executing queries.
*/

-- USE ROLE <YOUR ROLE>;
-- USE DATABASE <YOUR DATABASE>;
-- USE WAREHOUSE <YOUR WAREHOUSE>;


/*#########################################################
    CREATE NEW WAREHOUSE
    - BEST PRACTICE: Use an isolated for dynamic tables so resources are not contending
*/


create warehouse if not exists HOL_WH_XL_DT_<xx> warehouse_size='xlarge' min_cluster_count=1 max_cluster_count=5 auto_suspend=60 auto_resume=true INITIALLY_SUSPENDED=true;


/*#########################################################
    SETTING UP DYNAMIC TABLE - CC Summary
    - Objective: Create a dynamic table to summarize account and credit card data.
    - The table is set to refresh automatically every 5 minutes using the specified warehouse.
    - This dynamic table provides an aggregated view of account and credit card data, 
      including counts, average balances, and status information.
*/
CREATE OR REPLACE DYNAMIC TABLE COREBANKING.ACCOUNT_CREDIT_CARD_SUMMARY
    TARGET_LAG = '5 minutes'
    WAREHOUSE = HOL_WH_XL_DT_XX
    REFRESH_MODE = AUTO
    INITIALIZE = ON_CREATE
AS
SELECT 
    a.ACCOUNT_TYPE,
    COUNT(DISTINCT a.ACCOUNT_ID) AS TOTAL_ACCOUNTS,
    AVG(a.BALANCE) AS AVG_ACCOUNT_BALANCE,
    AVG(a.INTEREST_RATE) AS AVG_ACCOUNT_INTEREST_RATE,
    COUNT(CASE WHEN a.ACCOUNT_STATUS = 'Active' THEN 1 END) AS ACTIVE_ACCOUNTS,
    cc.CARD_TYPE,
    COUNT(DISTINCT cc.CREDIT_CARD_ID) AS TOTAL_CREDIT_CARDS,
    SUM(cc.CREDIT_LIMIT) AS TOTAL_CREDIT_LIMIT,
    SUM(cc.BALANCE) AS TOTAL_CREDIT_BALANCE,
    AVG(cc.BALANCE) AS AVG_CREDIT_BALANCE,
    COUNT(CASE WHEN cc.CARD_STATUS = 'Active' THEN 1 END) AS ACTIVE_CREDIT_CARDS
FROM 
    COREBANKING.ACCOUNTS a
LEFT JOIN 
    RISKANALYSIS.CREDIT_CARDS cc ON a.CUSTOMER_ID = cc.CUSTOMER_ID
GROUP BY 
    a.ACCOUNT_TYPE, cc.CARD_TYPE;









/*#########################################################
    SETTING UP DYNAMIC TABLE - Comprehensive Transaction Report
    - Objective: Create a dynamic table for a comprehensive transaction report.
    - This table clusters data by TRANSACTION_DATE and is set to refresh incrementally 
      every 5 minutes, ensuring only updated data is processed.
    - The report provides a detailed summary of transactions, including total transactions, 
      transaction amounts, unique customers, and top merchants.
*/
CREATE OR REPLACE DYNAMIC TABLE COREBANKING.TRANSACTION_REPORT
    TARGET_LAG = '5 minutes'
    WAREHOUSE = HOL_WH_XL_DT_XX
    CLUSTER BY (TRANSACTION_DATE)
    REFRESH_MODE = INCREMENTAL
    INITIALIZE = ON_CREATE
AS
WITH TransactionSummary AS (
    SELECT 
        t.TRANSACTION_ID,
        t.TRANSACTION_DATE,
        t.TRANSACTION_TYPE,
        t.MERCHANT,
        t.CATEGORY,
        t.TRANSACTION_AMOUNT,
        c.CUSTOMER_ID,
        c.FIRST_NAME,
        c.LAST_NAME,
        a.ACCOUNT_TYPE
    FROM 
        COREBANKING.TRANSACTIONS t
    JOIN 
        COREBANKING.ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID
    JOIN 
        COREBANKING.CUSTOMERS c ON a.CUSTOMER_ID = c.CUSTOMER_ID
)
SELECT 
    ts.TRANSACTION_DATE,
    COUNT(DISTINCT ts.TRANSACTION_ID) AS TOTAL_TRANSACTIONS,
    SUM(ts.TRANSACTION_AMOUNT) AS TOTAL_TRANSACTION_AMOUNT,
    AVG(ts.TRANSACTION_AMOUNT) AS AVG_TRANSACTION_AMOUNT,
    COUNT(DISTINCT ts.CUSTOMER_ID) AS UNIQUE_CUSTOMERS,
    ts.MERCHANT AS TOP_MERCHANT,
    SUM(ts.TRANSACTION_AMOUNT) AS MERCHANT_TOTAL_AMOUNT
FROM 
    TransactionSummary ts
GROUP BY 
    TRANSACTION_DATE, ts.MERCHANT
ORDER BY 
    TRANSACTION_DATE DESC, MERCHANT_TOTAL_AMOUNT DESC;







/*#########################################################
    Comprehensive Customer Financial Overview
    BIG TABLE JOIN
    - Objective: Create a dynamic table that provides a comprehensive view 
      of customer financial data.
    - This table joins data from multiple tables (customers, accounts, transactions, 
      credit cards, loans, fraud) to give an overall financial overview of each customer.
    - The table is clustered by CUSTOMER_ID and TRANSACTION_DATE and refreshes incrementally.
*/
CREATE OR REPLACE DYNAMIC TABLE COREBANKING.FULL_CUSTOMER
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = HOL_WH_XL_DT_XX
    CLUSTER BY (CUSTOMER_ID, TRANSACTION_DATE)
    REFRESH_MODE = INCREMENTAL
    INITIALIZE = ON_CREATE
AS
SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    c.LAST_NAME,
    c.EMAIL,
    c.PHONE_NUMBER,
    c.ADDRESS,
    c.CITY,
    c.STATE,
    c.ZIP_CODE,
    a.ACCOUNT_ID,
    a.ACCOUNT_TYPE,
    a.BALANCE AS ACCOUNT_BALANCE,
    a.INTEREST_RATE AS ACCOUNT_INTEREST_RATE,
    a.ACCOUNT_STATUS,
    t.TRANSACTION_ID,
    t.TRANSACTION_TYPE,
    t.TRANSACTION_AMOUNT,
    t.TRANSACTION_DATE,
    t.MERCHANT,
    t.CATEGORY
FROM 
    COREBANKING.CUSTOMERS c
LEFT OUTER JOIN 
    COREBANKING.ACCOUNTS a ON c.CUSTOMER_ID = a.CUSTOMER_ID
LEFT OUTER JOIN 
    COREBANKING.TRANSACTIONS t ON a.ACCOUNT_ID = t.ACCOUNT_ID;











/*#########################################################
    Comprehensive Customer Financial Overview - Risk Analysis
    - Objective: Create a dynamic table that combines customer data with 
      risk-related information, including fraud, credit cards, and loans.
    - This table is clustered by TRANSACTION_DATE and TRANSACTION_TYPE and refreshes incrementally.
    - It provides a comprehensive view of financial risk data associated with customers.
*/
CREATE OR REPLACE DYNAMIC TABLE RISKANALYSIS.FULL_RISK
    TARGET_LAG = '15 minutes'
    WAREHOUSE = HOL_WH_XL_DT
    CLUSTER BY (TRANSACTION_DATE, TRANSACTION_TYPE)
    REFRESH_MODE = INCREMENTAL
    INITIALIZE = ON_CREATE
AS
SELECT 
    FC.TRANSACTION_DATE,
    FC.TRANSACTION_TYPE,
    sum(FC.TRANSACTION_AMOUNT) AS TRANSACTION_AMOUNT,
    FC.MERCHANT,
    FC.CATEGORY,
    count(f.FRAUD_TYPE) AS FRAUD_TYPE,
    sum(cc.CREDIT_LIMIT) AS CREDIT_LIMIT,
    sum(cc.BALANCE) AS CREDIT_CARD_BALANCE,
    sum(l.LOAN_AMOUNT) AS LOAN_AMOUNT,
    sum(l.LOAN_BALANCE) AS LOAN_BALANCE,
    avg(l.INTEREST_RATE) AS LOAN_INTEREST_RATE

FROM 
    COREBANKING.FULL_CUSTOMER FC
LEFT OUTER JOIN 
    FRAUDDETECTION.TRANSACTION_FRAUD f ON FC.TRANSACTION_ID = f.TRANSACTION_ID
LEFT OUTER JOIN 
    RISKANALYSIS.CREDIT_CARDS cc ON FC.CUSTOMER_ID = cc.CUSTOMER_ID
LEFT OUTER JOIN 
    RISKANALYSIS.LOANS l ON FC.CUSTOMER_ID = l.CUSTOMER_ID
group by all ;



/*#########################################################
    QUERY DATA BELOW
*/

---------------------------------------------------------------------------------    
-- Query the dynamic table to retrieve the summarized account and credit card data
SELECT * FROM COREBANKING.ACCOUNT_CREDIT_CARD_SUMMARY;


---------------------------------------------------------------------------------
-- Query the dynamic table to retrieve the comprehensive transaction report
SELECT * FROM COREBANKING.TRANSACTION_REPORT;


---------------------------------------------------------------------------------    
-- Example: Querying for a specific transaction date
SELECT * FROM COREBANKING.TRANSACTION_REPORT
    WHERE TRANSACTION_DATE = '2024-07-11'
    ORDER BY TOTAL_TRANSACTIONS DESC;


---------------------------------------------------------------------------------    
-- Example queries to retrieve specific customer and transaction records
SELECT * FROM COREBANKING.FULL_CUSTOMER WHERE CUSTOMER_ID = '402000';

