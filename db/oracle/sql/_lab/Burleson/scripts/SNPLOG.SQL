/*  */
rem
rem Name:       snplog.sql
rem FUNCTION:   Report on database Snapshot Logs
rem Use:        From an account that accesses DBA_ views
rem
rem
set pages 56 lines 130 feedback off
start title132 "Snapshot Log Report"
spool rep_out\&db\snap_log
rem
column log_owner        format a15      heading "Owner"
column master           format a27      heading "Master"
column log_table        format a27      heading "Snapshot"
column log_trigger      format a20      heading "Trigger Name"
column current_snapshots                heading "Last Refresh"
rem
select 
	log_owner, 
	master, 
	log_table, 
	log_trigger, 
	current_snapshots
from 
dba_snapshot_logs
order by 1;
rem
spool off
pause Press enter to continue
set pages 22 lines 80 feedback on
clear columns
ttitle off
