/*  */
rem
rem Name:     log_stat.sql
rem
rem FUNCTION: Provide a current status for redo logs
rem 
rem
column first_change# format 999,999,999  heading Change#
column group#        format 9,999     heading Grp#
column thread#       format 999       heading Th#
column sequence#     format 999,999   heading Seq#
column members       format 999       heading Mem
column archived      format a4        heading Arc?
COLUMN first_time    format a25       HEADING First|Time
break on thread#
set pages 60 lines 132 feedback off 
start title132 'Current Redo Log Status'
spool rep_out\&db\log_stat
select thread#, group#, sequence#,
bytes, members,archived,status,first_change#,
to_char(first_time,'dd-mon-yyyy hh24:mi') first_time
 from sys.v_$log
order by thread#, group#;
spool off
pause Press Enter to continue
set pages 22 lines 80 feedback on
clear breaks 
clear columns
ttitle off
