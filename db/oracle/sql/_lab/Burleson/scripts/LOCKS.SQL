/*  */
rem
rem FUNCTION: Report all DB locks
rem
column osuser format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
column lock_id1 format a10 heading 'Lock|ID1'
column lock_id2 format a10 heading 'Lock|ID2'
column type heading 'Type|Lock'
set feedback off echo off pages 59 lines 131
start title132 'Report on All Locks'
spool rep_out\&db\locks
select nvl(a.osuser,'SYS') osuser,b.session_id,type,
mode_held,mode_requested,
lock_id1,lock_id2
from sys.v_$session a, sys.dba_locks b
where
a.sid=b.session_id
order by 2
/
spool off
pause press enter/return to continue 
clear columns
set feedback on echo on pages 22 lines 80
