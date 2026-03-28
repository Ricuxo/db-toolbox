Rem
Rem    NOME
Rem      stats.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica se as tabelas estão sendo monitoradas para fins de 
Rem      coleta de estatisticas.
Rem      
Rem    UTILIZAÇÃO
Rem      @stats
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       08/10/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col comando for a70
col dt_criacao for a25
col last_analyzed for a25
set pages 50

select 'alter table '||t.OWNER||'.'||t.table_name||' monitoring;' as comando, 
        t.monitoring,
        to_char(t.last_analyzed,'yyyy/mm/dd hh24:mi:ss') last_analyzed,
         to_char(o.created, 'yyyy/mm/dd hh24:mi:ss') dt_criacao 
from dba_tables t, dba_objects o
where t.owner not in ('SYSTEM', 'SYS', 'PERFSTAT', 'DBSNMP', 'OUTLN','WMSYS','QUEST')
and t.owner = o.owner
and t.table_name = o.object_name
and t.table_name not like 'PLAN_TABLE'
order by monitoring desc, last_analyzed, created
/

set pages 200