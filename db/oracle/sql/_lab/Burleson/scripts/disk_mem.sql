/*  */
set pages 0 lines 80
start title80 'Disk to Memory Sorts Percent'
spool rep_out/&db/NI_lookup.doc
ttitle off
set pages 0 lines 80 heading off
select 
'Disk to memory Sorts percent'||','||to_char((a.value/b.value)*100,999.9999)||','||to_char(a.meas_date,'dd-mon-yy hh24:mi')
from dba_running_stats a, dba_running_stats b where a.name = 'sorts (disk)' and
b.name='sorts (memory)' and a.meas_date=b.meas_date
and trunc(a.meas_date)>=to_date('&dd_mon_yy','dd-mon-yy')
order by a.meas_date
/
spool off
set echo off
