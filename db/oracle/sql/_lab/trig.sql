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
Rem      FERR@RI      13/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off

select OWNER, 
       TRIGGER_NAME, 
       TRIGGER_TYPE, 
       TRIGGERING_EVENT
from dba_triggers
where OWNER = upper('&1')
OR trigger_name LIKE UPPER('%&1%');
/
set verify on