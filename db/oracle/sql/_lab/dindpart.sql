set pagesize 9999
set linesize 165
set linesize 160
col owner format a30
col index format a30
col partition format a30
col logging format a7
col degree format a15
col status format a8
col last_analyzed format a20
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';

select s.index_owner owner
     , s.index_name "INDEX"
     , s.partition_name "PARTITION"
     , s.status
     , s.logging
     , e.degree
     , s.last_analyzed
  from dba_ind_partitions s
     , dba_indexes e
 where e.index_name = s.index_name
   and e.owner = s.index_owner
   and e.table_owner like nvl('&LOWNER', e.table_owner)
   and e.table_name like nvl('&LTABLE_NAME', e.table_name)
   and e.index_name like nvl('&LINDEX_NAME', e.index_name)
 order by s.index_owner, s.index_name, partition_position
/
