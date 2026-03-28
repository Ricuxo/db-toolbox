/*  */
column meas_date format a17 heading 'Measurement|Date'
column value new_value size_lim noprint
set pages 0 lines 80 feedback off verify off
ttitle off
select a.value*b.value value from v$parameter a, v$parameter b 
where a.name = 'cache_size_threshold' and b.name='db_block_size';
column sorts_disk format 999,999 heading 'Disk|Sorts'
column long_scans format 999,999,999 heading 'Long Scans|>&&size_lim Bytes'
column short_scans format 999,999,999 heading 'Short Scans|<&&size_lim bytes'
column total_scans format 999,999,999 heading 'Total Scans'
start title80 'Sorts and Table Scans'
spool rep_out/&db/sorts_table_scans
select to_char(a.meas_date,'dd-mon-yyyy hh24:mi') meas_date, a.value sorts_disk,
b.value long_scans, c.value short_scans, b.value+c.value total_scans
from
dba_running_stats a,
dba_running_stats b,
dba_running_stats c
where
trunc(a.meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
and
a.meas_date=b.meas_date
and
b.meas_date=c.meas_date
and
a.name='sorts (disk)'
and
b.name ='table scans (long tables)'
and 
c.name='table scans (short tables)'
order by meas_date
/
spool off
ttitle off
clear columns
set feedback on verify on
