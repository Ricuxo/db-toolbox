/*  */
rem
rem FUNCTION: Get all of a tables comments
rem
set heading off pages 0 verify off feedback off termout off
spool do_tabhp.sql 
select
 unique 'execute table_help('||''''||owner||''''||','||''''||table_name||''''||');'
 from dba_col_comments where owner='&OWNER' and length(comments)>0;
spool off
set echo off lines 132
set serveroutput on size 4000
spool comments.lis 
start do_tabhp.sql
spool off
host del do_tabhp.sql
set heading on pages 22 verify on feedback on termout on lines 80


