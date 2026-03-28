/*  */
rem
rem FUNCTION: Report On Objects Which Should Be Kept
rem
column owner format a11 heading Schema
column name format a22 heading 'Should Keep|Object Name'
column namespace format a15 heading Name|Space
column type heading Object|Type format a15
column kept format a4 heading Kept
column sharable_mem format 999,999 heading Shared|Memory
column executions format 9,999,999 heading Executes
set lines 132 pages 47 feedback off
@title132 'Oracle Should Keep Report'
break on owner on namespace on type
spool rep_out/&db/should_keeps
select  
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
	type not in ('NOT LOADED','NON-EXISTENT','VIEW','TABLE','INVALID TYPE','CURSOR')
	and executions>loads and executions>1 and kept='NO'
order by loads,owner,namespace,type,executions desc;
spool off
set lines 80 pages 22 feedback on
clear columns
clear breaks
ttitle off
