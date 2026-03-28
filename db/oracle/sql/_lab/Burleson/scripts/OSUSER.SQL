/*  */
rem
rem Name: OSUSER.SQL
rem
rem Function: Provide list of SID, System PID and username for
rem Function: current oralce users
rem
start title132 'Oracle System Users'
set lines 132 pages 0
spool rep_out/&db/osuser
select a.sid,b.spid,a.username,a.osuser
from v$session a, v$process b
where a.paddr=b.addr (+)
/
spool off
ttitle off
clear columns
