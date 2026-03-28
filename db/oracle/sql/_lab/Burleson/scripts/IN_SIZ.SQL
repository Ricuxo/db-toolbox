/*  */
rem
rem in_siz.sql
rem
rem FUNCTION: Report on default sizing for indexes
rem
rem MRA 9/18/96
rem
column index_name format a20 heading Index
column owner format a10 heading Owner
column tablespace_name format a10 heading Tablespace
column initial_extent heading "Init|Ext"
column next_extent heading "Next|Ext"
column pct_increase format 9990 heading "%|Incr"
column pct_free format 9999 heading "%|Free"
column ini_trans format 9999 heading "Init|Trans"
column max_trans format 9999 heading "Max|Trans"
column min_extents format 9999 heading "Min|Ext"
column max_extents format 9999 heading "Max|Ext"
break on owner on tablespace_name
set lines 132 pages 57 feedback off
start title132 "Index Sizing Data"
spool rep_out/&db/in_siz.lis
select 
	owner,
	index_name,
	tablespace_name,
	initial_extent, 
	next_extent,
	pct_increase,
	pct_free,
	ini_trans,
	max_trans,
	min_extents,
	max_extents 
from 
	dba_indexes
where
	owner not in ('SYS','SYSTEM')
order by
	owner,
	tablespace_name,
	index_name
/
spool off
