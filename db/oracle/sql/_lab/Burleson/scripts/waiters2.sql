/*  */
rem
rem FUNCTION: Report on sessions waiting for locks
rem
column busername format a10 heading 'Holding|User'
column wusername format a10 Heading 'Waiting|User'
column bsession_id heading 'Holding|SID'
column wsession_id heading 'Waiting|SID'
column mode_held format a20 heading 'Mode|Held'
column mode_requested format a20 heading 'Mode|Requested'
column lock_id1 format a20 heading 'Lock|ID1'
column lock_id2 format a20 heading 'Lock|ID2'
column type heading 'Lock|Type'
set lines 132 pages 59 feedback off echo off
ttitle 'Processes Waiting on Locks Report'
spool waiters
select 
	holding_session bsession_id, 
	waiting_session wsession_id, 
	b.username busername, 
	a.username wusername, 
	c.lock_type type, 
	mode_held, mode_requested,
	lock_id1, lock_id2 
from
sys.v_$session b, sys.dba_waiters c, sys.v_$session a 
where
c.holding_session=b.sid and
c.waiting_session=a.sid
/
spool off
pause press enter/return to continue
clear columns
set lines 80 pages 22 feedback on echo on
ttitle off
