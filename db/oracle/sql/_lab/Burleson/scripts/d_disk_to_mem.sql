/*  */
column value format 999.9999
column name format a30
column meas_date format a16
set pages 0 lines 80
start title80 'Disk to Memory Sorts Percent'
spool rep_out/&db/disk_mem
select 
'Disk_To_Memory_Sort_Percent', (a.delta/greatest(b.delta,1))*100 value , to_char(a.meas_date,'dd-mon-yy hh24:mi') meas_date
from dba_running_stats a, dba_running_stats b where a.name = 'sorts (disk)' and
b.name='sorts (memory)' and a.meas_date=b.meas_date
and trunc(a.meas_date)>=to_date('&dd_mon_yy','dd-mon-yy')
order by a.meas_date
/
spool off
set echo off
