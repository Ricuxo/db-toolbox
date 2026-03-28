/*  */
set lines 132 pages 1000
select runid,unit_number,line#,total_occur,
total_time/1000000000 total ,
min_time/1000000000 min, 
max_time/1000000000 max
from plsql_profiler_data where total_time>0
/
