set pagesize 9999
set linesize 160

COLUMN TABLE FORMAT a50
COLUMN PART_NAME FORMAT a30
COLUMN SUB_PART_COUNT FORMAT a14
COLUMN TABLESPACE_NAME FORMAT a30
COLUMN LOGGING FORMAT a6
COLUMN LAST_ANALYZED FORMAT a20

alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';

select table_owner||'.'||table_name "TABLE"
     , dtp.partition_name PART_NAME
     , dtp.subpartition_count
     , dtp.tablespace_name
     , dtp.logging
     , to_char(dtp.last_analyzed, 'dd/mm/yyyy hh24:mi:ss') last_analyzed
  from dba_tab_partitions dtp
 where dtp.table_owner = NVL('&OWNER', dtp.table_owner)
   and dtp.table_name = NVL('&TABLE_NAME', dtp.table_name)
/
