Rem
Rem    NOME
Rem      undo.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script informa a situação da Tablespace de UNDO, a taxas de geração de UNDO e sugere valores para UNDO_RETENTION.
Rem      
Rem    UTILIZAÇÃO
Rem      @undo
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      03/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
column TAM_MB format a11
column USADO_MB format a11
column LIVRE_MB format a11
column OCUP_% format a7
column " " format a40

PROMPT
PROMPT Situação atual do UNDO:
select c.TABLESPACE_NAME, to_char( nvl( e.TAM, b.TAM ), '9999990.99' ) TAM_MB,
       to_char( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) USADO_MB,
       to_char( nvl( nvl( d.LIVRE, a.LIVRE ), 0 ), '9999990.99' ) LIVRE_MB,
       to_char( round( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ), 2 ), '990.99' ) "OCUP_%",
       rpad( rpad( chr(1), round( ( ( ( nvl( e.TAM, b.TAM ) - nvl( nvl( d.LIVRE, a.LIVRE ), 0 ) ) * 100 ) / nvl( e.TAM, b.TAM ) ) / 2.5 ), chr(1) ) ||
       '_', 40, '_' ) " "
  from DBA_TABLESPACES c,
       -- 
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 LIVRE
           from DBA_FREE_SPACE
          where TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace')
          group by TABLESPACE_NAME ) a,
       --
       ( select TABLESPACE_NAME, ( a.free_BLOCKS * b.VALUE ) / 1024 / 1024 LIVRE
           from V$SORT_SEGMENT a, V$PARAMETER b
          where b.NAME = 'db_block_size'
            and a.TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace') ) d,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_DATA_FILES
          where TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace')
          group by TABLESPACE_NAME ) b,
       --
       ( select TABLESPACE_NAME, sum( BYTES ) / 1024 / 1024 TAM
           from DBA_TEMP_FILES
          where TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace')
          group by TABLESPACE_NAME ) e
       --
 where c.TABLESPACE_NAME     = (select value from v$parameter where name = 'undo_tablespace')
   and a.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and d.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and b.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
   and e.TABLESPACE_NAME (+) = c.TABLESPACE_NAME
 order by c.TABLESPACE_NAME
/


PROMPT
-- col "UNDO_RETENTION (Sec)" for 999,999,999
-- col "UNDO_RETENTION (Min)" for 999,999,999
select value/60/60      as "UNDO_RETENTION (Horas)",
       value/60         as "UNDO_RETENTION (Min)", 
       to_number(value) as "UNDO_RETENTION (Sec)"
from v$parameter 
where name = 'undo_retention' 
/


PROMPT
PROMPT
PROMPT  Taxa de Geração de Undo:  
SELECT trunc(((AVG_UNDO_PER_SEC * 60) * DB_BLOCK_SIZE) /1024/1024,0) AS "Média(MB/Min)",
       trunc(((MAX_UNDO_PER_SEC * 60) * DB_BLOCK_SIZE) /1024/1024,0) AS "Máximo(MB/Min)"   
FROM (SELECT (SUM(undoblks)/SUM(((end_time-begin_time)*86400))) AS AVG_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT MAX(UNDOBLKS)/600 AS MAX_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT value AS DB_BLOCK_SIZE
        FROM v$parameter
        WHERE name = 'db_block_size')
/


PROMPT
PROMPT
PROMPT  Undo necessário para atender as transações atuais:
-- col Média(MB)  for 999,999,999
-- col Máximo(MB) for 999,999,999
SELECT trunc((AVG_UNDO_PER_SEC * DB_BLOCK_SIZE * UNDO_RETENTION) /1024/1024,0) AS "Média(MB)",
       trunc((MAX_UNDO_PER_SEC * DB_BLOCK_SIZE * UNDO_RETENTION) /1024/1024,0) AS "Máximo(MB)"   
FROM (SELECT (SUM(undoblks)/SUM(((end_time-begin_time)*86400))) AS AVG_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT MAX(UNDOBLKS)/600 AS MAX_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT value AS DB_BLOCK_SIZE
        FROM v$parameter
        WHERE name = 'db_block_size'),
     (SELECT value AS UNDO_RETENTION
        FROM v$parameter
        WHERE name = 'undo_retention')
/


PROMPT
PROMPT
PROMPT O UNDO_RETENTION pode ser configurado para: 
col "CONSIDERANDO A GERAÇÃO MÉDIA"  for a40
col "CONSIDERANDO A GERAÇÃO MÁXIMA" for a40
SELECT 'alter system set undo_retention=' || trunc((UNDO_SIZE_BYTES / (AVG_UNDO_PER_SEC * DB_BLOCK_SIZE)),0) AS "GERAÇÃO MÉDIA",
       'alter system set undo_retention=' || trunc((UNDO_SIZE_BYTES / (MAX_UNDO_PER_SEC * DB_BLOCK_SIZE)),0) AS "GERAÇÃO MÁXIMA"  
FROM (select sum(BYTES) AS UNDO_SIZE_BYTES
        from DBA_DATA_FILES
        where TABLESPACE_NAME = (select value from v$parameter where name = 'undo_tablespace')),
     (SELECT (SUM(undoblks)/SUM(((end_time-begin_time)*86400))) AS AVG_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT MAX(UNDOBLKS)/600 AS MAX_UNDO_PER_SEC
        FROM v$undostat),
     (SELECT value AS DB_BLOCK_SIZE
        FROM v$parameter
        WHERE name = 'db_block_size')
/

PROMPT
PROMPT
set feedback on



