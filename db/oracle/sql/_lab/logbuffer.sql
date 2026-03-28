Rem
Rem    NOME
Rem      logbuffer.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações sobre o Buffer de Redo Log(log_buffer).
Rem      
Rem    UTILIZAÇÃO
Rem      @logbuffer
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       04/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
col cpu_count for a9 justify right

PROMPT
PROMPT O valor de LOG_BUFFER deve ser 512K ou 128K * cpu_count, o que for maior.

select (select value from v$parameter where name = 'cpu_count') as cpu_count,
       ((select value from v$parameter where name = 'cpu_count')*128)/1024 as value_ideal_mb,
       (select trunc(VALUE/1024/1024,0) 
        from v$parameter where NAME = 'log_buffer') as value_actual_mb
from dual
/

SELECT r.value "Retries", 
       e.value "Entries",
       r.value/e.value*100 "Percentage"
FROM v$sysstat r, v$sysstat e
WHERE r.name = 'redo buffer allocation retries'
  AND e.name='redo entries';


PROMPT
set feedback on