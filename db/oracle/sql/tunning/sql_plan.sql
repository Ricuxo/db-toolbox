col LAST_LOAD_TIME form a20
set verify off
set feed off
set long 100000
set pages 1000
select distinct dbms_lob.substr(sql_fulltext,2000,1) text from gv$sql where sql_id='&1';
prompt
prompt Plano Atual
prompt ===========
select inst_id,SQL_ID,ADDRESS, PLAN_HASH_VALUE,OLD_HASH_VALUE,CHILD_NUMBER,LAST_LOAD_TIME,LAST_ACTIVE_TIME,executions exec, round((ELAPSED_TIME/1000000)/decode(EXECUTIONS,0,1,EXECUTIONS),4) "ELA/EXE", SQL_PROFILE
from gv$sql
where sql_id='&1'
order by 1,8
/
prompt
prompt Historico do Plano
prompt ==================

@sql_plan_hist '&1'

set verify on
set feed on
