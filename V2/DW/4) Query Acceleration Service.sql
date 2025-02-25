/*#########################################################
    SET THE CONTEXT
    - Find and replace 'XXX' with your number
*/

USE ROLE MS_DBA_XXX;
USE DATABASE MS_FINSIGHTS_XXX;
USE WAREHOUSE MS_HOL_WH;

ALTER SESSION SET use_cached_result=FALSE;

-- Let's check what queries were eligible for QAS in the last 90 days
SELECT query_id,
       query_text,
       start_time,
       end_time,
       warehouse_name,
       warehouse_size,
       eligible_query_acceleration_time,
       upper_limit_scale_factor,
       DATEDIFF(second, start_time, end_time) AS total_duration,
       eligible_query_acceleration_time / NULLIF(DATEDIFF(second, start_time, end_time), 0) AS eligible_time_ratio
FROM
    SNOWFLAKE.ACCOUNT_USAGE.QUERY_ACCELERATION_ELIGIBLE
WHERE
    start_time >= DATEADD(day, -90, CURRENT_TIMESTAMP())
    AND eligible_time_ratio <= 1.0
    --AND total_duration BETWEEN 3 * 60 and 5 * 60
ORDER BY (eligible_time_ratio, upper_limit_scale_factor) DESC NULLS LAST
LIMIT 100;



---LET US USE AN XSMALL WAREHOUSE TO TEST SOME QUERIES

CREATE OR REPLACE WAREHOUSE TEST_WH_XXX WITH
  WAREHOUSE_SIZE='XSmall'
  INITIALLY_SUSPENDED = true
  AUTO_SUSPEND = 60;
  
USE WAREHOUSE TEST_WH_XXX;
  
-- THIS QUERY TAKES c. 1 MIN WITHOUT QAS
-- THIS QUERY TAKES c. 30 SECONDS WITH QAS
SELECT d.d_year as "Year",
       i.i_brand_id as "Brand ID",
       i.i_brand as "Brand",
       SUM(ss_net_profit) as "Profit"
FROM   snowflake_sample_data.tpcds_sf10tcl.date_dim    d,
       snowflake_sample_data.tpcds_sf10tcl.store_sales s,
       snowflake_sample_data.tpcds_sf10tcl.item        i
WHERE  d.d_date_sk = s.ss_sold_date_sk
  AND s.ss_item_sk = i.i_item_sk
  AND i.i_manufact_id = 939
  AND d.d_moy = 12
GROUP BY d.d_year,
         i.i_brand,
         i.i_brand_id
ORDER BY 1, 4, 2
;

-- LET US CHECK OUT THE QBOVE QUERY'S ELIGIBILITY FOR QAS
SELECT SYSTEM$ESTIMATE_QUERY_ACCELERATION('...');


---NOW LET US CREATE AN ACCELERATED WH

CREATE OR REPLACE WAREHOUSE QAS_WH_XXX WITH
  WAREHOUSE_SIZE='XSmall'
  ENABLE_QUERY_ACCELERATION = true
  QUERY_ACCELERATION_MAX_SCALE_FACTOR = 20
  INITIALLY_SUSPENDED = true
  AUTO_SUSPEND = 60;

USE WAREHOUSE QAS_WH_XXX;

-- RERUN THE QUERY ABOVE WITH THE ACCELERATED WH
