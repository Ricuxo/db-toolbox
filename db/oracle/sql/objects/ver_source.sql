Rem
Rem    NOME
Rem      trig.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe codigo fonte de um determinado objeto.
Rem
Rem    UTILIZAÇÃO
Rem      @trig <owner> <trigger_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      LUIZ NORONHA      14/06/10 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


set verify off
set hea off
set long 1000
set pagesize 300

select TEXT     
from dba_source
WHERE OWNER = CASE WHEN INSTR(UPPER('&1'),'.') > 0 THEN SUBSTR(UPPER('&1'),1,INSTR(UPPER('&1'),'.')-1) END
AND NAME = CASE WHEN INSTR(UPPER('&1'),'.') > 0 THEN SUBSTR(UPPER('&1'),INSTR(UPPER('&1'),'.')+1) END;

set verify on
set hea on
set pagesize 50