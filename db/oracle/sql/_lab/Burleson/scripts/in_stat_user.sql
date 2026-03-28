/*  */
rem  NAME: IN_STAT.sql     
rem
rem  FUNCTION: Report on index statistics
rem  INPUTS:    1 = Index owner    2 = Index name
rem
#def iowner = '&OWNER'
def iname  = '&INDEX'
set pages 56 lines 130 verify off feedback off
column user                   format a10            heading "Owner"
column index_name              format a21            heading "Index"
column status                  format a7             heading "Status"
column blevel                  format 9,999,999      heading "Tree Level"
column leaf_blocks             format 999,999,999    heading "Leaf Blk"
column distinct_keys           format 99,999,999,999 heading "# Keys"
column avg_leaf_blocks_per_key format 999,999,999    heading "Avg. LB/Key"
column avg_data_blocks_per_key format 999,999,999    heading "Avg. DB/Key"
column clustering_factor       format 99,999,999,999 heading "Clstr Factor"
rem
start title132 "Index Statistics Report"
spool rep_out\&db\ind_stat
rem
select  user, index_name, status, blevel, leaf_blocks,
	distinct_keys, avg_leaf_blocks_per_key,
	avg_data_blocks_per_key, clustering_factor
from user_indexes
where
index_name like upper('&&iname')
and leaf_blocks>0
order by 1,2;
rem
spool off
set pages 22 lines 80 verify on feedback on
clear columns
undef iowner
undef iname
undef owner
undef name
ttitle off
