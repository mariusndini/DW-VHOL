--UPDATED 2020-09-15
----------------------------------------------------------------------------------------
----- DBA PART I
----------------------------------------------------------------------------------------

-- --3.1.2 Set your context to use your DBA role and assigned SCHEMA
use role role_bos_26;

use database citibike_bos;
use schema citibike_bos.schema26;


--2.1.4 Create a table called trips to hold our Citibike data
create or replace table trips
(tripduration integer,
  starttime timestamp,
  stoptime timestamp,
  start_station_id integer,
  start_station_name string,
  start_station_latitude float,
  start_station_longitude float,
  end_station_id integer,
  end_station_name string,
  end_station_latitude float,
  end_station_longitude float,
  bikeid integer,
  membership_type string,
  usertype string,
  birth_year integer,
  gender integer);

--2.2.3 Create the stage - this has been previoulsy done
-- create or replace stage trip_data_s3 url = 's3://snowflake-workshop-lab/citibike-trips-csv/';

--2.2.4 Have a look at the staged data
ls @data.citibike.mystage;

--2.3.1 Create a file format that matches our CSV data (OR RUN VIA UI)
create or replace file format csv
  type='csv'
  compression = 'auto' 
  field_delimiter = ',' 
  record_delimiter = '\n'
  skip_header = 1
  field_optionally_enclosed_by = '\042' 
  trim_space = false
  error_on_column_count_mismatch = false 
  escape = 'none' 
  escape_unenclosed_field = '\134'
  date_format = 'auto' 
  timestamp_format = 'auto' 
  NULL_IF = ('\\N', '');


--3.1.2 Create a Warehouse to load our data (OR RUN VIA UI)
create or replace warehouse load_wh26
with warehouse_size = 'medium'
auto_suspend = 300
auto_resume = true
min_cluster_count = 1
max_cluster_count = 1
scaling_policy = 'standard';


--3.2.1 Adjust your context to use your new warehouse
use warehouse load_wh26;

-- Peek into one of the files
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
FROM @data.citibike.mystage
(FILE_FORMAT => csv, PATTERN => 'trips/data/2018/1/10/trips.csv');


--3.2.2 Load some of the data!
copy into trips
from @data.citibike.mystage
pattern='trips/data/2018/1/10/trips.csv'
file_format=csv
-- on_error = continue
FORCE = TRUE;



--3.2.3 Let’s scale our compute UP by increasing our Warehouse size to X-Large:
alter warehouse load_wh26 set warehouse_size='xlarge';

--3.2.4 Then load the rest of the data:
copy into trips
from @data.citibike.mystage
file_format=csv;


--3.2.5 Now that the data is loaded, we can run simple SQL
--Check the number of rows loaded
select count(*) from trips;


-- And a sample of the data
select * from trips limit 20;


----------------------------------------------------------------------------------------
-----DBA PART II
----------------------------------------------------------------------------------------

--SECTION 1: CLONE THE SCHEMA
--3.2.1 Create a dev schema by cloning schema
create or replace schema citibike_bos.schema26_dev clone citibike_bos.schema26;

--SECTION 2: QUERY JSON
select *
from WEATHER_DATA.PUBLIC.HOL_WEATHER
where v:city.id::int = 5128638 limit 20;

--2.2.1 Check out how we can query JSON data with SQL, as if it were a structured table!
select
  dateadd('year',-2,v:time::timestamp) as observation_time,
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from WEATHER_DATA.PUBLIC.HOL_WEATHER
where city_id = 5128638 limit 20;



--2.3.1 Let's first create a view in schema1_dev
create or replace view citibike_bos.schema26_dev.weather_vw as
select
  dateadd('year',-2,v:time::timestamp) as observation_time,
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from WEATHER_DATA.PUBLIC.HOL_WEATHER
where city_id = 5128638;


--2.3.2 Verify the data before pushing to PROD schema
select * from citibike_bos.schema26_dev.weather_vw
limit 20;


--2.3.3 All good, create the view in PROD!
create or replace view citibike_bos.schema26.weather_vw as
select
  dateadd('year',-2,v:time::timestamp) as observation_time,
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from WEATHER_DATA.PUBLIC.HOL_WEATHER
where city_id = 5128638;

--2.3.4 Drop the DEV schema
drop schema citibike_bos.schema26_dev;
use schema citibike_bos.schema26;


-------------------------------------------------------------------------------
--SECTION 2.4: COMBINED VIEW
--2.4.1 Now that we have the weather_vw, let's combine it with our trips table
create or replace view trip_weather_vw as
select * from trips
left outer join weather_vw
on date_trunc('hour', observation_time) = date_trunc('hour', starttime);


--2.4.2 Now we can see what the weather was like at the start of a ride!
select weather as conditions,
count(*) as "num trips"
from trip_weather_vw
where conditions is not null
group by 1 order by 2 desc;


-------------------------------------------------------------------------------
--SECTION 4.2: TIME TRAVEL
--4.1.1 Accidentally drop the trips table
drop table trips;


--4.1.3 Restore with an UNdrop!
undrop table trips;
select * from trips limit 10;


-------------------------------------------------------------------------------
--SECTION 4.3: ROLL BACK A TABLE
--4.2.1 Accidentally mess up the data and replace all the station names with "oops"
update trips set start_station_name = 'oops';


--4.2.2 Try to list the top 20 stations...
select *
from trips
limit 200;


--4.2.3 Fix it by finding the query_id and then rolling the table back
set query_id =
(select query_id from
table(information_schema.query_history_by_session (result_limit=>5))
where query_text like 'update%' order by start_time limit 1);

create or replace table trips as
    (select * from trips before (statement => $query_id));

--Run the query in 4.2.2 again and ta da! The data is fixed :)
select *
from trips
limit 200;


