--
--
--  NAME
--    ectop.sql
--
--  DESCRIPTION
--    Exibe os comandos que mais consumiram recursos.
--
--  HISTORY
--    23/05/2008(Eduardo Chinelatto)
--
-----------------------------------------------------------------------------

COL EXEC          FOR 9999999     HEADING 'Exec'
COL TEXT                          HEADING 'Sql text'
COL HASH_VALUE    FOR 9999999999  HEADING 'Hash|value'
COL GETS          FOR 999999999   HEADING 'Logical|read'
COL READS         FOR 999999999   HEADING 'Physical|read'
COL OPT_MODE      FOR A9          HEADING 'Optimizer|mode'
COL RATIO         FOR 999         HEADING 'Hit|Ratio'
COL ROWS_PROC     FOR 999999999   HEADING 'Rows|processed'
COL ELAPSED       FOR 99999.00    HEADING 'Elapsed|time'
COL CPU           FOR 99999.00    HEADING 'Cpu|time'
set wrap off
set lines 130
set pages 100


SELECT SUBSTR(SQL_TEXT, 1, 30) TEXT,
       EXECUTIONS EXEC,
       ROUND(BUFFER_GETS / EXECUTIONS) GETS,
       ROUND(DISK_READS / EXECUTIONS) READS,
       ROUND((BUFFER_GETS-DISK_READS)/BUFFER_GETS*100) RATIO,
       OPTIMIZER_MODE OPT_MODE,
       ROUND(ROWS_PROCESSED / EXECUTIONS) ROWS_PROC,
       HASH_VALUE,
       ROUND(ELAPSED_TIME / EXECUTIONS / 1000000, 2) elapsed,
       ROUND(CPU_TIME / EXECUTIONS / 1000000, 2) CPU
FROM V$SQL
WHERE EXECUTIONS >= 1 AND
      BUFFER_GETS / DECODE(EXECUTIONS, 0, 1, EXECUTIONS) > 1000
ORDER BY 3 DESC;

--
-- Fim
--

