/*  */
column value format 999.9999
column name format a30
column meas_date format a16
set pages 0 lines 80
start title80 'Latch Miss Percent'
spool rep_out/&db/latch_miss
select 
name, value, to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats where name like 'Latch Miss%'
order by meas_date
/
spool off
set echo off
