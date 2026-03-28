col COMP_ID for a10
col COMP_NAME for a40
col VERSION for a15
set lines 180
set pages 999
select COMP_ID,COMP_NAME,VERSION,STATUS from dba_registry order by status;