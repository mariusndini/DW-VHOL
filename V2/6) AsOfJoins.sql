/*#########################################################
    SET THE CONTEXT
    - Find and replace 'XXX' with your number
*/

USE ROLE MS_DBA_XXX;
USE DATABASE MS_FINSIGHTS_XXX;
USE SCHEMA TRADES;
USE WAREHOUSE TEST_WH_XXX;


SELECT * FROM trades limit 10;
SELECT * FROM quotes limit 10;

select count (*) from trades where "Symbol" = 'AAPL'; --838,794
select count (*) from quotes where "Symbol" = 'AAPL'; --12,045,314


-- THIS IS A VERY LONG RUNNING QUERY. c. 11 mins on a 4XL Warehouse!!!
-- Query ID: 
WITH all_trades AS (
SELECT t."Symbol", 
       t."Sale Condition", 
       t."Trade Volume", 
       t."TTime" as trade_time,
       q."TTime" as quote_time,
       rank() OVER (PARTITION BY t."Symbol", t."Exchange", t."TTime" ORDER BY TIMESTAMPDIFF(milliseconds , t."TTime" , q."TTime")) as latest_quotes
FROM trades t 
JOIN quotes q
  ON t."Symbol" = q."Symbol" 
  AND t."Exchange" = q."Exchange" 
  AND t."TTime" BETWEEN q."TTime" AND dateadd(second,10, q."TTime")
WHERE t."Symbol" = 'AAPL' 
AND q."Symbol" IS NOT NULL
)
select *
from all_trades
where latest_quotes = 1
;



SELECT t."Symbol", 
       t."Sale Condition", 
       t."Trade Volume", 
       t."TTime" as trade_time,
       q."TTime" as quote_time
FROM trades t 
ASOF JOIN quotes q
  MATCH_CONDITION (t."TTime" >= q."TTime")
  ON t."Symbol" = q."Symbol"
  AND t."Exchange" = q."Exchange" 
WHERE t."Symbol" = 'AAPL' 
AND q."Symbol" is not null
;
-- 3-4 seconds