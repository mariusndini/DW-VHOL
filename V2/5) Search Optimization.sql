/*#########################################################
    SET THE CONTEXT
    - Find and replace 'XXX' with your number
*/

USE ROLE MS_DBA_XXX;
USE DATABASE MS_FINSIGHTS_XXX;
USE WAREHOUSE TEST_WH_XXX;

//This query time will depend on the warehouse size.
CREATE OR REPLACE TABLE OPENALEX_WORKS_INDEX CLONE MS_FINSIGHTS_XXX.OPENALEX.OPENALEX_WORKS_INDEX; 


//Note: Check the table details
DESCRIBE TABLE OPENALEX_WORKS_INDEX;
SHOW TABLES LIKE 'OPENALEX_WORKS_INDEX' ;


//Note: Check the data
SELECT * FROM OPENALEX_WORKS_INDEX LIMIT 100;


------ Run all 3 queries, check duration in Query History
// Note: This query will take ~30 seconds 
SELECT *  from OPENALEX_WORKS_INDEX where mag_work_id = 2240388798; 

// Note: This query will take ~ 1 minute
SELECT *  from OPENALEX_WORKS_INDEX where work_title ilike 'Cross-domain applications of multimodal human-computer interfaces'; 

// Note: This query will take ~1 minute
SELECT * from OPENALEX_WORKS_INDEX  where WORK_PRIMARY_LOCATION:source:display_name ilike 'Eco-forum'; 


----Let us enable Search Optimization

// Defining Search Optimization on NUMBER fields For Equality
ALTER TABLE OPENALEX_WORKS_INDEX ADD SEARCH OPTIMIZATION ON EQUALITY(MAG_WORK_ID);

// Defining Search Optimization on VARCHAR fields optimized for Wildcard search
ALTER TABLE OPENALEX_WORKS_INDEX ADD SEARCH OPTIMIZATION ON SUBSTRING(WORK_TITLE);

// Defining Search Optimization on VARIANT field For Equality
ALTER TABLE OPENALEX_WORKS_INDEX ADD SEARCH OPTIMIZATION ON SUBSTRING(WORK_PRIMARY_LOCATION:source.display_name);

// Defining Search Optimization on VARIANT field For Wildcard search
ALTER TABLE OPENALEX_WORKS_INDEX ADD SEARCH OPTIMIZATION ON EQUALITY(WORK_PRIMARY_LOCATION:source.issn_l);


SHOW TABLES LIKE 'OPENALEX_WORKS_INDEX';

DESCRIBE SEARCH OPTIMIZATION ON OPENALEX_WORKS_INDEX;
-- The status will update from active=false to true as the Search Access Path is finished being created

---let us run the queries again

ALTER SESSION SET use_cached_result = FALSE;

--- Search equality column
--- x minute to y seconds
SELECT *  
FROM OPENALEX_WORKS_INDEX 
WHERE mag_work_id = 2240388798;

--- Search a string column
--- x minute to y seconds
SELECT *  
FROM OPENALEX_WORKS_INDEX 
WHERE work_title ILIKE 'Cross-domain applications of multimodal human-computer interfaces'; 

 --- Query variant data
 --- x minutes to y sec
SELECT *
FROM OPENALEX_WORKS_INDEX  
WHERE WORK_PRIMARY_LOCATION:source:issn_l = '2615-6946';


--- search of strings in Variants
--- x minutes to y seconds
SELECT *
FROM OPENALEX_WORKS_INDEX  
WHERE WORK_PRIMARY_LOCATION:source:display_name ILIKE 'Eco-forum'; 

