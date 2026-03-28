/*  */
rem
rem FUNCTION: Generate a report on session events by user
rem
rem events.sql 
rem
column sid            heading Sid
column event          heading Event            format a40
column total_waits    heading Total|Waits
column total_timeouts heading Total|Timeouts
column time_waited    heading Time|Waited
column average_wait   heading Average|Wait
column username       heading User
break on username
start title132 "Session Events By User"
spool rep_out\&db\events
set lines 132 pages 59
select 
	nvl(username,'SYS') username, event, sum(total_waits) total_waits, 
        sum(total_timeouts) total_timeouts,
	sum(time_waited) time_waited, avg(average_wait) average_wait 
from 
	sys.v_$session_event a, sys.v_$session b
where 
	a.sid= b.sid
and event not like 'SQL*Net%'
	and event not like 'smon%'
	and event not like 'pmon%'
	and event not like 'rdbms%'
	and event not like '%control%'
	and event not like 'LGWR%'
        and event not like 'PX%'
group by nvl(username,'SYS'),event
order by 1,5 desc; 
spool off
pause Press enter to continue
clear columns
clear breaks
set lines 80 pages 22
ttitle off
