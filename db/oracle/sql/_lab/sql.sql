set lines 200
set pages 10000
undef HASH_VALUE

select BUFFER_GETS/decode(EXECUTIONS,0,1,EXECUTIONS) bufexec,EXECUTIONS,ELAPSED_TIME,DISK_READS,BUFFER_GETS,round(cpu_time/1000000,2) cpu_time
,SHARABLE_MEM,PARSING_USER_ID,ADDRESS,HASH_VALUE,first_load_time
from v$sqlarea
where HASH_VALUE in (&&HASH_VALUE);

column sql_text heading 'sql_text' format a120
SELECT sql_text FROM V$SQLTEXT 
WHERE HASH_VALUE in (&&HASH_VALUE) 
ORDER BY PIECE;

undef HASH_VALUE
