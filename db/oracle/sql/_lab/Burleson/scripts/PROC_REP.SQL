/*  */
rem
rem FUNCTION: Report on Object status
rem
set pages 53 lines 80 verify off feedback off echo off
column owner format a10
column name format a30
column type format a9 word_wrapped
column status format a7
column lines format 9,999
break on owner skip page on type
start title80 "Report on Stored Code"
spool rep_out\&db\procs
select 
	b.owner owner,
	b.object_type type,
	b.object_name name,
	b.status status,
	b.last_ddl_time Modified,
	lines 
from dba_objects b, proc_count a
where b.owner not in ('SYS','SYSTEM')
and b.owner=a.owner 
and b.object_type=a.type 
and b.object_name=a.name
order by 1,2,3
/
spool off
pause Press enter to continue
set pages 22 lines 80 verify on feedback on echo on
clear breaks
clear columns
ttitle off
