/*  */
REM
REM NAME         : view_rep.sql
REM FUNCTION     : report on database views by owner
REM USE          : Generate a report on database views
REM
REM Limitations    If your view definitions are greater than 2000 characters
REM                then increase the set long. This can be determined by
REM                querying the DBA_VIEWS table's text_length column for the
REM                max value: select max(text_length) from dba_views;
REM
set pages 59 lines 131 feedback off echo off
column text             format a75
column owner            format a20
column view_name        format a20
column status           format a7
set long 2000
start title132 "Database Views Report"
spool rep_out\&db\view_rep
select 
	v.owner,
	v.view_name,
	v.text,
	o.status 
from 
	dba_views v, 
	dba_objects o
where 
	v.owner like upper('%&owner_name') and
	o.owner = v.owner and
	o.object_type = 'VIEW' and
	o.object_name = v.view_name
order by 
	o.status, 
	v.view_name;
spool off
set pages 22 lines 80 feedback on echo on
clear columns
ttitle off
Pause Press enter to continue
