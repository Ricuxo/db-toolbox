/*  */
column value format 999.9999
column name format a30
column meas_date format a16
rem column delta format 999.9999
set pages 0 lines 80
start title80 'Non-Index Lookups Ratio'
spool rep_out/&db/dd_miss
select 
name, value, Delta, to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats where name ='Non-Index Lookups Ratio'
and trunc(meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
order by meas_date
/
spool off
set echo off
