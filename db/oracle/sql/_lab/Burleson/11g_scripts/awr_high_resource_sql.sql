/*  */
-- *************************************************
--  
-- This script is free for non-commercial purposes
-- with no warranties.  Use at your own risk.
--
-- To license this script for a commercial purpose, 
-- contact info@rampant.cc
-- *************************************************

select sql_text,
       username,
       disk_reads_per_exec,
       buffer_gets,
       disk_reads,
       parse_calls,
       sorts,
       executions,
       rows_processed,
       hit_ratio,
       first_load_time,
       sharable_mem,
       persistent_mem,
       runtime_mem,
       cpu_time,
       elapsed_time,
       address,
       hash_value
from
(select sql_text ,
        b.username ,
 round((a.disk_reads/decode(a.executions,0,1,
 a.executions)),2)
       disk_reads_per_exec,
       a.disk_reads ,
       a.buffer_gets ,
       a.parse_calls ,
       a.sorts ,
       a.executions ,
       a.rows_processed ,
       100 - round(100 *
       a.disk_reads/greatest(a.buffer_gets,1),2) hit_ratio,
       a.first_load_time ,
       sharable_mem ,
       persistent_mem ,
       runtime_mem,
       cpu_time,
       elapsed_time,
       address,
       hash_value
from 
   sys.v_$sqlarea a,
   sys.all_users b
where 
   a.parsing_user_id=b.user_id and
   b.username not in ('sys','system')
order by 3 desc)
where rownum < 21
