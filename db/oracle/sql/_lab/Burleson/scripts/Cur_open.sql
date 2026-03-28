/*  */
REM: Report on open cursors
REM: shows first 60 of text only
REM: Valid for 7.3 and 8.0
column username format a20 heading 'User'
column sql_text format a60  heading 'Cursor text'
column address heading 'Address'
column time heading 'Elapsed Time'
set lines 131 pages 45
start title132 'Currently Open Cursors'
spool rep_out\&&db\cur_open.lst
select s.username, c.sql_text, c.address, last_call_et time
from v$open_cursor c, v$session s
where s.status = 'ACTIVE' and
c.sid = s.sid and
s.osuser <> 'oracle'
order by time desc, c.address desc, username;
spool off
ttitle off

