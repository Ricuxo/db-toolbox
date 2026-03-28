/*  */
set pages 0 lines 80 heading off feedback off verify off
@title80 ''
ttitle off
set pages 0 lines 80 heading off feedback off verify off
spool rep_out/&db/undo_blk_waits.doc
select 
name||','||to_char(value)||','||to_char(delta)||','||to_char(meas_date,'dd-mon-yy hh24:mi')
from dba_running_stats where name ='undo block waits' 
and trunc(meas_date)>to_date('&dd_mon_yy','dd-mon-yy')
order by meas_date
/
spool off
