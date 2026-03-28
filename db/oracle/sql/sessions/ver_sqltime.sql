set line 1000
col SQL_PROFILE for a20
col SQL_PLAN_BASELINE for a20
col LAST_ACTIVE_TIME for a30



select inst_id,
       sql_id, 
       CHILD_NUMBER, 
       to_char(LAST_ACTIVE_TIME,'dd/mm/yyyy hh24:mi:ss') LAST_ACTIVE_TIME, 
       SQL_PROFILE, 
       SQL_PLAN_BASELINE, 
       (ELAPSED_TIME/1000000)/EXECUTIONS AVG_ELAP_TIME, 
       PLAN_HASH_VALUE,
       ROWS_PROCESSED,
       ELAPSED_TIME/1000000 ELAPSED_TIME,
       BUFFER_GETS/EXECUTIONS BUFFERGET_PEXEC,
       EXECUTIONS
  from Gv$sql 
 where sql_id='&1'
and EXECUTIONS > 0
order by LAST_ACTIVE_TIME desc
/

undefine 1
