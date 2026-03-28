/*  */
column value format 999.9999
column name format a25
column meas_date format a16
set pages 0 lines 80
start title80 'Cumulative Hit Ratio'
spool rep_out/&db/cum_hrat
select 
name, value, to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats where name ='CUMMULATIVE HIT RATIO'
order by meas_date
/
spool off
