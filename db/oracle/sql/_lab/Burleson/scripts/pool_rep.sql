/*  */
column name format a30 heading 'Pool Measurement'
column meas_date format a15 heading 'Measurement Date'
column value format 9,999.99 heading 'Value'
set pages 47
@title80 'Shared Pool Measurements'
spool rep_out/&db/pool_rep.doc
select name,value,to_char(meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats
where name in ('Shared Pool Available',
'Shared Pool Used') and 
trunc(meas_date) between to_date('&date1') and to_date('&date2')
order by 1,3
/
spool off

