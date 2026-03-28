Rem
Rem    NOME
Rem      fragidx.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista informações sobre a utilização de espaço de um indice.
Rem      
Rem    UTILIZAÇÃO
Rem      @fragidx <owner> <table>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       22/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off
set feedback off
col index_name        for a35
col index_type        for a10
col num_rows          for 999,999,999,999 
col leaf_blocks       for 999,999,999,999
col clustering_factor for 999,999,999,999  
col distinct_keys     for 999,999,999,999
col COLUMN_NAME       for a25

PROMPT
PROMPT Lista informações sobre a utilização de espaço de um indice.
PROMPT
PROMPT Se cluster proximo a leaf_blocks = bom 
PROMPT Se cluster proximo a distinct_keys = ruim     

SELECT owner || '.' || index_name as index_name,
       leaf_blocks, 
       clustering_factor, 
       distinct_keys,
       NUM_ROWS, 
       INDEX_TYPE, 
       STATUS, 
       blevel,
       last_analyzed,
       TABLE_OWNER || '.' || TABLE_NAME as table_name
FROM dba_indexes
WHERE owner = upper('&1')
 AND index_name = upper('&2') 
/

select COLUMN_NAME,            
       COLUMN_POSITION,        
       COLUMN_LENGTH,       
       CHAR_LENGTH,            
       DESCEND                
from dba_ind_columns
where index_name = upper('&2')
/

col segment_name for a35
select SEGMENT_NAME, 
       PARTITION_NAME, 
       BYTES/1024/1024 as TAM_MB, 
       EXTENTS, 
       TABLESPACE_NAME
from dba_segments
WHERE owner = upper('&1')
  and SEGMENT_NAME = upper('&2')
/


-- execute DBMS_STATS.GATHER_INDEX_STATS (ownname => '&1', indname => '&2'); 


PROMPT
PROMPT ==> Atenção! Reorganize o indice quando DELETE_PCT ultrapassar 20%

select NAME as INDEX_NAME, 
       PARTITION_NAME,  
      (DEL_LF_ROWS/LF_ROWS)*100 as "==> DELETE_PCT",      
      LF_ROWS, 
       DEL_LF_ROWS,
       DEL_LF_ROWS_LEN/1024/1024 as TAMANHO_DELETADOS_MB,
       BTREE_SPACE,
       USED_SPACE
from index_stats
where NAME = upper('&2')
/

PROMPT
set verify on
set feedback on 

