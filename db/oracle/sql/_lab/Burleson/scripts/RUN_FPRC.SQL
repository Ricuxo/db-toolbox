/*  */
REM
REM NAME        : RUN_FPRC.SQL 
REM FUNCTION    : Generate and execute the exe_fprc.sql procedure
REM USE         : Document the procedures and packages and functions
REM               for a user or users
REM Limitations : Must have access to dba_source and dba_objects.
rem               The FPRC_RCT.SQL procedure must be in same directory
REM
set termout on
column dbname new_value db noprint
pause Use % for a wildcard - Press enter to continue
accept owner prompt 'Enter object owner:'
accept type  prompt 'Enter object type:'
accept name  prompt 'Enter object name:'
prompt Working....
set echo off heading off verify off feedback off
select value dbname from v$parameter where name='db_name';
spool rep_out\&db\do_fprc.sql
select unique('start fprc_rct '||a.owner||' '||'"'||a.type||'"'||' '||a.name)
from 
	dba_source a, dba_objects b
where
	a.owner like upper('&owner') and
	a.type like upper('&type') and
	a.name like upper('&name')
	and a.owner=b.owner and
	a.type=b.object_type and
	a.name=b.object_name;
spool off
set termout off 
spool rep_out\&db\exe_fprc.sql
start rep_out\&db\exe_fprc.sql
spool off
undef owner
undef type
undef name
clear columns
set echo on heading on verify on feedback on
