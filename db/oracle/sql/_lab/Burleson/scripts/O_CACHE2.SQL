/*  */
rem
rem FUNCTION: Report on "bad" objects
rem
rem
column owner format a10 heading Schema
column name format a20 heading Object|Name
column namespace heading Name|Space format a10
column type heading Object|Type format a10
column kept format a4 heading Kept
column sharable_mem format 999,999 heading Shared|Memory
column executions format 9,999 heading Executes
set lines 132 pages 47 feedback off
@title132 'Oracle Objects Report'
break on owner on namespace on type
spool rep_out/&db/o_stat2
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
	type in ('NOT LOADED','NON-EXISTENT')
order by owner,namespace,type,executions desc) 
where rownum<101;
spool off
clear columns
clear breaks
set lines 80 pages 22 feedback on
