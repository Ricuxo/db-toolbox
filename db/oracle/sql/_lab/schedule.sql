Rem
Rem    NOME
Rem      schedule.sql  
Rem
Rem    DESCRIÇÃO
Rem      Lista os jobs schedulados no Banco Oracle.
Rem      
Rem    UTILIZAÇÃO
Rem      @schedule
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      09/01/09 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

--
col OWNER for a12
col PROGRAM_NAME for a25
col START_DATE for a20
col END_DATE for a20
col REPEAT_INTERVAL for a100
--
select OWNER,  
       JOB_NAME, 
       PROGRAM_NAME, 
       JOB_TYPE, 
       STATE, 
       to_char(START_DATE,'dd/mm/yy hh24:mi:ss') START_DATE,
       to_char(END_DATE,'dd/mm/yy hh24:mi:ss') END_DATE,
       to_char(LAST_START_DATE,'dd/mm/yy hh24:mi:ss') LAST_START_DATE,
       to_char(LAST_RUN_DURATION,'dd/mm/yy hh24:mi:ss') LAST_RUN_DURATION,
       to_char(NEXT_RUN_DATE,'dd/mm/yy hh24:mi:ss') NEXT_RUN_DATE,
       SCHEDULE_TYPE,
       REPEAT_INTERVAL,
       FAILURE_COUNT,
       SYSTEM as SYS_JOB     
from DBA_SCHEDULER_JOBS;


--
set heading ON
select decode(count(*), 0,'Não há') || ' jobs.'
from DBA_SCHEDULER_JOBS;
--
prompt
--
