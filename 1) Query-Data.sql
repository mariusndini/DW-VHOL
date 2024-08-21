/*#########################################################
    SET THE CONTEXT
    - Switch to the appropriate role, database, and warehouse.
    - Ensure you are operating in the correct environment for executing queries.
*/
USE ROLE <YOUR ROLE>;
USE DATABASE <YOUR DATABASE>;
USE WAREHOUSE <YOUR WAREHOUSE>;











/*################################################################################
##################################################################################
########################## ** VIEW ALL TABLES ** #################################
    - Display a list of all tables available in the specified database.
    - Perform sample queries to retrieve the first 1000 records from critical tables 
      in various schemas like Core Banking, Risk Analysis, Wealth Management, and Fraud Detection.
*/
SHOW TABLES IN DATABASE;

-- Sample data retrieval from key tables for initial exploration
SELECT * FROM COREBANKING.CUSTOMERS LIMIT 1000;
SELECT * FROM COREBANKING.ACCOUNTS LIMIT 1000;
SELECT * FROM COREBANKING.TRANSACTIONS LIMIT 1000;
SELECT * FROM RISKANALYSIS.LOANS LIMIT 1000;
SELECT * FROM RISKANALYSIS.CREDIT_CARDS LIMIT 1000;
SELECT * FROM WEALTHMANAGEMENT.INVESTMENTS LIMIT 1000;
SELECT * FROM FRAUDDETECTION.TRANSACTION_FRAUD LIMIT 1000;

-- Count the number of records in each key table to understand the data volume
SELECT COUNT(*) FROM COREBANKING.CUSTOMERS;
SELECT COUNT(*) FROM COREBANKING.ACCOUNTS;
SELECT COUNT(*) FROM COREBANKING.TRANSACTIONS;
SELECT COUNT(*) FROM RISKANALYSIS.LOANS;
SELECT COUNT(*) FROM RISKANALYSIS.CREDIT_CARDS;
SELECT COUNT(*) FROM WEALTHMANAGEMENT.INVESTMENTS;
SELECT COUNT(*) FROM FRAUDDETECTION.TRANSACTION_FRAUD;












/*#########################################################
###########################################################
###########################################################
    $ Customer Segmentation Report
    - Objective: Identify different customer segments based on demographics, 
      account types, and transaction behaviors.
    - This query aggregates transaction data by customer and account type, 
      providing insights into transaction volumes and average transaction values 
      for each segment.
*/
SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    c.LAST_NAME,
    a.ACCOUNT_TYPE,
    COUNT(t.TRANSACTION_ID) AS TRANSACTION_COUNT,
    AVG(t.TRANSACTION_AMOUNT) AS AVG_TRANSACTION_AMOUNT
FROM 
    COREBANKING.CUSTOMERS c
JOIN 
    COREBANKING.ACCOUNTS a ON c.CUSTOMER_ID = a.CUSTOMER_ID
JOIN 
    COREBANKING.TRANSACTIONS t ON a.ACCOUNT_ID = t.ACCOUNT_ID
WHERE 
    t.TRANSACTION_DATE >= '2024-01-01'
GROUP BY 
    c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME, a.ACCOUNT_TYPE
ORDER BY 1 ASC;














/*#########################################################
###########################################################
###########################################################
    $ Account Performance Report
    - Objective: Analyze the performance and status of different account types.
    - This query provides a breakdown of account types, including the number 
      of active, inactive, and closed accounts, along with average balances 
      and interest rates.
*/
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
    ACCOUNT_TYPE
ORDER BY 
    TOTAL_ACCOUNTS DESC;



















/*#########################################################
###########################################################
###########################################################
    $ Transaction Analysis Report
    - Objective: Gain insights into transaction patterns and financial flows.
    - This query summarizes the transaction data, including the total number, 
      total amount, and average, maximum, and minimum transaction amounts for 
      each transaction type.
*/
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
    TRANSACTION_TYPE
ORDER BY 
    TOTAL_TRANSACTIONS DESC;







    
/*#########################################################
###########################################################
###########################################################
    $ Loan Portfolio Report
    - Objective: Assess the status and performance of the loan portfolio.
    - This query evaluates the loan portfolio by loan type, showing the 
      total loan amounts, outstanding balances, average interest rates, 
      and the number of paid-off loans.
*/
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
    LOAN_TYPE
ORDER BY 
    TOTAL_LOAN_AMOUNT DESC;









    
/*#########################################################
###########################################################
###########################################################
    $ Credit Card Usage Report
    - Objective: Monitor and analyze credit card usage and risks.
    - This query provides insights into the number of credit cards by type, 
      including total credit limits, balances, and the status (active, inactive, closed) 
      of the cards.
*/
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
    CARD_TYPE
ORDER BY 
    TOTAL_CARDS DESC;








    
/*#########################################################
###########################################################
###########################################################
    $ Investment Portfolio Report
    - Objective: Evaluate the performance of customer investments.
    - This query aggregates data on different investment types, 
      showing total investments, current value, average risk levels, 
      and average returns for each investment type.
*/
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
    INVESTMENT_TYPE
ORDER BY 
    TOTAL_INVESTMENT_AMOUNT DESC;









    
/*#########################################################
###########################################################
###########################################################
    $ Fraud Detection Report
    - Objective: Identify and analyze fraudulent activities.
    - This query focuses on the types of fraud detected, 
      the number of occurrences, affected transactions, and the most recent detection date.
*/
SELECT 
    FRAUD_TYPE,
    COUNT(FRAUD_ID) AS FRAUD_COUNT,
    COUNT(DISTINCT TRANSACTION_ID) AS AFFECTED_TRANSACTIONS,
    MAX(DETECTED_DATE) AS LAST_DETECTED_DATE
FROM 
    FRAUDDETECTION.TRANSACTION_FRAUD
GROUP BY 
    FRAUD_TYPE
ORDER BY 
    FRAUD_COUNT DESC;







    
/*#########################################################
###########################################################
###########################################################
    $ Risk Management Report
    - Objective: Assess and mitigate financial risks across the organization.
    - This query calculates the total risk exposure for each customer by summing 
      their loan balances and credit card balances, providing a clear picture 
      of financial risk.
*/
SELECT 
    l.CUSTOMER_ID,
    SUM(l.LOAN_BALANCE) AS TOTAL_LOAN_BALANCE,
    SUM(cc.BALANCE) AS TOTAL_CREDIT_CARD_BALANCE,
    SUM(l.LOAN_BALANCE + cc.BALANCE) AS TOTAL_RISK_EXPOSURE
FROM 
    RISKANALYSIS.LOANS l
JOIN 
    RISKANALYSIS.CREDIT_CARDS cc ON l.CUSTOMER_ID = cc.CUSTOMER_ID
GROUP BY 
    l.CUSTOMER_ID
ORDER BY 
    TOTAL_RISK_EXPOSURE DESC;









    
/*#########################################################
###########################################################
###########################################################
    $ Cross-Sell and Upsell Opportunities Report
    - Objective: Identify opportunities to cross-sell and upsell financial products.
    - This query analyzes the total number of financial products held by each customer, 
      which can indicate opportunities for cross-selling and upselling additional products.
*/
SELECT 
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    c.LAST_NAME,
    COUNT(DISTINCT a.ACCOUNT_ID) AS NUM_ACCOUNTS,
    COUNT(DISTINCT cc.CREDIT_CARD_ID) AS NUM_CREDIT_CARDS,
    COUNT(DISTINCT i.INVESTMENT_ID) AS NUM_INVESTMENTS,
    (COUNT(DISTINCT a.ACCOUNT_ID) + COUNT(DISTINCT cc.CREDIT_CARD_ID) + COUNT(DISTINCT i.INVESTMENT_ID)) AS TOTAL_PRODUCTS
FROM 
    COREBANKING.CUSTOMERS c
LEFT JOIN 
    COREBANKING.ACCOUNTS a ON c.CUSTOMER_ID = a.CUSTOMER_ID
LEFT JOIN 
    RISKANALYSIS.CREDIT_CARDS cc ON c.CUSTOMER_ID = cc.CUSTOMER_ID
LEFT JOIN 
    WEALTHMANAGEMENT.INVESTMENTS i ON c.CUSTOMER_ID = i.CUSTOMER_ID
GROUP BY 
    c.CUSTOMER_ID, c.FIRST_NAME, c.LAST_NAME
ORDER BY 
    TOTAL_PRODUCTS DESC;
