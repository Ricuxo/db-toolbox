/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading 'Begin|Interval|time'    format a8
col c2 heading 'SQL|ID'                 format a13
col c3 heading 'Exec|Delta'             format 9,999
col c4 heading 'Buffer|Gets|Delta'      format 9,999
col c5 heading 'Disk|Reads|Delta'       format 9,999
col c6 heading 'IO Wait|Delta'          format 9,999
col c7 heading 'Application|Wait|Delta' format 9,999
col c8 heading 'Concurrency|Wait|Delta' format 9,999


break on c1 

select
  to_char(s.begin_interval_time,'mm-dd hh24')  c1,
  sql.sql_id               c2,    
  sql.executions_delta     c3,
  sql.buffer_gets_delta    c4,
  sql.disk_reads_delta     c5,
  sql.iowait_delta         c6,
  sql.apwait_delta         c7,
  sql.ccwait_delta         c8
from
   dba_hist_sqlstat        sql,
   dba_hist_snapshot         s
where
   s.snap_id = sql.snap_id
order by
   c1, 
   c2
;
