
set feed off
set pages 100

col c1 heading 'Begin|time'             format a17
col c2 heading 'Execs'                  format 999,999,999
col c3 heading 'Buffer|Gets'            format 999,999,999
col c4 heading 'Disk|Reads'             format 999,999,999
col c5 heading 'Row|Process'            format 999,999,999
col c8 heading 'CPU|Time(secs)'         format 999,999,999.9999
col c9 heading 'Elapsed|Time(secs)'     format 999,999,999.9999
col c10 heading 'Elapsed|Execs(secs)'     format 999,999,999.9999
 

select distinct sql_text from v$sql where sql_id='&1';

 
select
  to_char(s.begin_interval_time,'YYYY-MM-DD HH24:MI')  c1,
  sql.executions_delta     	   c2,
  sql.buffer_gets_delta    	   c3,
  sql.disk_reads_delta     	   c4,
  sql.ROWS_PROCESSED_DELTA         c5,
  sql.cpu_time_delta/1000000       c8,
  sql.elapsed_time_delta/1000000   c9,
  (sql.elapsed_time_delta/1000000)/sql.executions_delta c10
from
   dba_hist_sqlstat        sql,
   dba_hist_snapshot         s
where s.snap_id = sql.snap_id
and   sql.executions_delta <> 0
and   sql_id = '&1'
order by c1
/

set feed on
