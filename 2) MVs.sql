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
    $ Account Performance Report
    - Objective: Analyze the performance and status of different account types.
    - This materialized view aggregates account data to provide insights into 
      the number of active, inactive, and closed accounts, along with average balances 
      and interest rates for each account type.
*/
CREATE OR REPLACE MATERIALIZED VIEW COREBANKING.ACCOUNT_PERFORMANCE_MV AS
SELECT 
    ACCOUNT_TYPE,
    COUNT(ACCOUNT_ID) AS TOTAL_ACCOUNTS,
    AVG(BALANCE) AS AVG_BALANCE,
    AVG(INTEREST_RATE) AS AVG_INTEREST_RATE,
    COUNT(CASE WHEN ACCOUNT_STATUS = 'Active' THEN 1 END) AS ACTIVE_ACCOUNTS,
    COUNT(CASE WHEN ACCOUNT_STATUS = 'Inactive' THEN 1 END) AS INACTIVE_ACCOUNTS,
    COUNT(CASE WHEN ACCOUNT_STATUS = 'Closed' THEN 1 END) AS CLOSED_ACCOUNTS
FROM 
    COREBANKING.ACCOUNTS
GROUP BY 
    ACCOUNT_TYPE;

-- Retrieve data from the Account Performance materialized view
SELECT *
FROM COREBANKING.ACCOUNT_PERFORMANCE_MV;











/*#########################################################
###########################################################
###########################################################
    $ Transaction Analysis Report
    - Objective: Gain insights into transaction patterns and financial flows.
    - This materialized view summarizes transaction data, including the total number, 
      total amount, and average, maximum, and minimum transaction amounts for 
      each transaction type.
*/
CREATE OR REPLACE MATERIALIZED VIEW COREBANKING.TRANSACTION_ANALYSIS_MV AS
SELECT 
    TRANSACTION_TYPE,
    COUNT(TRANSACTION_ID) AS TOTAL_TRANSACTIONS,
    SUM(TRANSACTION_AMOUNT) AS TOTAL_AMOUNT,
    AVG(TRANSACTION_AMOUNT) AS AVG_TRANSACTION_AMOUNT,
    MAX(TRANSACTION_AMOUNT) AS MAX_TRANSACTION_AMOUNT,
    MIN(TRANSACTION_AMOUNT) AS MIN_TRANSACTION_AMOUNT
FROM 
    COREBANKING.TRANSACTIONS
GROUP BY 
    TRANSACTION_TYPE;

-- Retrieve data from the Transaction Analysis materialized view
SELECT *
FROM COREBANKING.TRANSACTION_ANALYSIS_MV;










/*#########################################################
###########################################################
###########################################################
    $ Loan Portfolio Report
    - Objective: Assess the status and performance of the loan portfolio.
    - This materialized view aggregates loan data by loan type, showing the 
      total loan amounts, outstanding balances, average interest rates, 
      and the number of paid-off loans.
*/
CREATE OR REPLACE MATERIALIZED VIEW RISKANALYSIS.LOAN_PORTFOLIO_MV AS
SELECT 
    LOAN_TYPE,
    COUNT(LOAN_ID) AS TOTAL_LOANS,
    SUM(LOAN_AMOUNT) AS TOTAL_LOAN_AMOUNT,
    SUM(LOAN_BALANCE) AS OUTSTANDING_BALANCE,
    AVG(INTEREST_RATE) AS AVG_INTEREST_RATE,
    COUNT(CASE WHEN LOAN_BALANCE = 0 THEN 1 END) AS PAID_OFF_LOANS
FROM 
    RISKANALYSIS.LOANS
GROUP BY 
    LOAN_TYPE;

-- Retrieve data from the Loan Portfolio materialized view
SELECT *
FROM RISKANALYSIS.LOAN_PORTFOLIO_MV;











/*#########################################################
###########################################################
###########################################################
    $ Credit Card Usage Report
    - Objective: Monitor and analyze credit card usage and risks.
    - This materialized view provides insights into the number of credit cards by type, 
      including total credit limits, balances, and the status (active, inactive, closed) 
      of the cards.
*/
CREATE OR REPLACE MATERIALIZED VIEW RISKANALYSIS.CREDIT_CARD_USAGE_MV AS
SELECT 
    CARD_TYPE,
    COUNT(CREDIT_CARD_ID) AS TOTAL_CARDS,
    SUM(CREDIT_LIMIT) AS TOTAL_CREDIT_LIMIT,
    SUM(BALANCE) AS TOTAL_BALANCE,
    AVG(BALANCE) AS AVG_BALANCE,
    COUNT(CASE WHEN CARD_STATUS = 'Active' THEN 1 END) AS ACTIVE_CARDS,
    COUNT(CASE WHEN CARD_STATUS = 'Inactive' THEN 1 END) AS INACTIVE_CARDS,
    COUNT(CASE WHEN CARD_STATUS = 'Closed' THEN 1 END) AS CLOSED_CARDS
FROM 
    RISKANALYSIS.CREDIT_CARDS
GROUP BY 
    CARD_TYPE;

-- Retrieve data from the Credit Card Usage materialized view
SELECT *
FROM RISKANALYSIS.CREDIT_CARD_USAGE_MV;












/*#########################################################
###########################################################
###########################################################
    $ Investment Portfolio Report
    - Objective: Evaluate the performance of customer investments.
    - This materialized view aggregates data on different investment types, 
      showing total investments, current value, average risk levels, 
      and average returns for each investment type.
*/
CREATE OR REPLACE MATERIALIZED VIEW WEALTHMANAGEMENT.INVESTMENT_PORTFOLIO_MV AS
SELECT 
    INVESTMENT_TYPE,
    COUNT(INVESTMENT_ID) AS TOTAL_INVESTMENTS,
    SUM(INVESTMENT_AMOUNT) AS TOTAL_INVESTMENT_AMOUNT,
    SUM(CURRENT_VALUE) AS TOTAL_CURRENT_VALUE,
    AVG(CASE 
        WHEN RISK_LEVEL = 'Low' THEN 1 
        WHEN RISK_LEVEL = 'Medium' THEN 2 
        WHEN RISK_LEVEL = 'High' THEN 3 
        ELSE 0 END) AS AVG_RISK_LEVEL,
    AVG(CURRENT_VALUE - INVESTMENT_AMOUNT) AS AVG_RETURN
FROM 
    WEALTHMANAGEMENT.INVESTMENTS
GROUP BY 
    INVESTMENT_TYPE;

-- Retrieve data from the Investment Portfolio materialized view
SELECT *
FROM WEALTHMANAGEMENT.INVESTMENT_PORTFOLIO_MV;












/*#########################################################
###########################################################
###########################################################
    $ STATS
    - Objective: Monitor materialized view refresh history and usage statistics.
    - The following queries will help in understanding the performance and cost 
      associated with materialized views.
*/

show materialized views in database;

-- Retrieve recent materialized view refresh history
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY
ORDER BY START_TIME DESC
LIMIT 1000;

-- Calculate the total credits used by materialized view refreshes
SELECT SUM(CREDITS_USED)
FROM SNOWFLAKE.ACCOUNT_USAGE.MATERIALIZED_VIEW_REFRESH_HISTORY;
