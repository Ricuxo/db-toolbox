Rem
Rem    NOME
Rem      buffercache.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações sobre o cache de buffer(buffer_cache).
Rem      
Rem    UTILIZAÇÃO
Rem      @buffercache
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       04/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

select NAME, 
       trunc(VALUE/1024/1024,0) as value_mb
from v$parameter
where NAME in ('sga_max_size',
               'db_cache_size',
               'db_keep_cache_size',      
               'db_recycle_cache_size',
               'db_2k_cache_size',
               'db_4k_cache_size',        
               'db_8k_cache_size',
               'db_16k_cache_size',        
               'db_32k_cache_size'       
               )
order by 2 desc 	
/


PROMPT
SELECT round(((1 - (phy.value - lob.value - dir.value) / ses.value)*100),2) "TOTAL_CACHE_HIT_HATIO__PCT"
FROM   v$sysstat ses, v$sysstat lob, v$sysstat dir, v$sysstat phy 
WHERE  ses.name = 'session logical reads'
AND    dir.name = 'physical reads direct'
AND    lob.name = 'physical reads direct (lob)'
AND    phy.name = 'physical reads'
/

select name, block_size, round(((1 - (physical_reads / (db_block_gets + consistent_gets)))*100),2) "HIT_HATIO_PCT"
from v$buffer_pool_statistics
where db_block_gets + consistent_gets > 0
/

PROMPT
set pages 24

select NAME,
       BLOCK_SIZE, 
       SIZE_FOR_ESTIMATE, 
       SIZE_FACTOR, 
       BUFFERS_FOR_ESTIMATE, 
       ESTD_PHYSICAL_READ_FACTOR, 
       ESTD_PHYSICAL_READS
from v$db_cache_advice
/

prompt

set feedback on
set pages 3000


