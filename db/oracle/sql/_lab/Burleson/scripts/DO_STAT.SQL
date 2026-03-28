/*  */
REM NAME:     DO_STAT.SQL
rem FUNCTION: DONT RUN THIS UNLESS YOU WANT
rem           ALL TABLES ANALYZED SINCE IT WILL 
rem           LOAD TABLE STATS AND THIS MAY CAUSE 
rem           PROBLEMS WITH OPTIMIZER
rem
set pages 0 
rem set feedback off 
rem set echo off termout off 
rem set verify off
spool run_stat.sql
select 'analyze table '||owner||'.'||table_name||
' estimate statistics;' from dba_tables where owner not in ('SYS','SYSTEM');
spool off
start run_stat.sql
ho del run_stat.sql;*
