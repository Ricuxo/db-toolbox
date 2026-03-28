/*  */
rem
rem FUNCTION: Document current internal locks
rem
column username format a10 heading 'Lock|Holder'
column session_id heading 'User|SID'
column lock_type format a27 heading 'Lock Type'
column mode_held format a10 heading 'Mode|Held'
column mode_requested format a10 heading 'Mode|Requested'
column lock_id1 format a30 heading 'Lock/Cursor|ID1'
column lock_id2 format a10 heading 'Lock|ID2'
prompt 'ALL is all types or modes'
accept lock prompt 'Enter Desired Lock Type: '
accept mode prompt 'Enter Lock Mode: '
set lines 132 pages 59 feedback off echo off verify off
break on username
start title132 'Report on Internal Locks Mode: &mode Type: &lock'
spool rep_out\&db\int_locks
select /*+ rule */
	nvl(b.username,'SYS') username, 
	session_id,lock_type,mode_held,
	mode_requested,lock_id1,lock_id2
from
	sys.dba_lock_internal a, sys.v_$session b
where
	upper(mode_held) like upper('%&mode%') or 
	upper('&mode')='ALL' and
	upper(lock_type) like upper('%&lock%') or
	upper(mode_held) like upper('%&mode%') or
	upper('&mode')='ALL' and
	upper('&lock')='ALL' and
	a.session_id=b.sid 
order by 1,2
/
spool off
pause press enter/return to continue
set lines 80 pages 22 feedback on echo on verify on
clear columns
clear breaks
undef lock
undef mode
