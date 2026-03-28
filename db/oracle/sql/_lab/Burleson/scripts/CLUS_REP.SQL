/*  */
rem
rem Name: clus_rep.sql
rem
rem FUNCTION: Generate a report on database clusters
rem         : showing cluster, tablespace, tables, and column data
rem MRA RevealNet 10/23/95
rem
column owner             format a10
column cluster_name      format a15 heading "Cluster"
column tablespace_name   format a20 heading "Tablespace"
column table_name        format a20 heading "Table"
column tab_column_name   format a20 heading "Table Column"
column clu_column_name   format a20 heading "Cluster Column"
set pages 56 lines 130 feedback off
start title132 "Cluster Report"
break on owner on tablespace_name on cluster_name on table_name
spool rep_out\&db\cluster
select a.owner,tablespace_name,a.cluster_name,
table_name,tab_column_name,clu_column_name
from dba_clusters a,dba_clu_columns b
where
a.cluster_name=b.cluster_name
order by 1,2,3,4
/
spool off
pause Press enter to continue
ttitle off
clear columns
clear breaks
exit

