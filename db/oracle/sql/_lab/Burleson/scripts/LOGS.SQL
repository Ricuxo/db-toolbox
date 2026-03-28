/*  */
rem Name:     log.sql
rem
rem FUNCTION: Provide a report on redo log history
rem 
rem
break on thread#
prompt enter report start date (dd-mon-yy):
accept st_date
start title80 'Redo Log Activity Report'
set lines 80 pages 60 feedback off verify off
spool rep_out\&db\log_hist
select thread#,sequence#,first_change#,first_time first_time,switch_change#  from sys.v_$loghist
where to_date(first_time,'mm/dd/yy hh24:mi:ss') >= '&st_date' 
order by thread#,sequence#
/
spool off
clear breaks 
undef st_date
set pages 22 feedback on verify on
pause Press enter to continue

