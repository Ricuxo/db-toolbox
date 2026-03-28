set linesize 135
select optimizer_mode,first_load_time,executions,buffer_gets,disk_reads,sql_text,HASH_VALUE from v$sqlarea where address='&addr'
/
