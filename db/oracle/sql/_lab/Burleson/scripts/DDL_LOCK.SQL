/*  */
rem
rem Function: Document DDL Locks currently in use
rem
column owner format a15 heading 'User'
column session_id heading 'SID'
column mode_held format a20 heading 'Lock Mode|Held'
column mode_requested format a20 heading 'Lock Mode|Requested'
column type heading 'Type|Object' format a15
column name heading 'Object|Name' format a20
set feedback off echo off pages 59 lines 131
start title132 'Report on All DDL Locks Held'
spool rep_out\&db\ddl_lock
select nvl(owner,'SYS') owner,session_id,name,type,
mode_held,mode_requested
from  sys.dba_ddl_locks
where mode_held !='Null'
order by 2
/
spool off
pause press enter/return to continue 
clear columns
set feedback on pages 22 lines 80
ttitle off
