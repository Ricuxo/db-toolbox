/*  */
REM ********************************************************************
REM Locks v.1.01				                27/05/96
REM This query will list locking conflicts between tables
REM and indicate users who are locking the tables and
REM there waited users. Must be run as SYS
REM Sanjeev Parikh
REM ********************************************************************

set headingsep ='|'
set lines 160
set pagesize 20

ttitle 'Database Locking Conflict Report'
btitle 'Mode Held = indicates the user holding the lock|Mode Request = indicates the user waiting on the later to finish to establish lock||** End of Locking Conflict Report **'

column username 	format a10	heading 'User'
column terminal 	format a15	heading 'Application|PC'
column object 		format a15	heading	'Table'
column sql  		format a15	heading 'SQL'
column sid 		format 999	heading 'SID'
column lock_type 	format a15	heading 'Lock|Type'
column mode_held 	format a11	heading 'Mode|Held'
column mode_requested 	format a10	heading 'Mode|Request'
column lock_id1 	format a8	heading 'Lock ID1'
column lock_id2 	format a8	heading 'Lock ID2'
column first_load_time  format a19	heading 'Requested'
 
break on lock_id1

select a.sid,
       username, 
       terminal,
       decode(a.type,'MR', 'Media Recovery',
   		     'RT', 'Redo Thread',
		     'UN', 'User Name',
		     'TX', 'Transaction',
		     'TM', 'DML',
		     'UL', 'PL/SQL User Lock',
		     'DX', 'Distributed Xaction',
  		     'CF', 'Control File',
		     'IS', 'Instance State',
		     'FS', 'File Set',
		     'IR', 'Instance Recovery',
		     'ST', 'Disk Space Transaction',
		     'IR', 'Instance Recovery',
		     'ST', 'Disk Space Transaction',
		     'TS', 'Temp Segment',
		     'IV', 'Library Cache Invalidation',
		     'LS', 'Log Start or Switch',
		     'RW', 'Row Wait',
		     'SQ', 'Sequence Number',
		     'TE', 'Extend Table',
		     'TT', 'Temp Table', a.type) lock_type,
   	decode(a.lmode,0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.lmode)) mode_held,
   decode(a.request,
   0, 'None',           /* Mon Lock equivalent */
   1, 'Null',           /* N */
   2, 'Row-S (SS)',     /* L */
   3, 'Row-X (SX)',     /* R */
   4, 'Share',          /* S */
   5, 'S/Row-X (SSX)',  /* C */
   6, 'Exclusive',      /* X */
   to_char(a.request)) mode_requested,
   to_char(a.id1) lock_id1, to_char(a.id2) lock_id2,
   c.object object,
   d.sql_text sql,
   e.first_load_time
from v$lock a, v$session, v$access c, v$sqltext d, v$sqlarea e
   where (id1,id2) in
     (select b.id1, b.id2 from v$lock b where b.id1=a.id1 and
     b.id2=a.id2 and b.request>0) and
     a.sid = v$session.sid and
     a.sid = c.sid and
     d.address = v$session.sql_address and
     d.hash_value = v$session.sql_hash_value and
     d.address = e.address
order by a.id1, a.lmode desc
