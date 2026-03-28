/*  */
rem
rem FUNCTION: Report Stored Object Statistics
rem
column owner format a11 heading Schema
column name format a30 heading Object|Name
column namespace format a15 heading Name|Space
column type format a10 heading Object|Type
column kept format a4 heading Kept
column sharable_mem format 9,999,999 heading Shared|Memory
column executions format 999,999 heading Executes
break on report
compute sum of sharable_mem on report
set lines 132 pages 47 feedback off
@title132 'Oracle Kept Objects Report'
break on owner on namespace on type on report
spool rep_out/&db/o_stat
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
	type not in ('NOT LOADED','NON-EXISTENT','SEQUENCE','PACKAGE BODY')
	and kept='YES'
order by owner,namespace,type,executions desc;
spool off
set lines 80 pages 22 feedback on
clear columns
clear breaks
clear computes
clear breaks
ttitle off
rem        and owner not in ('SYS','SYSTEM','DBAUTIL')
