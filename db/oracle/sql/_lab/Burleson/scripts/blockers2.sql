/*  */
rem NAME: blockers.sql
rem FUNCTION: Show all processes causing a dead lock
rem HISTORY: MRA 1/15/96 Created
rem
COLUMN username 		FORMAT a10 	HEADING 'Holding|User'
COLUMN session_id 				HEADING 'SID'
COLUMN mode_held 		FORMAT a20 	HEADING 'Mode|Held'
COLUMN mode_requested 	FORMAT a20 	HEADING 'Mode|Requested'
COLUMN lock_id1 		FORMAT a20 	HEADING 'Lock|ID1'
COLUMN lock_id2 		FORMAT a20 	HEADING 'Lock|ID2'
COLUMN type 					HEADING 'Lock|Type'
COLUMN program			FORMAT a15	HEADING 'Executing|Program'
SET LINES 132 PAGES 59 FEEDBACK OFF ECHO OFF
ttitle 'Sessions Blocking Other Sessions Report'
SPOOL blockers
SELECT 
	a.session_id, 
	username, 
	type, 
	mode_held, 
	mode_requested,
	lock_id1, 
	lock_id2 
FROM
	sys.v_$session b, 
	sys.dba_blockers c, 
	sys.dba_lock a
WHERE
	c.holding_session=a.session_id and
	c.holding_session=b.sid
/
SPOOL OFF
PAUSE press enter/return to continue
CLEAR COLUMNS
SET LINES 80 PAGES 22 FEEDBACK ON 


