/*  */
column total_scans format 99,999,999 heading 'Total Scans'
column meas_date format a16 heading 'Measurement|Date'
column value new_value size_lim noprint
set pages 0 lines 80 feedback off verify off
ttitle off
select a.value*b.value value from v$parameter a, v$parameter b 
where a.name = 'cache_size_threshold' and b.name='db_block_size';
column long_scans format 999,999,999 heading 'Long Scans|>&&size_lim Bytes'
column short_scans format 999,999,999 heading 'Short Scans|<&&size_lim bytes'
column total_scans format 999,999,999 heading 'Total Scans'
start title80 'Table Scans'
spool rep_out/&db/table_scans
select 
a.value long_scans, b.value short_scans, a.value+b.value total_scans, 
to_char(a.meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats a, dba_running_stats b 
where a.name ='table scans (long tables)' 
and b.name='table scans (short tables)' 
and trunc(a.meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
and a.meas_date=b.meas_date 
order by meas_date
/
spool off
ttitle off
clear columns
set feedback on verify on
