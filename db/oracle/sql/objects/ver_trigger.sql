Rem
Rem    NOME
Rem      trig.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe informações uma determinada trigger.
Rem
Rem    UTILIZAÇÃO
Rem      @trig <owner> <trigger_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      LUIZ NORONHA      14/06/10 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------



COL triggering_event FOR a20
COL enable_command   FOR a100
COL disable_command  FOR a100
set verify off

select owner, 
       trigger_name, 
       trigger_type, 
       TRIM(triggering_event) triggering_event,
       status,
       'ALTER TRIGGER ' || owner || '.' || trigger_name || ' enable;' enable_command,
       'ALTER TRIGGER ' || owner || '.' || trigger_name || ' disable;' disable_command       
from dba_triggers
where UPPER(OWNER) = upper('&1')
OR UPPER(trigger_name) LIKE UPPER('%&1%')
ORDER BY 1;


set verify on