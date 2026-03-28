/*  */
--*************************************************
--    
--   Free for non-commercial use!  
--   To license, e-mail info@rampant.cc
-- ************************************************

col c1 heading 'Begin|Interval|time'    format a8
col c2 heading 'Exec|Delta'             format 999,999
col c3 heading 'Buffer|Gets|Delta'      format 999,999
col c4 heading 'Disk|Reads|Delta'       format 9,999
col c5 heading 'IO Wait|Delta'          format 9,999
col c6 heading 'App|Wait|Delta'         format 9,999
col c7 heading 'Cncr|Wait|Delta'        format 9,999
col c8 heading 'CPU|Time|Delta'         format 999,999
col c9 heading 'Elpsd|Time|Delta'       format 999,999

accept sqlid prompt 'Enter SQL ID: '

ttitle 'time series execution for|&sqlid'

break on c1 

select
  to_char(s.begin_interval_time,'mm-dd hh24')  c1,
  sql.executions_delta     c2,
  sql.buffer_gets_delta    c3,
  sql.disk_reads_delta     c4,
  sql.iowait_delta         c5,
  sql.apwait_delta         c6,
  sql.ccwait_delta         c7,
  sql.cpu_time_delta       c8,
  sql.elapsed_time_delta   c9
from
   dba_hist_sqlstat        sql,
   dba_hist_snapshot         s
where
   s.snap_id = sql.snap_id
and
   sql_id = '&sqlid'
order by
   c1
;
