/*  */
rem Name		:	clu_typ.sql
rem Purpose		:	Report on new DBA_CLUSTER columns
rem Use		:	From an account that accesses DBA_ views
rem
column owner 			format a10 	heading "Owner"
column cluster_name 		format a15 	heading "Cluster"
column tablespace_name 	format a10 	heading "Tablespace"
column avg_blocks_per_key 	format 999999 	heading "Blocks per Key"
column cluster_type 		format a8 	Heading "Type"
column function 		format 999999 	heading "Function"
column hashkeys 		format 99999 	heading "# of Keys" 
set pages 56 lines 131 feedback off
start title132 "Cluster Type Report"
spool rep_out\&db\clu_type
select 
	owner,
	cluster_name,
	tablespace_name,
	avg_blocks_per_key, 
	cluster_type, 
	function,
	hashkeys
from 
	dba_clusters
order by 2
/
spool off
set pages 22 lines 80 feedback on
clear columns
ttitle off

