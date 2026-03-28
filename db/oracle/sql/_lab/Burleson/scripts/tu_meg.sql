/*  */
column value format 99,999.99
column name format a25
column meas_date format a16
column delta format 99,999.99
set pages 0 lines 80
start title80 'Total Used Meg'
spool rep_out/&db/tu_meg
select 
name, value, Delta, to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats where name ='TOTAL USED MEG'
order by meas_date
/
spool off
