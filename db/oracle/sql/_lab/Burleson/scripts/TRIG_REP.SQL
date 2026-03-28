/*  */
rem
rem  NAME       :  trig_rep.sql
rem  FUNCTION   :  Report on all triggers and their status
rem
column owner            format a10
column trigger_name     format a20      heading "Trigger"
column trigger_type     format a20      heading "Type"
column triggering_event format a10      heading "Event"
column table            format a40      heading "Trigger Table"
rem
break on owner
set verify off  feedback off lines 130 pages 58 
start title132 "Trigger Status Report"
spool  rep_out\&db\trg_stat
rem
Select  owner, 
	trigger_name,
	trigger_type,
	triggering_event,
	table_owner||'.'||table_name "Table", 
	status 
from dba_triggers
where owner=upper('&trigger_owner')
order by 1,5,2;
spool off
clear columns 
clear breaks
set verify on  feedback on lines 80 pages 22
ttitle off
