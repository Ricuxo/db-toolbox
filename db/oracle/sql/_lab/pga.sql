Rem
Rem    NOME
Rem      pga.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações sobre a PGA.
Rem      
Rem    UTILIZAÇÃO
Rem      @pga
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       04/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
col name for a70
col value_bytes for a20
col value for 99999999999999


select NAME, 
       VALUE VALUE_BYTES
from v$parameter
where NAME in ('pga_aggregate_target',
               'workarea_size_policy',        
               'sort_area_size',
               'sort_area_retained_size'         
               )
order by 1	
/

SELECT *
FROM v$pgastat
WHERE name = 'cache hit percentage'
/

SELECT ROUND(pga_target_for_estimate/1024/1024) AS target_mb,
       estd_pga_cache_hit_percentage AS cache_hit_percent, 
       estd_overalloc_count
FROM v$pga_target_advice
ORDER BY target_mb
/

SELECT low_optimal_size/1024 AS low_kb,
       (high_optimal_size+1)/1024 AS high_kb,
       ROUND(100*optimal_executions/total_executions) AS optimal,
       ROUND(100*onepass_executions/total_executions) AS onepass,
       ROUND(100*multipasses_executions/total_executions) AS multipass
FROM v$sql_workarea_histogram
WHERE total_executions != 0
ORDER BY low_kb
/

SELECT * FROM v$pgastat
/

PROMPT
PROMPT Aumente o valor de PGA_AGGREGATE_TARGET ou SORT_AREA_SIZE se a relação for maior que 5%.
SELECT d.value "Disk", m.value "Mem",
       round (((d.value/m.value)*100),2) "Sort_Hit_Ratio"
FROM v$sysstat m, v$sysstat d
WHERE m.name = 'sorts (memory)'
AND d.name = 'sorts (disk)'
/

PROMPT
set feedback on