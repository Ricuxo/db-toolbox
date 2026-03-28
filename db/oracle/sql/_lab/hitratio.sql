prompt # 
prompt # Verifica estatiscas de acertos dos recursos de memoria do banco
prompt # 

---Calculo HIT RATIO

column "Physical Reads" format 99,999,999,999 
column "Consistent Gets" format 99,999,999,999 
column "DB Block Gets" format 99,999,999,999 
column "Percent (Above 70% ?)" format 999.99 
TTitle left "*****  Database:  "dbname", DB Block Buffers ( As of:  "xdate" )   *****" skip 1 - left "Percent = (100*(1-(Physical Reads/(Consistent Gets + DB Block  Gets))))" skip 2 
SELECT  physical_reads "Physical Reads", 
        consistent_gets "Consistent Gets", 
        db_block_gets "DB Block Gets", 
        (100*(1-(physical_reads/(consistent_gets+db_block_gets)))) "Percent (Above 70% ?)" 
 from (SELECT  VALUE db_block_gets FROM V$SYSSTAT WHERE NAME = 'db block gets') dbblockgets,
      (SELECT  VALUE consistent_gets FROM V$SYSSTAT WHERE NAME = 'consistent gets') consistentgets,
      (SELECT  VALUE physical_reads FROM V$SYSSTAT WHERE NAME = 'physical reads') physicalreads;




column "Executions" format 999,999,990 
column "Cache Misses Executing" format 999,999,990 
column "Data Dictionary Gets" format 999,999,999 
column "Get Misses" format 999,999,999 
ttitle left skip 1 - left "**********     Shared Pool Size (Execution Misses)     **********" skip 1 
select sum(pins) "Executions", 
        sum(reloads) "Cache Misses Executing", 
      (sum(reloads)/sum(pins)*100) "% Ratio (Ficar abaixo 1%)" 
 from v$librarycache; 




 
ttitle left "**********     Shared Pool Size (Dictionary Gets)     **********"  skip 1 
select sum(gets) "Data Dictionary Gets", 
        sum(getmisses) "Get Misses", 
        100*(sum(getmisses)/sum(gets)) "% Ratio (Ficar abaixo 12%)" 
 from v$rowcache; 



PROMPT 
TTITLE LEFT '> Rollback Ratios ' SKIP 2 

COLUMN "Ratio (%)" FORMAT 999.99 

SELECT name, ROUND((waits / gets) * 100, 2) "Ratio (%)" 
FROM v$rollstat a, v$rollname b 
WHERE a.usn = b.usn; 

prompt 
prompt Add more rollback segments if Ratio > 0% 
prompt 
prompt 

TTITLE OFF 

