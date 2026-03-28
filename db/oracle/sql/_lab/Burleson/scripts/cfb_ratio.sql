/*  */
column table_name format a20 heading 'Table|Name'
column index_name format a20 heading 'Index|Name'
column dirty_blocks heading 'Dirty|Blocks'
column clustering_factor heading 'Clustering|Factor'
column cfb_ratio heading 'Clustering Factor|To Blocks Ratio' format 99,999.99
column owner format a15 heading 'Owner'
@title132 'Clustering Factor to Block Ratio Report'
set lines 132 verify off pages 55 feedback off
break on owner on table_name 
spool rep_out/&&db/cfb_ratio
select t.owner,t.table_name,i.index_name, t.num_rows, t.blocks dirty_blocks,i.clustering_factor,
i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks) cfb_ratio, i.blevel
from dba_tables t, dba_indexes i
where t.owner=i.table_owner and t.table_name=i.table_name
and t.owner not in ('SYS','SYSTEM','DBAUTIL','OUTLN','DBSNMP','SPOTLIGHT','PERFSTAT','RMAN','IWATCH')
order by t.owner,i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks) desc,t.table_name,i.index_name
/
spool off
set lines 80 pages 22 feedback on verify on
clear columns
ttitle off

rem and i.clustering_factor/decode(t.blocks,0,decode(i.clustering_factor,0,1,i.clustering_factor),t.blocks)>10
