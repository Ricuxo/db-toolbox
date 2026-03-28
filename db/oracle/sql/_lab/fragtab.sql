Rem
Rem    NOME
Rem      fragtab.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra informações de utilização de espaço de uma tabela.
Rem      
Rem    UTILIZAÇÃO
Rem      @fragtab <owner> <table>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       22/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set verify off
-- num_rows     = O número de linhas da tabela
-- avg_row_len  = Tamanho médio da linha, incluindo o overhead da linha
-- empty_blocks = O número de blocos  acima da marca d'água superior da tabela 
-- blocks       = O número de blocos abaixo da marca d'água superior da tabela
-- avg_space    = O espaço médio livre em bytes nos blocos abaixo da marca d'água superior
-- chain_cnt    = O número de linhas encadeadas ou migradas na tabela

col table_name for a30
col num_rows for 999999999999999
col tam_mb for 999999999999999  
col free_space_under_hwm_MB for 999999999999999  
col blocks_under_hwm  for 999999999999999
-- col tam_mb for a15

SELECT owner || '.' || table_name as table_name,
       last_analyzed, 
         (select bytes/1024/1024 
          from dba_segments 
          where owner = upper('&1')
          and segment_name = upper('&2')) as tam_mb,                         
       trunc((avg_space * blocks)/1024/1024,0) as free_space_under_hwm_MB,
       blocks as blocks_under_hwm,           
       avg_space as avg_free_space_under_hwm_bytes, 
       empty_blocks as blocks_above_hwm,     
       num_rows,                              
       avg_row_len,   
       chain_cnt                              
FROM dba_tables
WHERE owner     = upper('&1')
 AND table_name = upper('&2')
/

set verify on