Rem
Rem    NOME
Rem      topsql.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script exibe as instruções com mais buffer_gets e executions no momento      
Rem
Rem    UTILIZAÇÃO
Rem      @topsql
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/08/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

column SQL_TEXT    format a80
column PROGRAM     format a20
column BUFFER_GETS format 999,999,999,999
column DISK_READS  format 999,999,999,999
column EXECUTIONS  format 999,999,999,999

PROMPT
PROMPT Identificando as 5 instrucoes SQLs que estao consumindo mais CPU (BUFFER_GETS)  1,000 = mil

SELECT b.sid, 
       b.program,
       buffer_gets, 
       disk_reads, 
       executions,
--       round((buffer_gets/executions), 2) "Gets/Exec",
--       round(( disk_reads/executions), 2) "Reads/Exec",
       sql_text
FROM v$sqlarea a, v$session b
WHERE b.sql_hash_value = a.hash_value
  and rownum < 6
ORDER BY buffer_gets desc
/



PROMPT
PROMPT Identificando as 5 instrucoes SQLs que estao consumindo mais I/O (DISK_READS)  1,000 = mil

SELECT b.sid, 
       b.program,
       disk_reads,          
       buffer_gets, 
       executions,
--       round((buffer_gets/executions), 2) "Gets/Exec",
--       round(( disk_reads/executions), 2) "Reads/Exec",
       sql_text
FROM v$sqlarea a, v$session b
WHERE b.sql_hash_value = a.hash_value
  and rownum < 6
ORDER BY disk_reads desc
/


PROMPT
PROMPT Identificando as 5 instrucoes SQLs que estao realizando mais SORTS (SORTS)  1,000 = mil

SELECT b.sid, 
       b.program,
       sorts,          
       buffer_gets, 
       executions,
--       round((buffer_gets/executions), 2) "Gets/Exec",
--       round(( disk_reads/executions), 2) "Reads/Exec",
       sql_text
FROM v$sqlarea a, v$session b
WHERE b.sql_hash_value = a.hash_value
  and rownum < 6
ORDER BY sorts desc
/











