/*  */
col table_name format a30 heading 'Table|Name'
col last_analyzed format a18 heading 'Last|Analyzed'
col owner format a13 heading 'Owner'
col last_ddl_time format a18 heading 'Last DDL|Date'
@title80 'DDL Verses Analyzed'
set lines 90 pages 55
spool rep_out\&db\ddl_anal
select 
  t.owner, t.table_name, 
  to_char(trunc(t.last_analyzed),'dd-mon-yyyy hh24:mi') last_analyzed, 
  to_char(trunc(o.last_ddl_time),'dd-mon-yyyy hh24:mi') last_ddl_time 
from 
  dba_tables t, dba_objects o 
where
   t.owner not in
   ('SYS','SYSTEM','DBAUTIL','OUTLN','SCOTT','RMAN','WEBDB','DBSNMP','OAS_PUBLIC','PUBLIC','PERFSTAT')
   and t.table_name=o.object_name 
   and t.owner=o.owner
   and t.last_analyzed is not null
   and to_char(trunc(t.last_analyzed),'dd-mon-yyyy')!=to_char(trunc(o.last_ddl_time),'dd-mon-yyyy')
/
spool off
ttitle off
set pages 22 lines 80
