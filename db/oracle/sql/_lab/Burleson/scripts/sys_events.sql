/*  */
col event format a30 heading 'Event Name'
col waits format 999,999,999 heading 'Total|Waits'
col average_wait format 999,999,999 heading 'Average|Waits'
col time_waited format 999,999,999 heading 'Time Waited'
@title80 'System Events'
spool rep_out/&db/sys_events
select event, total_waits-total_timeouts waits,
time_waited/(total_waits-total_timeouts) average_wait,
time_waited
from v$system_event  
where total_waits-total_timeouts>0
	and event not like 'SQL*Net%'
	and event not like 'smon%'
	and event not like 'pmon%'
	and event not like 'rdbms%'
	and event not like '%control%'
	and event not like 'LGWR%'
        and event not like 'PX%'
order by time_waited desc
/
spool off
clear columns
ttitle off
