/*  */
rem name: backup.sql
rem FUNCTION: Show database datafile Archive status
rem
column name format a43
column arc heading 'Backup Status'
set lines 132 pages 59 feedback off
start title132 "Database File Backup Status"
spool rep_out\&db\file_bup
select name, a.status,decode(b.status,'Active','Backup','Normal') arc, enabled, bytes, change#,time Archive from
sys.v_$datafile a, sys.v_$backup b where
a.file#=b.file#;
spool off
clear columns
ttitle off
pause press enter to continue


