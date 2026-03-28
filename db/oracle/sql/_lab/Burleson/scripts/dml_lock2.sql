/*  */
rem
rem FUNCTION: Document DML locks currently in use
rem
column owner format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
set feedback off echo off pages 59 lines 131
ttitle 'Report on All DML Locks Held'
spool dml_lock
select nvl(owner,'SYS') owner,session_id,name,
mode_held,mode_requested
from  sys.dba_dml_locks
order by 2
/
spool off
pause press enter/return to continue
clear columns
set feedback on echo on pages 22 lines 80
ttitle off
exit
