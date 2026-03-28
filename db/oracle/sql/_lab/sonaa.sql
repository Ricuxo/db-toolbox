Rem
Rem    NOME
Rem      sonaa.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica o processo do SONAA.
Rem      
Rem    UTILIZAÇÃO
Rem      @sonaa <object>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       09/04/09 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off


PROMPT
PROMPT --> Verificar se a trigger está ENABLED

col OWNER            for a8
col STATUS           for a7
col TRIGGER_NAME     for a35
col TRIGGERING_EVENT for a20
col TABLE_OWNER      for a12
col TABLE_NAME       for a15

select OWNER, 
       STATUS,
       TRIGGER_NAME, 
       TRIGGER_TYPE, 
       TRIGGERING_EVENT, 
       TABLE_OWNER, 
       TABLE_NAME
from dba_triggers
where OWNER = 'SYSADM'
  and TRIGGER_NAME = 'TRG_ACC_TICKLER_RECORDS_INS_01'
/


PROMPT
PROMPT
PROMPT --> Verificar a situação da fila na tabela: SONAA001.AA_EVENT_QTAB

select count(*) from sonaa001.aa_event_qtab
/


PROMPT
PROMPT
PROMPT --> Verificar se o processo que consome a fila está conectado

SELECT a.sid,
       a.serial#,
       b.spid,
       a.process,
       a.sql_address,
       a.sql_hash_value,
       a.username,
       a.status,
       to_char(a.logon_time,'dd/mm/yyyy hh24:mi:ss') dtr,
       round((a.last_call_et/60),0) LAST_CALL_ET__MIN,
       a.program,
       a.prev_hash_value,
       a.module,
       a.machine,
       a.osuser,
       'alter system kill session '''||a.sid||','||a.serial#||''' immediate;' as "Kill Session"
FROM   v$session a, v$process b
WHERE  a.paddr    = b.addr
AND    a.username = upper('sonaa001')
ORDER BY 7, dtr ASC
/


PROMPT

set feedback on
