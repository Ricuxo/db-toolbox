Rem
Rem    NOME
Rem      bigidx.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica se há indices maiores que suas tabelas(owner).
Rem      
Rem    UTILIZAÇÃO
Rem      @bigidx
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      02/06/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
set verify off

col TABLE_OWNER  for a12
col TABLE_NAME   for a30
col INDEX_OWNER  for a12
col INDEX_NAME   for a30
-- col TAB_TAM_MB   for 999,999,999
-- col TAB_IDX_MB   for 999,999,999

select tab.OWNER as TABLE_OWNER,
       tab.SEGMENT_NAME as TABLE_NAME,
       trunc(tab.TAM_MB,0) as TAB_TAM_MB,
       idx.OWNER as INDEX_OWNER,
       idx.SEGMENT_NAME as INDEX_NAME,
       trunc(idx.TAM_MB,0) as TAB_IDX_MB
from dba_indexes DBA,
     (select OWNER, SEGMENT_NAME, BYTES/1024/1024 AS TAM_MB
      from dba_segments
      where segment_type = 'TABLE') TAB,
     (select OWNER, SEGMENT_NAME, BYTES/1024/1024 AS TAM_MB
      from dba_segments
      where segment_type = 'INDEX') IDX
where dba.INDEX_NAME = idx.SEGMENT_NAME
  and dba.TABLE_NAME = tab.SEGMENT_NAME
  and idx.TAM_MB > tab.TAM_MB
  and idx.TAM_MB > 10
order by 6 desc
/

set feedback on
set verify on