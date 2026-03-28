Rem
Rem    NOME
Rem      segtbs.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista owner, nome, tipo e dos objetos existentes em um tablespace específico.
Rem
Rem    UTILIZAÇÃO
Rem      @segtbs <NOME_DA_TABLESPACE>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      26/02/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

col OWNER        for a18
col SEGMENT_NAME for a30

select OWNER, 
       SEGMENT_NAME, 
       PARTITION_NAME, 
       SEGMENT_TYPE, 
       BYTES/1024/1024 as MB
from dba_segments
where TABLESPACE_NAME = upper ('&1')
order by 1, 2, 3
/