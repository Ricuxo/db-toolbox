Rem
Rem    NOME
Rem      librarycache.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações sobre o cache de biblioteca(library_cache).
Rem      
Rem    UTILIZAÇÃO
Rem      @librarycache
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       01/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

col value for 999999999

select NAME, 
       trunc(VALUE/1024/1024,0) as value_mb
from v$parameter
where NAME in ('sga_max_size','shared_pool_size','shared_pool_reserved_size')
order by 2 desc 	
/


col tam_kb for 999999999
col pool for a15

select POOL,   
       NAME,   
       trunc(BYTES/1024/1024,0) as TAM_MB
from v$sgastat
where pool = 'shared pool'
and   name in ('library cache','free memory')
order by 1
/

col value for a20
select NAME, 
       VALUE
from v$parameter
where NAME = 'cursor_sharing'	
/

PROMPT
PROMPT
PROMPT Verificar se os comandos SQLs estão sendo compartilhados => GETHITRATIO da SQL AREA > 90%   

select NAMESPACE,
       GETS as "GETS(parses)",
       trunc(GETHITRATIO,2) as GETHITRATIO,
       PINS as "PINS(executions)",
       RELOADS as "RELOADS(parses/cache_misses)",
       INVALIDATIONS " INVALIDATIONS(reparses)"
from V$LIBRARYCACHE
order by RELOADS desc, INVALIDATIONS desc
/

PROMPT
PROMPT
PROMPT Verificar se as instruções estão sendo removidas do cache(LRU), evitar recargas => RELOAD_HITRATIO < 1% 

select sum(pins) as "TOTAL_PINS(executions)",
       sum(reloads) as "TOTAL_RELOADS(cache_misses)",
       trunc((SUM(reloads)/sum(pins)),5) as RELOAD_HITRATIO 
from V$LIBRARYCACHE
/


PROMPT
PROMPT
PROMPT Verificar se há ganho de tempo "estmd_lc_time_saved" se aumentar o shared_pool.
select * from V$SHARED_POOL_ADVICE 
/


PROMPT
PROMPT
PROMPT Verificar se existem objetos "pinados" na shared_pool. 

col owner   for a15
col name    for a30
col db_link for a30
select * 
from v$db_object_cache 
where kept = 'YES'
and owner not in ('SYS','XDB')
/


PROMPT
PROMPT
PROMPT Busca por instruções SQL Não Compartilhadas que poderiam ter os literais substituidos por BIND.

col module for a30
select HASH_VALUE, MODULE, substr(SQL_TEXT,0,80)
from v$sqlarea
where EXECUTIONS < 5
and rownum <20
order by upper(SQL_TEXT)
/


PROMPT
PROMPT
PROMPT Busca por instruções SQL Submetidas a Reparse, se o valor de PARSE_CALLS ~= EXECUTIONS, sofrendo muito reparses.   

select HASH_VALUE, MODULE, PARSE_CALLS, EXECUTIONS, substr(SQL_TEXT,0,80)
from v$sqlarea
where PARSE_CALLS >= EXECUTIONS
and rownum <20
order by PARSE_CALLS desc 
/


prompt

set feedback on

