/*  */
rem
rem NAME:     log_file.sql
rem
rem FUNCTION: Report on Redo Logs Physical files
rem 
rem
column group#  format 999999
column  member format a40
column meg format 999,999
set lines 80 pages 60 feedback off verify off
start title80 'Redo Log Physical Files'
break on group#
spool rep_out\&db\rdo_file
select a.group#,a.member,b.bytes,b.bytes/(1024*1024) meg 
from sys.v_$logfile a,
sys.v_$log b
where a.group#=b.group#
order by group#
/
spool off
clear columns
clear breaks
ttitle off
set pages 22 feedback on verify on
pause Press enter to continue
