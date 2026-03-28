/*  */
rem
rem Function: Create a compile list for invalid objects
rem
rem MRA 5/1/96
rem
set heading off pages 0 echo off termout off feedback off verify off
spool recompile.sql
select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)||' '||owner||'.'||object_name||' compile;'
from dba_objects where status='INVALID'
/
spool off
set heading on echo on termout on feedback on verify on
undef cr
