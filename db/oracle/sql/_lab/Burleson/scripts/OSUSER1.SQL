/*  */
rem
rem Name: OSUSER1.SQL
rem
rem Function: Provide list of SID, System PID and username for
rem Function: current oralce users
rem
ttitle 'Oracle System Users'
set lines 132 pages 0
spool osuser
select a.sid,b.spid,a.username,a.osuser
from v$session a, v$process b
where a.paddr=b.addr (+)
/
spool off
ttitle off
clear columns
