/*  */
rem
rem FUNCTION: Report Stored Object Statistics
rem
column owner format a11 heading Schema
column name format a20 heading Object|Name 
column namespace heading Name|Space format a10
column type heading Object|Type format a15
column kept format a4 heading Kept
column sharable_mem format 999,999 heading Shared|Memory
column executions format 999,999 heading Executes
set lines 132 pages 47 feedback off
@title132 'Oracle Objects Report'
break on owner on namespace on type
spool rep_out/&db/o_stat
select * from (select  
	OWNER, 
	NAMESPACE,
	TYPE,
	NAME,
	SHARABLE_MEM,
	LOADS,  
	EXECUTIONS,   
	LOCKS,    
	PINS,
	KEPT
from 
	v$db_object_cache
where 
	type not in ('NOT LOADED','NON-EXISTENT')
and kept='YES'
order by owner,namespace,type,loads,executions desc);
spool off
set lines 80 pages 22 feedback on
clear columns
clear breaks
ttitle off
