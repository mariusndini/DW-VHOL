/*#########################################################
    CHANGE THIS TO BE YOUR ROLE
*/
use role SYSADMIN;

/*#########################################################
    create the respective database.
*/
CREATE DATABASE IF NOT EXISTS FINSIGHTS;
USE DATABASE FINSIGHTS;

/*#########################################################
    CREATE WAREHOUSE
*/
CREATE WAREHOUSE IF NOT EXISTS FINWH; // CREATE XS WH
USE WAREHOUSE FINWH;

/*#########################################################
    CREATE RESPECTIVE SCHEMAS
*/
CREATE SCHEMA IF NOT EXISTS FINSIGHTS.CoreBanking;
CREATE SCHEMA IF NOT EXISTS FINSIGHTS.WealthManagement;
CREATE SCHEMA IF NOT EXISTS FINSIGHTS.RiskAnalysis;
CREATE SCHEMA IF NOT EXISTS FINSIGHTS.FraudDetection;




/*#######################** CREATE TABLES **##################################*/

/*
The CUSTOMERS table stores essential personal and contact information about each customer of the financial institution. 
It acts as the foundational table for customer-related data and serves as a reference point for other tables.
*/
CREATE OR REPLACE TABLE FINSIGHTS.COREBANKING.CUSTOMERS (
    CUSTOMER_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    EMAIL VARCHAR(100),
    PHONE_NUMBER VARCHAR(50),
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    ZIP_CODE VARCHAR(10),
    DATE_OF_BIRTH DATE,
    ACCOUNT_CREATION_DATE DATE
);

/*
The ACCOUNTS table contains information about the various types of accounts held by customers, 
including savings, checking, and credit accounts. It links to the CUSTOMERS table to associate accounts with their owners.
*/

CREATE OR REPLACE TABLE FINSIGHTS.COREBANKING.ACCOUNTS (
    ACCOUNT_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    CUSTOMER_ID INT,
    ACCOUNT_TYPE VARCHAR(20),
    BALANCE DECIMAL(15, 2),
    INTEREST_RATE DECIMAL(5, 2),
    ACCOUNT_OPEN_DATE DATE,
    ACCOUNT_STATUS VARCHAR(20),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES FINSIGHTS.COREBANKING.CUSTOMERS(CUSTOMER_ID)
);


/*
The TRANSACTIONS table records all financial transactions conducted through the accounts, such as deposits, withdrawals, and payments. 
It is critical for tracking cash flow and financial activities.
*/
CREATE OR REPLACE TABLE FINSIGHTS.COREBANKING.TRANSACTIONS (
    TRANSACTION_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    ACCOUNT_ID INT,
    TRANSACTION_DATE DATE,
    TRANSACTION_AMOUNT DECIMAL(15, 2),
    TRANSACTION_TYPE VARCHAR(20),
    MERCHANT VARCHAR(100),
    CATEGORY VARCHAR(50),
    FOREIGN KEY (ACCOUNT_ID) REFERENCES FINSIGHTS.COREBANKING.ACCOUNTS(ACCOUNT_ID)
);



/*
The LOANS table manages data regarding the various loans extended to customers, such as personal loans, auto loans, and mortgages. 
It helps in assessing risk and managing loan portfolios.
*/
CREATE OR REPLACE TABLE FINSIGHTS.RISKANALYSIS.LOANS (
    LOAN_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    CUSTOMER_ID INT,
    LOAN_TYPE VARCHAR(20),
    LOAN_AMOUNT DECIMAL(15, 2),
    LOAN_BALANCE DECIMAL(15, 2),
    INTEREST_RATE DECIMAL(5, 2),
    LOAN_ISSUE_DATE DATE,
    LOAN_DUE_DATE DATE,
    FOREIGN KEY (CUSTOMER_ID) REFERENCES FINSIGHTS.COREBANKING.CUSTOMERS(CUSTOMER_ID)
);


/*
The CREDIT_CARDS table contains information about the credit cards issued to customers, including their limits, balances, and statuses. 
It aids in credit risk management and customer relationship management.
*/
CREATE OR REPLACE TABLE FINSIGHTS.RISKANALYSIS.CREDIT_CARDS (
    CREDIT_CARD_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    CUSTOMER_ID INT,
    CARD_NUMBER VARCHAR(20),
    CARD_TYPE VARCHAR(20),
    CREDIT_LIMIT DECIMAL(15, 2),
    BALANCE DECIMAL(15, 2),
    EXPIRATION_DATE DATE,
    CARD_STATUS VARCHAR(20),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES FINSIGHTS.COREBANKING.CUSTOMERS(CUSTOMER_ID)
);


/*
The INVESTMENTS table tracks customer investments in various financial products, such as stocks, bonds, and mutual funds. 
It provides insights into wealth management and customer portfolio analysis.
*/
CREATE OR REPLACE TABLE FINSIGHTS.WEALTHMANAGEMENT.INVESTMENTS (
    INVESTMENT_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    CUSTOMER_ID INT,
    INVESTMENT_TYPE VARCHAR(20),
    INVESTMENT_AMOUNT DECIMAL(15, 2),
    CURRENT_VALUE DECIMAL(15, 2),
    INVESTMENT_DATE DATE,
    RISK_LEVEL VARCHAR(20),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES FINSIGHTS.COREBANKING.CUSTOMERS(CUSTOMER_ID)
);



/*
The TRANSACTION_FRAUD table identifies and records transactions flagged as potentially fraudulent. 
It supports fraud detection efforts and risk management within the financial institution.
*/
CREATE OR REPLACE TABLE FINSIGHTS.FRAUDDETECTION.TRANSACTION_FRAUD (
    FRAUD_ID INTEGER AUTOINCREMENT(1, 1) PRIMARY KEY,
    TRANSACTION_ID INT,
    DETECTED_DATE DATE,
    FRAUD_TYPE VARCHAR(50),
    DESCRIPTION VARCHAR(255),
    FOREIGN KEY (TRANSACTION_ID) REFERENCES FINSIGHTS.COREBANKING.TRANSACTIONS(TRANSACTION_ID)
);















